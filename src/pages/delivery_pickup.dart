import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sprintf/sprintf.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';


import '../repository/user_repository.dart';

class DeliveryPickupWidget extends StatefulWidget {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final RouteArgument routeArgument;

  DeliveryPickupWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {

  DeliveryPickupController _con;

  int vis = 0;


  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
    _con.parentWidgetType = 1;
  }

  @override
  Widget build(BuildContext context) {
    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
//      widget.pickup = widget.list.pickupList.elementAt(0);
//      widget.delivery = widget.list.pickupList.elementAt(1);
    }
    if(_con.carts.length == 0) {
      _con.refreshCarts(showToast:0);
    }
    if(_con.carts.length > 0 && vis == 0) {
      vis = 1;
      double sum = 0;
      int limit = _con.carts[0].product.market.mini_order;
      for(int i = 0 ; i < _con.carts.length ;i++)
        sum += _con.carts[i].product.price * _con.carts[i].quantity;

      if (_con.carts[0].product.market.shipping_method == 0) {//FreeShipping
        if(_con.carts[0].product.market.free_shipping == false && sum < limit) {
          _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(
              content: Text(sprintf(S.of(context).market_minimum_order, [limit,  _con.carts[0].product.market.deliveryFee]))
          ));
        }
      }

      if(_con.carts[0].product.market.shipping_method == 1) { //LimitedShipping
        if(sum < limit && _con.carts[0].product.market.limited_shipping == false) {
          _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(
              content: Text(sprintf(S.of(context).market_minimum_order, [limit,  _con.carts[0].product.market.deliveryFee]))
          ));
        }
      }
    }

    return Scaffold(
      key: _con.scaffoldKey,
      bottomNavigationBar: CartBottomDetailsWidget(con: _con),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery_or_pickup,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: (_con.carts.length > 0 && _con.carts[0].product.market.pay_on_pickup) ? ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.domain,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  S.of(context).pickup,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline4,
                ),
                subtitle: Text(
                  S.of(context).pickup_your_product_from_the_market,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              ):
              Container(),
            ),
            (_con.carts.length > 0 && _con.carts[0].product.market.pay_on_pickup) ? PickUpMethodItem(
                paymentMethod: _con.getPickUpMethod(),
                onPressed: (paymentMethod) {
                  _con.togglePickUp();
                }
            ):
            Container(),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.map,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).delivery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: _con.carts.isNotEmpty && Helper.canDelivery(_con.carts[0].product.market, carts: _con.carts)
                        ? Text(
                      S.of(context).click_to_confirm_your_address_and_pay_or_long_press,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    )
                        : Text(
                      S.of(context).deliveryMethodNotAllowed,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
                _con.carts.isNotEmpty && Helper.canDelivery(_con.carts[0].product.market, carts: _con.carts)
                    ? Container(
                    child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          DeliveryAddressesItemWidget(
                            paymentMethod: _con.getDeliveryMethod(),
                            address: _con.deliveryAddress,
                            onPressed: (Address _address) {
                              if (_con.deliveryAddress.id == null || _con.deliveryAddress.id == 'null') {
                                DeliveryAddressDialog(
                                  context: context,
                                  address: _address,
                                  onChanged: (Address _address) {
                                    _con.addAddress(_address);
                                  },
                                );
                              } else {
                                _con.toggleDelivery();
                              }
                            },
                            onLongPress: (Address _address) {
                              DeliveryAddressDialog(
                                context: context,
                                address: _address,
                                onChanged: (Address _address) {
                                  _con.updateAddress(_address);
                                },
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              if (currentUser.value.apiToken != null) {
                                var bottomSheetController = _con.scaffoldKey.currentState.showBottomSheet(
                                      (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: _con.scaffoldKey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                  ),
                                );
                                bottomSheetController.closed.then((value) {
                                  _con.addressUpdated(context);
                                });
                              }
                            },
                            icon: Icon(
                              Icons.my_location,
                              color: Theme.of(context).hintColor,
                            ),
                          )
                        ]
                    )
                )
                    : NotDeliverableAddressesItemWidget(),
                Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.note_add,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).add_note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                        S.of(context).add_note_helper,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child:TextField(
                      controller: _con.check_note,
                      maxLines: 8,
                      minLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '',
                        contentPadding:
                        const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
