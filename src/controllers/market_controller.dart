import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/category.dart';
import '../models/gallery.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';

class MarketController extends ControllerMVC {
  Market market;
  List<Gallery> galleries = <Gallery>[];
  List<Product> products = <Product>[];
  List<Category> categories = <Category>[];
  List<Product> trendingProducts = <Product>[];
  List<Product> featuredProducts = <Product>[];
  List<Category> market_categories = <Category>[];
  List<Review> reviews = <Review>[];
  bool loadCart = false;
  GlobalKey<ScaffoldState> scaffoldKey;
  bool stillLoading = false;

  MarketController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<dynamic> listenForMarket({String id, String message}) async {
    final whenDone = new Completer();
    final Stream<Market> stream = await getMarket(id, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => market = _market);
      return whenDone.complete(_market);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
      return whenDone.complete(Market.fromJSON({}));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
        return whenDone.complete(market);
      }
    });
    return whenDone.future;
  }

  void listenForGalleries(String idMarket) async {
    final Stream<Gallery> stream = await getGalleries(idMarket);
    stream.listen((Gallery _gallery) {
      setState(() => galleries.add(_gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForMarketCategories(String id, {int isFirst = 0}) async {
    final Stream<Market> stream = await getMarket(id, deliveryAddress.value);
    stream.listen((Market _market) {

      List<Category> mark_ctr = categories.where((element) => _market.categories.contains(element.id)).toList();
      /*if(categories.length > 0)
        mark_ctr.insert(0, categories[0]);*/
      setState(() {
        market_categories = mark_ctr;
      });
      if(isFirst == 1){
        List<String> selCategories = [market_categories.elementAt(0).id];
        listenForProducts(market.id, categoriesId: selCategories);
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
    });
  }

  void listenForMarketReviews({String id, String message}) async {
    final Stream<Review> stream = await getMarketReviews(id);
    stream.listen((Review _review) {
      setState(() => reviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForProducts(String idMarket, {List<String> categoriesId}) async{
    int isLoading = 0;
    int limit = 25;
    for( int offset = 0 ; offset < 1000 ; offset += limit ) {
      if ( isLoading == 0) {
        int readCnt = 0;
        final Stream<Product> stream = await getProductsOfMarketSuper(
            idMarket, limit, offset, categories: categoriesId);
        stream.listen((Product _product) {
          setState(() {
            products.add(_product);
            readCnt++;
          });
        }, onError: (a) {
          print(a);
        }, onDone: () {
          market.name = products
              ?.elementAt(0)
              ?.market
              ?.name;
          if (readCnt == 0) {
            setState(() {
              stillLoading = false;
            });
            isLoading = 1;
          }
          else {
            setState(() {
              stillLoading = true;
            });
          }
        });
      }
    }
  }

  void listenForTrendingProducts(String idMarket) async {
    final Stream<Product> stream = await getTrendingProductsOfMarket(idMarket);
    stream.listen((Product _product) {
      setState(() => trendingProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

   void listenForFeaturedProducts(String idMarket) async {
    final Stream<Product> stream = await getFeaturedProductsOfMarket(idMarket);
    stream.listen((Product _product) {
      setState(() => featuredProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories({int isFirst = 0}) async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      categories.insert(0, new Category.fromJSON({'id': '0', 'name': S.of(context).all}));
      listenForMarketCategories(market.id, isFirst: isFirst);
    });
  }

  Future<void> selectCategory(List<String> categoriesId) async {
    products.clear();
    listenForProducts(market.id, categoriesId: categoriesId);
  }

  Future<void> refreshMarket() async {
    var _id = market.id;
    market = new Market();
    galleries.clear();
    reviews.clear();
    featuredProducts.clear();
    market_categories.clear();
    listenForMarket(id: _id, message: S.of(context).market_refreshed_successfuly);
    listenForMarketReviews(id: _id);
    listenForGalleries(_id);
    listenForFeaturedProducts(_id);
  }

  void loadingCart() {
    setState(() {
      this.loadCart = true;
    });
  }

  void loadingFinishedCart() {
    setState(() {
      this.loadCart = false;
    });
  }
}
