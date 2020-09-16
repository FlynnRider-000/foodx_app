import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sprintf/sprintf.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  String paymentMethod = "";
  static String checkout_note = "";
  int parentWidgetType = 0;
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message, int showToast:1 }) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          coupon = _cart.product.applyCoupon(coupon);
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null && showToast == 1) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts({int showToast = 1}) async {
    setState(() {
      carts = [];
    });
    if(showToast == 1)
      listenForCarts(message: S.of(context).carts_refreshed_successfuly);
    else
      listenForCarts(message: S.of(context).carts_refreshed_successfuly,showToast:0);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_product_was_removed_from_your_cart(_cart.product.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    carts.forEach((cart) {
      double productAmount = cart.product.price * cart.quantity;
      subTotal += productAmount;
    });
    /*if (Helper.canDelivery(carts[0].product.market, carts: carts)) {
      deliveryFee = carts[0].product.market.deliveryFee;
    }*/
    //deliveryFee = subTotal < carts[0].product.market.mini_order ? carts[0].product.market.deliveryFee : 0;
    taxAmount = (subTotal + deliveryFee) * carts[0].product.market.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
    setState(() {});
  }

  void doApplyCoupon(String code, {String message}) async {
    coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen((Coupon _coupon) async {
      coupon = _coupon;
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
    });
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout(BuildContext context) {
    int flag = 0;
    double sum = 0;
    int limit = carts[0].product.market.mini_order;
    for (int i = 0; i < carts.length; i++)
      sum += carts[i].product.price * carts[i].quantity;

    /*if (carts[0].product.market.shipping_method == 0) {//FreeShipping
      if(carts[0].product.market.free_shipping == false) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(sprintf(S.of(context).market_minimum_order, [limit, carts[0].product.market.deliveryFee]))
        ));
      }
    }*/
    if(carts[0].product.market.shipping_method == 1) { //LimitedShipping
      if(sum < limit && carts[0].product.market.limited_shipping == true) {
        flag = 1;
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(sprintf(S.of(context).market_limited_order, [limit]))
        ));
      }
      /*if(sum < limit && carts[0].product.market.limited_shipping == false) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(sprintf(S.of(context).market_minimum_order, [limit, carts[0].product.market.deliveryFee]))
        ));
      }*/
    }
    if(flag == 0) {
      if (!currentUser.value.profileCompleted()) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).completeYourProfileDetailsToContinue),
          action: SnackBarAction(
            label: S.of(context).settings,
            textColor: Theme.of(context).accentColor,
            onPressed: () {
              Navigator.of(context).pushNamed('/Settings');
            },
          ),
        ));
      } else {
        if (carts[0].product.market.closed) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).this_market_is_closed_),
          ));
        } else {
          Navigator.of(context).pushNamed('/DeliveryPickup');
        }
      }
    }
  }

  Color getCouponIconColor() {
    if (coupon?.valid == true) {
      return Colors.green;
    } else if (coupon?.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(context).focusColor.withOpacity(0.7);
  }
}
