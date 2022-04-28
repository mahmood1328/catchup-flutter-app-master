import 'dart:io';

import 'package:catchup/colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    return Scaffold(
      backgroundColor: CatchupColors.black,
      appBar: AppBar(
        backgroundColor: CatchupColors.black,
        title: Text(
          'Terms of Service',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: 'https://term.chaleeetask.com',
      )
    );
  }
}
