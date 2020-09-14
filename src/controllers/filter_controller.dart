import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/field.dart';
import '../models/filter.dart';
import '../repository/field_repository.dart';

class FilterController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  List<Field> fields = [];
  Filter filter;
  Cart cart;

  FilterController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForFilter().whenComplete(() {
      listenForFields();
    });
  }

  Future<void> listenForFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
    });
  }

  Future<void> saveFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filter.fields = this.fields.where((_f) => _f.selected).toList();
    prefs.setString('filter', json.encode(filter.toMap()));
  }

  void listenForFields({String message}) async {
    final Stream<Field> stream = await getFields();
    int index = 0;
    stream.listen((Field _field) {
      setState(() {
        if (filter.fields.contains(_field) ||
            filter.fields.length == 0 && index == 0) {
          _field.selected = true;
        }
        fields.add(_field);
        index++;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshFields() async {
    fields.clear();
    listenForFields(message: S.of(context).addresses_refreshed_successfuly);
  }

  void onChangeFieldsFilter(int index) {
    setState(() {
      for(int i = 0 ; i < fields.length; i++ ){
        fields[i].selected = false;
      }
      fields.elementAt(index).selected = true;
    });
  }
}
