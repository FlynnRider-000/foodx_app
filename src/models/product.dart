import '../models/category.dart';
import '../models/market.dart';
import '../models/media.dart';
import '../models/option.dart';
import '../models/option_group.dart';
import '../models/review.dart';
import 'coupon.dart';
import '../repository/order_repository.dart';

class Product {
  String id;
  String name;
  double price;
  double discountPrice;
  Media image;
  String description;
  String ingredients;
  String capacity;
  String unit;
  String packageItemsCount;
  bool featured;
  bool deliverable;
  bool outOfStock;
  Market market;
  Category category;
  List<Option> options;
  List<OptionGroup> optionGroups;
  List<Review> productReviews;

  Product();

  Product.fromJSONSuper(Map<String, dynamic> jsonMap, mrk, catgry) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      discountPrice = jsonMap['discount_price'] != null ? jsonMap['discount_price'].toDouble() : 0.0;
      price = discountPrice != 0 ? discountPrice : price;
      discountPrice = discountPrice == 0 ? discountPrice : jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      description = jsonMap['description'];
      capacity = jsonMap['capacity'].toString();
      unit = jsonMap['unit'] != null ? jsonMap['unit'].toString() : '';
      packageItemsCount = jsonMap['package_items_count'].toString();
      featured = jsonMap['featured'] ?? false;
      outOfStock = jsonMap['out_of_stock'] ?? false;
      deliverable = jsonMap['deliverable'] ?? false;
      market = mrk;
      category = catgry;
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      options = jsonMap['options'] != null && (jsonMap['options'] as List).length > 0
          ? List.from(jsonMap['options']).map((element) => Option.fromJSON(element)).toSet().toList()
          : [];
      optionGroups = jsonMap['option_groups'] != null && (jsonMap['option_groups'] as List).length > 0
          ? List.from(jsonMap['option_groups']).map((element) => OptionGroup.fromJSON(element)).toSet().toList()
          : [];
      productReviews = jsonMap['product_reviews'] != null && (jsonMap['product_reviews'] as List).length > 0
          ? List.from(jsonMap['product_reviews']).map((element) => Review.fromJSON(element)).toSet().toList()
          : [];
    } catch (e) {
      id = '';
      name = '';
      price = 0.0;
      discountPrice = 0.0;
      description = '';
      capacity = '';
      unit = '';
      packageItemsCount = '';
      featured = false;
      deliverable = false;
      outOfStock = false;
      market = Market.fromJSON({});
      category = Category.fromJSON({});
      image = new Media();
      options = [];
      optionGroups = [];
      productReviews = [];
      print(e);
    }
  }

  Product.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      discountPrice = jsonMap['discount_price'] != null ? jsonMap['discount_price'].toDouble() : 0.0;
      price = discountPrice != 0 ? discountPrice : price;
      discountPrice = discountPrice == 0 ? discountPrice : jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      description = jsonMap['description'];
      capacity = jsonMap['capacity'].toString();
      unit = jsonMap['unit'] != null ? jsonMap['unit'].toString() : '';
      packageItemsCount = jsonMap['package_items_count'].toString();
      featured = jsonMap['featured'] ?? false;
      outOfStock = jsonMap['out_of_stock'] ?? false;
      deliverable = jsonMap['deliverable'] ?? false;
      market = jsonMap['market'] != null ? Market.fromJSON(jsonMap['market']) : Market.fromJSON({});
      category = jsonMap['category'] != null ? Category.fromJSON(jsonMap['category']) : Category.fromJSON({});
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      options = jsonMap['options'] != null && (jsonMap['options'] as List).length > 0
          ? List.from(jsonMap['options']).map((element) => Option.fromJSON(element)).toSet().toList()
          : [];
      optionGroups = jsonMap['option_groups'] != null && (jsonMap['option_groups'] as List).length > 0
          ? List.from(jsonMap['option_groups']).map((element) => OptionGroup.fromJSON(element)).toSet().toList()
          : [];
      productReviews = jsonMap['product_reviews'] != null && (jsonMap['product_reviews'] as List).length > 0
          ? List.from(jsonMap['product_reviews']).map((element) => Review.fromJSON(element)).toSet().toList()
          : [];
    } catch (e) {
      id = '';
      name = '';
      price = 0.0;
      discountPrice = 0.0;
      description = '';
      capacity = '';
      unit = '';
      packageItemsCount = '';
      featured = false;
      deliverable = false;
      outOfStock = false;
      market = Market.fromJSON({});
      category = Category.fromJSON({});
      image = new Media();
      options = [];
      optionGroups = [];
      productReviews = [];
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["discountPrice"] = discountPrice;
    map["description"] = description;
    map["capacity"] = capacity;
    map["package_items_count"] = packageItemsCount;
    return map;
  }

  double getRate() {
    double _rate = 0;
    productReviews.forEach((e) => _rate += double.parse(e.rate));
    _rate = _rate > 0 ? (_rate / productReviews.length) : 0;
    return _rate;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;

  Coupon applyCoupon(Coupon coupon) {
    isCouponUsed = 0;
    usedCoupon = '';
    if (coupon.code != '') {
      if (coupon.valid == null) {
        coupon.valid = false;
      }
      coupon.discountables.forEach((element) {
        if (element.discountableType == "App\\Models\\Product") {
          if (element.discountableId == id) {
            coupon = _couponDiscountPrice(coupon);
            usedCoupon = coupon.code;
            isCouponUsed = 1;
          }
        } else if (element.discountableType == "App\\Models\\Market") {
          if (element.discountableId == market.id) {
            coupon = _couponDiscountPrice(coupon);
            usedCoupon = coupon.code;
            isCouponUsed = 1;
          }
        } else if (element.discountableType == "App\\Models\\Category") {
          if (element.discountableId == category.id) {
            coupon = _couponDiscountPrice(coupon);
            usedCoupon = coupon.code;
            isCouponUsed = 1;
          }
        }
      });
    }
    return coupon;
  }

  Coupon _couponDiscountPrice(Coupon coupon) {
    coupon.valid = true;
    discountPrice = price;
    if (coupon.discountType == 'fixed') {
      price -= coupon.discount;
    } else {
      price = price - (price * coupon.discount / 100);
    }
    if (price < 0) price = 0;
    return coupon;
  }
}
