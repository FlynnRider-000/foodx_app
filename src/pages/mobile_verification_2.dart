import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../generated/l10n.dart';
import '../repository/user_repository.dart' as repository;
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../models/route_argument.dart';
import '../models/user.dart' as UserModel;

class MobileVerification2 extends StatefulWidget {
  RouteArgument routeArgument;

  MobileVerification2({
    Key key,
    this.routeArgument
  }) : super(key: key);

  @override
  _MobileVerification2State createState() => _MobileVerification2State();
}

class _MobileVerification2State extends State<MobileVerification2> {
  TextEditingController _smsCodeController = TextEditingController();
  bool isVerifying  = false;
  bool isVerified = false;

  @override
  Widget build(BuildContext context) {
    final _ac = config.App(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _ac.appWidth(100),
              child: Column(
                children: <Widget>[
                  Text(
                    'Verify Your Account',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'We are sending OTP to validate your mobile number. Hang on!',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            TextField(
              controller: _smsCodeController,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
              decoration: new InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                ),
                focusedBorder: new UnderlineInputBorder(
                  borderSide: new BorderSide(
                    color: Theme.of(context).focusColor.withOpacity(0.5),
                  ),
                ),
                hintText: '000000',
              ),
            ),
            SizedBox(height: 15),
            Text(
              'SMS has been sent to ' + this.widget.routeArgument.heroTag,
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            isVerifying ? SpinKitCircle(
              color: Colors.white70,
              size: 40.0,
            ) : SizedBox(height: 40),
            SizedBox(height: 30),
            new BlockButtonWidget(
              onPressed: () async {
                if (isVerified) {
                  Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                  return;
                }
                if (_smsCodeController.text != '' && !isVerified) {
                  setState(() {
                    isVerifying = true;
                  });
                  final AuthCredential credential = PhoneAuthProvider.getCredential(
                    verificationId: this.widget.routeArgument.id,
                    smsCode: _smsCodeController.text,
                  );
                  FirebaseAuth _auth = FirebaseAuth.instance;
                  try {
                    final UserCredential user = await _auth
                        .signInWithCredential(credential);
                    final User currentUser = await _auth.currentUser;
                    if (user.user.uid == currentUser.uid) {
                      UserModel.User usr = repository.currentUser.value;
                      usr.phoneVerified = 1;
                      usr.phone = this.widget.routeArgument.heroTag;
                      usr.deviceToken = null;
                      repository.update(usr);
                      setState(() {
                        isVerifying = false;
                        isVerified = true;
                      });
                    }
                  } catch (error) {
                    setState(() {
                      isVerifying = false;
                    });
                  }
                }
              },
              color: Theme.of(context).accentColor,
              text: Text(isVerified ? 'Done' : S.of(context).verify.toUpperCase(),
                  style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Theme.of(context).primaryColor))),
            ),
          ],
        ),
      ),
    );
  }
}
