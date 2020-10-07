import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/product_item_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

typedef VoidCallback = void Function(int);

class ProductItemWidget extends StatefulWidget {

  final String heroTag;
  final Product product;
  VoidCallback onLoadingCart;
  VoidCallback onLoadingFinishedCart;
  bool firstLoad = true;

  ProductItemWidget({Key key, this.product, this.heroTag, this.onLoadingCart, this.onLoadingFinishedCart}) : super(key: key);

  @override
  _ProductItemWidgetState createState() {
    return _ProductItemWidgetState();
  }
}

class _ProductItemWidgetState extends StateMVC<ProductItemWidget> {

  ProductItemController _con;

  _ProductItemWidgetState() : super(ProductItemController()) {
    _con = controller;

  }

  void initState() {

  }

  Future<void> afterBuild() async{
    _con.onLoadingCart = widget.onLoadingCart;
    _con.onLoadingFinishedCart = widget.onLoadingFinishedCart;
  }

  @override
  Widget build(BuildContext context) {
    //WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild);
    afterBuild();
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Product', arguments: RouteArgument(id: widget.product.id, heroTag: widget.heroTag));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: widget.heroTag + widget.product.id,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  imageUrl: widget.product.image.thumb,
                  placeholder: (context, url) => Image.asset(
                    'assets/img/loading.gif',
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.product.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Row(
                          children: Helper.getStarsList(widget.product.getRate()),
                        ),
                        Text(
                          widget.product.options.map((e) => e.name).toList().join(', '),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                _con.decrementQuantity();
                              },
                              iconSize: 30,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                              icon: Icon(Icons.remove_circle_outline),
                              color: Theme.of(context).hintColor,
                            ),
                            Text(_con.quantity.toString(), style: Theme.of(context).textTheme.subtitle1),
                            IconButton(
                              onPressed: () {
                                _con.incrementQuantity();
                              },
                              iconSize: 30,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                              icon: Icon(Icons.add_circle_outline),
                              color: Theme.of(context).hintColor,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Helper.getPrice(
                        widget.product.price,
                        context,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      widget.product.discountPrice > 0
                          ? Helper.getPrice(widget.product.discountPrice, context,
                          style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(decoration: TextDecoration.lineThrough)))
                          : SizedBox(height: 0),
                      widget.product.capacity != '' && widget.product.capacity != null && widget.product.capacity != 'null'
                          ? Text(widget.product.capacity + widget.product.unit, style: Theme.of(context).textTheme.bodyText2)
                          : SizedBox(height: 0),
                      FlatButton(
                        onPressed: () async {
                          if (currentUser.value.apiToken == null) {
                            Navigator.of(context).pushNamed("/Login");
                          } else {
                            widget.onLoadingCart(1);
                            await _con.listenForProduct(productId: widget.product.id);
                            await _con.listenForCart();
                            if (_con.isSameMarkets(_con.product)) {
                              _con.addToCart(_con.product);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AddToCartAlertDialogWidget(
                                    oldProduct: _con.carts.elementAt(0)?.product,
                                    newProduct: _con.product,
                                    onPressed: (product, {reset: true}) {
                                      return _con.addToCart(_con.product, reset: true);
                                    },
                                    onCancelled: (){
                                      widget.onLoadingFinishedCart(1);
                                    },);
                                },
                              );
                            }
                          }
                        },
                        padding: EdgeInsets.symmetric(vertical: 10),
                        color: Theme.of(context).accentColor,
                        shape: StadiumBorder(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            S.of(context).add_to_cart,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
