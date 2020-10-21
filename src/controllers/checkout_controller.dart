import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class CheckoutController extends CartController {
  Payment payment;
  CreditCard creditCard = new CreditCard();
  bool loading = true;
  bool placeOrderSuccess = false;
  String orderNotPlacedStr = "";
  GlobalKey<ScaffoldState> scaffoldKey;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  @override
  void onLoadingCartDone() {
    if (payment != null) addOrder(carts);
    super.onLoadingCartDone();
  }

  void addOrder(List<Cart> carts) async {
    Order _order = new Order();

    _order.checkout_note = CartController.checkout_note;
    _order.productOrders = new List<ProductOrder>();
    _order.tax = carts[0].product.market.defaultTax;
    _order.deliveryFee =  0;
    OrderStatus _orderStatus = new OrderStatus();
    _orderStatus.id = '1'; // TODO default order status Id
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = settingRepo.deliveryAddress.value;
    _order.hint = ' ';

    double subTotal = 0;
    carts.forEach((_cart) {
      ProductOrder _productOrder = new ProductOrder();
      _productOrder.quantity = _cart.quantity;
      _productOrder.price = _cart.product.price;
      _productOrder.product = _cart.product;
      _productOrder.options = _cart.options;

      double cc = _productOrder.price;
      _productOrder.options.forEach((element) {
        cc += element.price;
      });
      subTotal += cc * _productOrder.quantity;

      _order.productOrders.add(_productOrder);
    });

    if(payment.method != 'Pay on Pickup') {
      if( (!(carts[0].product.market.shipping_method == 0 && carts[0].product.market.free_shipping == true)  &&
          !(carts[0].product.market.shipping_method == 1 && subTotal >= carts[0].product.market.mini_order && carts[0].product.market.limited_shipping == false)) ||
          (payment.id == "visacard" || payment.id == "mastercard")
      )
        _order.deliveryFee = carts[0].product.market.deliveryFee;
    }

    total = subTotal;
    total += subTotal * _order.tax / 100;
    total += _order.deliveryFee;
    deliveryFee = _order.deliveryFee;
    orderRepo.addOrder(_order, this.payment, total).then((value) async{
      settingRepo.coupon = new Coupon.fromJSON({});
      return value;
    }).then((value) {
      if (value is Order) {
        if(value.id != "-1")
          setState(() {
            loading = false;
            placeOrderSuccess = true;
          });
        else{
          setState(() {
            loading = false;
            placeOrderSuccess = false;
          });
          setState(() {
            orderNotPlacedStr = value.checkout_note;
          });
        }
      }
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }
}
