import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:io' show Platform;

import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart' as userRepo;
import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> with WidgetsBindingObserver {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadData();
    userRepo.getCurrentUser();
  }

  void loadData() {
    _con.progress.addListener(() async {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        await settingsRepo.getCurrentLocationOnOpenApp();
        try {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
        } catch (e) {}
      }
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (Platform.isIOS && settingsRepo.settingOpened) {
      if (state == AppLifecycleState.resumed) {
        settingsRepo.settingOpened = false;
        Navigator.of(context).pop();
        await settingsRepo.getCurrentLocationOnOpenApp();
        try {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
        } catch (e) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/img/logo.png',
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
