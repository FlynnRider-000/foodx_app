import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../generated/l10n.dart';
import '../controllers/market_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ProductItemATCWidget.dart';
import '../elements/ProductsCarouselWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  MenuWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);
}

class _MenuWidgetState extends StateMVC<MenuWidget> {
  MarketController _con;
  List<String> selectedCategories;

  _MenuWidgetState() : super(MarketController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.market = widget.routeArgument.param as Market;
    _con.listenForTrendingProducts(_con.market.id);
    _con.listenForCategories(isFirst: 1);
    selectedCategories = [];
    /*
    _con.listenForProducts(widget.routeArgument.id);
    */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.of(context).pushNamed('/Details', arguments: RouteArgument(id: '0', param: _con.market.id, heroTag: 'menu_tab')),
        ),
        title: Text(
          _con.market?.name ?? '',
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 0)),
        ),
        actions: <Widget>[
          _con.loadCart
              ? SizedBox(
            width: 60,
            height: 60,
            child: RefreshProgressIndicator(),
          )
              : new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Icon(
                Icons.bookmark,
                color: Theme.of(context).hintColor,
              ),
              title: Text(
                S.of(context).featured_products,
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                maxLines: 2,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            ProductsCarouselWidget(heroTag: 'menu_trending_product', productsList: _con.trendingProducts),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Icon(
                Icons.subject,
                color: Theme.of(context).hintColor,
              ),
              title: Text(
                S.of(context).products,
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                maxLines: 2,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            _con.market_categories.isEmpty
                ? SizedBox(height: 90)
                : Container(
              height: 90,
              child: ListView(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: List.generate(_con.market_categories.length, (index) {
                  var _category = _con.market_categories.elementAt(index);
                  var _selected = this.selectedCategories.contains(_category.id);
                  if(this.selectedCategories.length == 0 && index == 0) {
                    this.selectedCategories.add(_category.id);
                    _selected = true;
                  }
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(start: 20),
                    child: RawChip(
                      elevation: 0,
                      label: Text(_category.name),
                      labelStyle: _selected
                          ? Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Theme.of(context).primaryColor))
                          : Theme.of(context).textTheme.bodyText2,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      backgroundColor: Theme.of(context).focusColor.withOpacity(0.1),
                      selectedColor: Theme.of(context).accentColor,
                      selected: _selected,
                      //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                      showCheckmark: false,
                      avatar: (_category.id == '0')
                          ? null
                          : (_category.image.url.toLowerCase().endsWith('.svg')
                          ? SvgPicture.network(
                        _category.image.url,
                        color: _selected ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
                      )
                          : CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: _category.image.icon,
                        placeholder: (context, url) => Image.asset(
                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )),
                      onSelected: (bool value) {
                        setState(() {
//                                if (_category.id == '0') {
//                                  this.selectedCategories = ['0'];
//                                } else {
//                                  this.selectedCategories.removeWhere((element) => element == '0');
//                                }
//                                if (value) {
//                                  this.selectedCategories.add(_category.id);
//                                } else {
//                                  this.selectedCategories.removeWhere((element) => element == _category.id);
//                                }
                          this.selectedCategories.clear();
                          this.selectedCategories.add(_category.id);
                          _con.selectCategory(this.selectedCategories);
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            _con.products.isEmpty
                ? CircularLoadingWidget(height: 250)
                : ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: _con.products.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return ProductItemWidget(
                    heroTag: 'menu_list',
                    product: _con.products.elementAt(index),
                    onLoadingCart: (value) {if(value == 1) { _con.loadingCart();}},
                    onLoadingFinishedCart: (value) {if(value == 1) { _con.loadingFinishedCart();}}
                );
              },
            ),
            _con.stillLoading
              ? Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SpinKitThreeBounce(
                  color: Theme.of(context).accentColor,
                  size: 25.0,
                )
              )
              : Container()
          ],
        ),
      ),
    );
  }
}
