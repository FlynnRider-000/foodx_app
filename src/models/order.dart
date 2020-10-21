import '../models/address.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../models/user.dart';

class Order {
  String id;
  List<ProductOrder> productOrders;
  OrderStatus orderStatus;
  double tax;
  double deliveryFee;
  String hint;
  bool active;
  DateTime dateTime;
  User user;
  String checkout_note;
  Payment payment;
  Address deliveryAddress;
  double total;

  Order();

  Order.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      tax = jsonMap['tax'] != null ? jsonMap['tax'].toDouble() : 0.0;
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      hint = jsonMap['hint'] != null ? jsonMap['hint'].toString() : '';
      active = jsonMap['active'] ?? false;
      orderStatus = jsonMap['order_status'] != null ? OrderStatus.fromJSON(jsonMap['order_status']) : OrderStatus.fromJSON({});
      dateTime = DateTime.parse(jsonMap['updated_at']);
      checkout_note = jsonMap['check_out_note'] != null ? jsonMap['check_out_note'] : '';
      user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : User.fromJSON({});
      deliveryAddress = jsonMap['delivery_address'] != null ? Address.fromJSON(jsonMap['delivery_address']) : Address.fromJSON({});
      payment = jsonMap['payment'] != null ? Payment.fromJSON(jsonMap['payment']) : Payment.fromJSON({});
      productOrders = jsonMap['product_orders'] != null ? List.from(jsonMap['product_orders']).map((element) => ProductOrder.fromJSON(element)).toList() : [];
      total = 0;
    } catch (e) {
      id = '';
      tax = 0.0;
      deliveryFee = 0.0;
      hint = '';
      active = false;
      orderStatus = OrderStatus.fromJSON({});
      dateTime = DateTime(0);
      user = User.fromJSON({});
      checkout_note = "";
      payment = Payment.fromJSON({});
      deliveryAddress = Address.fromJSON({});
      productOrders = [];
      total = 0;
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["user_id"] = user?.id;
    map["order_status_id"] = orderStatus?.id;
    map["tax"] = tax;
    map['hint'] = hint;
    map["delivery_fee"] = deliveryFee;
    map["products"] = productOrders?.map((element) => element.toMap())?.toList();
    map["payment"] = payment?.toMap();
    map["check_out_note"] = checkout_note;
    map["total"] = total;
    if (!deliveryAddress.isUnknown()) {
      map["delivery_address_id"] = deliveryAddress?.id;
    }
    return map;
  }

  Map deliveredMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["order_status_id"] = 5;
    if (deliveryAddress?.id != null && deliveryAddress?.id != 'null') map["delivery_address_id"] = deliveryAddress.id;
    return map;
  }

  Map cancelMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    if (orderStatus?.id != null && orderStatus?.id == '1') map["active"] = false;
    return map;
  }

  bool canCancelOrder() {
    return this.active == true && this.orderStatus.id == '1'; // 1 for order received status
  }
}
