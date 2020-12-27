import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/razorpay_controller.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class RazorPayPaymentWidget extends StatefulWidget {
  RouteArgument routeArgument;

  RazorPayPaymentWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _RazorPayPaymentWidgetState createState() => _RazorPayPaymentWidgetState();
}

class _RazorPayPaymentWidgetState extends StateMVC<RazorPayPaymentWidget> {
  RazorPayController _con;

  _RazorPayPaymentWidgetState() : super(RazorPayController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).razorpayPayment,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        children: <Widget>[
          InAppWebView(
            initialUrl: _con.url,
            initialHeaders: {},
            initialOptions: Platform.isAndroid ? new InAppWebViewGroupOptions(android: new AndroidInAppWebViewOptions(textZoom: 120)) : new InAppWebViewGroupOptions(),
            onWebViewCreated: (InAppWebViewController controller) {
              _con.webView = controller;
            },
            onLoadStart: (InAppWebViewController controller, String url) {
              setState(() {
                _con.url = url;
              });
              if (url == "${GlobalConfiguration().getString('base_url')}payments/razorpay") {
                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 3);
              }
            },
            onProgressChanged: (InAppWebViewController controller, int progress) {
              setState(() {
                _con.progress = progress / 100;
              });
              controller.getUrl().then((value) {
                if (Platform.isIOS) {
                  String url = value;
                  if (url == "${GlobalConfiguration().getString('base_url')}payments/razorpay" && progress == 100) {
                    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 3);
                    return;
                  }
                }
                if(value.contains("payments.failed")) {
                  var res = value.split("payments.failed");
                  if(res.length > 1) {
                    var resString = res[1].split(",");
                    String toastStr = "";
                    toastStr += "Store is closed now.\n\n";
                    if(resString[1] != 'null')
                      toastStr += "Market Open Time : " + resString[1] + "\n";
                    if(resString[2] != 'null')
                      toastStr += "Market Close Time : " + resString[2] + "\n";
                    toastStr += "Current Time : " + resString[3] + "\n";
                    Navigator.of(context).pushReplacementNamed('/RazorPayFailed', arguments: toastStr);
                  }
                }
              });
            },
          ),
          _con.progress < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _con.progress,
                    backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
