import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/maps_util.dart';
import '../helpers/helper.dart';
import '../models/address.dart' as model;
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart' as userRepo;
import '../repository/settings_repository.dart' as settingRepo;

class ConfirmAllowLocationController extends ControllerMVC {

  GlobalKey<ScaffoldState> scaffoldKey;

  String cur_location = "";
  double latitude = 0.0;
  double longitude = 0.0;


  ConfirmAllowLocationController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void onAgree(BuildContext context) async {
    OverlayEntry loader = Helper.overlayLoader(context);

    await getLocation();
    if(cur_location != null) {
      Overlay.of(context).insert(loader);
      model.Address abc = await addAddress(new model.Address.fromJSON({
        'address': cur_location,
        'latitude': latitude,
        'longitude': longitude,
      }));
      await settingRepo.changeCurrentLocation(abc);
      settingRepo.deliveryAddress.value = abc;
      settingRepo.deliveryAddress.notifyListeners();
      loader.remove();
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }
    else
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
  }

  Future<model.Address> addAddress(model.Address address) async {
    return await userRepo.addAddress(address);
  }

  Future<dynamic> getLocation() async {
    final whenDone = new Completer();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var setting = json.decode(await prefs.getString('settings'));

    var location = new Location();
    MapsUtil mapsUtil = new MapsUtil();
    if (Platform.isAndroid) {
      await location.requestService();
      try {
        LocationData abc = await location.getLocation();
        String _addressName = await mapsUtil.getAddressName(
            new LatLng(abc.latitude, abc.longitude),
            setting['google_maps_key']);
        cur_location = _addressName;
        latitude = abc.latitude;
        longitude = abc.longitude;
      } catch (e) {
        cur_location = null;
      }
      whenDone.complete();
    }  else if (Platform.isIOS) {
      bool isEnabled = await location.hasPermission() == PermissionStatus.granted;
      if (isEnabled) {
        try {
          LocationData abc = await location.getLocation();
          String _addressName = await mapsUtil.getAddressName(
              new LatLng(abc.latitude, abc.longitude),
              setting['google_maps_key']);
          cur_location = _addressName;
          latitude = abc.latitude;
          longitude = abc.longitude;
        } catch (e) {
          cur_location = null;
        }
        whenDone.complete();
      } else {
        Widget allowButton = FlatButton(
          child: Text("Allow"),
          onPressed: () {
            Navigator.of(navigatorKey.currentContext).pop();
            exit(0);
          },
        );
        AlertDialog alert = AlertDialog(
          title: Text("We would like to access your location"),
          content: Text(
              "We will capture your location and list restaurants nearby you\n Please open Settings and enable location service"),
          actions: [
            allowButton,
          ],
        );
        showDialog(
            context: navigatorKey.currentContext,
            builder: (BuildContext context) {
              return alert;
            }
        );
      }
    }
  }
}
