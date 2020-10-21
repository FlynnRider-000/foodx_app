import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../generated/l10n.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class MobileVerification extends StatefulWidget {
  @override
  _MobileVerificationState createState() => _MobileVerificationState();
}

class _MobileVerificationState extends State<MobileVerification> {
  String verificationId;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _ac = config.App(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: currentUser.value.phoneVerified == 1 ? AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Verification',
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ) : null,
      body: currentUser.value.phoneVerified == 1 ? Stack(
        fit: StackFit.expand,
        children: <Widget>[
        Container(
        alignment: AlignmentDirectional.center,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 70),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                                Colors.green.withOpacity(1),
                                Colors.green.withOpacity(0.2),
                              ])),
                          child: Icon(
                            Icons.done,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 90,
                          )
                      ),
                      Positioned(
                        right: -30,
                        bottom: -50,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        top: -50,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 80),
                  Text(
                    'You are already Verified!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4.merge(TextStyle(fontWeight: FontWeight.w300)),
                  ),
                ],
            ),
          ),
        ]
      ) : Padding(
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
                    'Verify Phone ',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'To place order, you have to verify your identity. \n Please input your phone number',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // DropdownButtonHideUnderline(
            //   child: Container(
            //     decoration: ShapeDecoration(
            //       shape: UnderlineInputBorder(
            //         borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
            //       ),
            //     ),
            //     child: DropdownButton(
            //       value: '+216',
            //       elevation: 9,
            //       onChanged: (value) {},
            //       items: [
            //         DropdownMenuItem(
            //           value: '+213',
            //           child: SizedBox(
            //             width: _ac.appWidth(70), // for example
            //             child: Text('(+213) - Algeria', textAlign: TextAlign.center),
            //           ),
            //         ),
            //         DropdownMenuItem(
            //           value: '+216',
            //           child: SizedBox(
            //             width: _ac.appWidth(70), // for example
            //             child: Text('(+216) - Tunisia', textAlign: TextAlign.center),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: 30),
            TextField(
              controller: _phoneNumberController,
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
                hintText: '+1 000 000 0000',
              ),
            ),
            SizedBox(height: 80),
            new BlockButtonWidget(
              onPressed: () async {
                final PhoneVerificationCompleted verificationCompleted = (user) {
                    print('Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $user');
                };

                final PhoneVerificationFailed verificationFailed = (authException) {
                    print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
                    scaffoldKey.currentState?.showSnackBar(SnackBar(
                      content: Text(authException.code)
                    ));
                };

                final PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async {
                  this.verificationId = verificationId;
                  print("code sent to " + _phoneNumberController.text);

                  Navigator.of(context).pushNamed('/MobileVerification2', arguments: RouteArgument(id: this.verificationId, heroTag: _phoneNumberController.text));
                };

                final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
                    (String verificationId) {
                  this.verificationId = verificationId;
                  print("time out");
                };

                if (_phoneNumberController.text != '') {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: _phoneNumberController.text,
                      timeout: const Duration(seconds: 5),
                      verificationCompleted: verificationCompleted,
                      verificationFailed: verificationFailed,
                      codeSent: codeSent,
                      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
                }
              },
              color: Theme.of(context).accentColor,
              text: Text(S.of(context).submit.toUpperCase(),
                  style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Theme.of(context).primaryColor))),
            ),
          ],
        ),
      ),
    );
  }
}
