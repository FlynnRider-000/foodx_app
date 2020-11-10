import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:io' show Platform;

import '../controllers/confirm_allow_location_controller.dart';
import '../../generated/l10n.dart';

class ConfirmAllowLocationWidget extends StatefulWidget {

  ConfirmAllowLocationWidget({Key key}) : super(key: key);

  @override
  _ConfirmAllowLocationState createState() => _ConfirmAllowLocationState();
}

class _ConfirmAllowLocationState extends StateMVC<ConfirmAllowLocationWidget> with WidgetsBindingObserver {

  ConfirmAllowLocationController _con;

  _ConfirmAllowLocationState() : super(ConfirmAllowLocationController()) {
    _con = controller;
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (Platform.isIOS && _con.settingOpened) {
      _con.settingOpened = false;
      if (state == AppLifecycleState.resumed) {
        await _con.onAgree(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(S.of(context).alert),
        content: Text(S.of(context).capture_location_help),
        actions: <Widget>[
          MaterialButton(
            child: Text(S.of(context).yes),
            onPressed: () async {
              //Put your code here which you want to execute on Yes button click.
              await _con.onAgree(context);
            },
          ),

          MaterialButton(
            child: Text(S.of(context).no),
            onPressed: () {
              //Put your code here which you want to execute on No button click.
              Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
            },
          )
        ]
    );
  }
}
