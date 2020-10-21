import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

int isCouponUsed = 0;
String usedCoupon = '';

Future<Stream<Order>> getOrders() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=user;productOrders;productOrders.product;productOrders.options;orderStatus;payment&search=user.id:${_user.id}&searchFields=user.id:=&orderBy=id&sortedBy=desc';

  print("\n");
  print("--------------OrderRepository/getOrders-----------------");
  print(url);


  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrder(orderId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders/$orderId?${_apiToken}with=user;productOrders;productOrders.product;orderStatus;deliveryAddress;payment';

  print("\n");
  print("--------------OrderRepository/getOrder-----------------");
  print(url);


  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
    return Order.fromJSON(data);
  });
}

Future<Stream<Order>> getRecentOrders() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=user;productOrders;productOrders.product;orderStatus;payment&search=user.id:${_user.id}&searchFields=user.id:=&orderBy=updated_at&sortedBy=desc&limit=3';

  print("\n");
  print("--------------OrderRepository/getRecentOrders-----------------");
  print(url);


  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Order.fromJSON(data);
  });
}

Future<Stream<OrderStatus>> getOrderStatus() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}order_statuses?$_apiToken';

  print("\n");
  print("--------------OrderRepository/getOrderStatus-----------------");
  print(url);


  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return OrderStatus.fromJSON(data);
  });
}

Future<Order> addOrder(Order order, Payment payment, double total) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  CreditCard _creditCard = await userRepo.getCreditCard();
  order.user = _user;
  order.payment = payment;
  order.total = total;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}orders?$_apiToken';
  final client = new http.Client();
  Map params = order.toMap();
  params.addAll(_creditCard.toMap());

  var couponMap = new Map<String, dynamic>();
  couponMap["isCouponUsed"] = isCouponUsed;
  couponMap["usedCoupon"] = usedCoupon;

  params.addAll(couponMap);
  print("\n");
  print("--------------OrderRepository/addOrder-----------------");
  print(url);
  print(json.encode(params));


  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(params),
  );

  if(json.decode(response.body)['success'] == true)
    return Order.fromJSON(json.decode(response.body)['data']);
  else{
    Order temp = new Order();
    temp.id = "-1";
    temp.checkout_note = json.decode(response.body)['message'];
    return temp;
  }
}

Future<Order> cancelOrder(Order order) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';

  print("\n");
  print("--------------OrderRepository/cancelOrder-----------------");
  print(url);
  print(json.encode(order.cancelMap()));


  final client = new http.Client();
  final response = await client.put(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.cancelMap()),
  );
  if (response.statusCode == 200) {
    return Order.fromJSON(json.decode(response.body)['data']);
  } else {
    throw new Exception(response.body);
  }
}
