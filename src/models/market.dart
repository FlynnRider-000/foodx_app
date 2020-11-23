
import '../models/media.dart';
import 'user.dart';

class Market {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  String latitude;
  String longitude;
  bool pay_on_pickup;
  bool closed;
  bool availableForDelivery;
  bool free_shipping;
  bool limited_shipping;
  int shipping_method;
  int mini_order;
  double deliveryRange;
  double distance;
  List<User> users;
  List<String> categories;
  Market();

  Market.fromJSON(Map<String, dynamic> jsonMap) {
    try {

      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      adminCommission = jsonMap['admin_commission'] != null ? jsonMap['admin_commission'].toDouble() : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null ? jsonMap['delivery_range'].toDouble() : 0.0;
      address = jsonMap['address'];
      description = jsonMap['description'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null ? jsonMap['default_tax'].toDouble() : 0.0;
      information = jsonMap['information'];
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      closed = jsonMap['closed'] ?? false;
      shipping_method = jsonMap['shipping_method'];
      free_shipping = jsonMap['free_shipping'] == 1 ? true : false;
      limited_shipping = jsonMap['limited_shipping'] == 1 ? true : false;
      pay_on_pickup = jsonMap['pay_on_pickup'] == 1 ? true : false;
      mini_order = jsonMap['mini_order'];
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      distance = jsonMap['distance'] != null ? double.parse(jsonMap['distance'].toString()) : 0.0;
      categories = (jsonMap['category_lists'] != "" && jsonMap['category_lists'] != null) ? jsonMap['category_lists'].split(",").toList() : new List();
      users = jsonMap['users'] != null && (jsonMap['users'] as List).length > 0
          ? List.from(jsonMap['users']).map((element) => User.fromJSON(element)).toSet().toList()
          : [];
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = false;
      shipping_method = 0;
      free_shipping = false;
      pay_on_pickup = false;
      limited_shipping = true;
      mini_order= 0;
      availableForDelivery = false;
      distance = 0.0;
      categories = new List();
      users = [];
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance,
    };
  }
}
