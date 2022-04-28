import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/LoginPage.dart';
import 'package:catchup/pages/ProjectsListPage.dart';
import 'package:catchup/pages/introduce_page.dart';
import 'package:catchup/ui/ConnectionRefusedDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  Duration delay = Duration(seconds: 1);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool connectionError=false;
  void init() async {
    final start = DateTime.now();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool more = false;
    if(prefs.containsKey('more_time')){
      more = prefs.getBool('more_time');
    }

    if(more) {
      String token = prefs.getString('token');

      Widget homePage = LoginPage();

      if (token != null && token.isNotEmpty) {
        Global.user = await User.load();

        try {
          final profile = await Auth.profile();

          Global.profile = profile;

          // homePage = UsersListPage();
          homePage = ProjectsListPage(isAdmin: false);

          final end = DateTime.now();
          final Duration difference = end.difference(start);

          if (difference < delay) {
            delay -= difference;
          } else {
            delay = Duration.zero;
          }
        } on SocketException {

         setState(() {
           connectionError=true;
         });
          showDialog(
            context: context,
            builder: (_) => ConnectionRefusedDialog(),
          );
        } on AuthException catch (e) {

          _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
          if (e.cause == 'token unavailable') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage(),));
          }
        }
      }

      if(!connectionError)
      Future.delayed(delay, () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) => homePage,
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );

      });

    }else{

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => IntroducePage(),));
    }
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.black,
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Image.asset('assets/logo.png'),
          ),
        ),
        decoration: BoxDecoration(
        ),
      ),
    );
  }
}
