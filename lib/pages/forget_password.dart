import 'package:catchup/api/auth.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/LoadingSnackBar.dart';
import 'package:catchup/ui/SuccessSnackBar.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import 'dart:io';

class ForgetPassword extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<ForgetPassword> {
  final _emailController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  void _signup() async {
    _scaffoldKey.currentState.hideCurrentSnackBar();

    String error = "";

    final String email = _emailController.text;

    if (email.isEmpty) {
      error = "Please fill all fields!";
    } else if (!RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      error = "Please enter a valid email!";
    }

    if (error.isNotEmpty) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(error));

      return;
    }

    try {
      _scaffoldKey.currentState.showSnackBar(LoadingSnackBar("please wait..."));

      final bool = await Auth.forgetPassword(email: email,);

      _scaffoldKey.currentState.hideCurrentSnackBar();

      if (bool == null || !bool ) {
        _scaffoldKey.currentState
            .showSnackBar(ErrorSnackBar("server busy now. Try again later!"));

        return;
      };

      _scaffoldKey.currentState
          .showSnackBar(SuccessSnackBar("You have successfully signed up."));

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(_scaffoldKey.currentContext);
      });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: CatchupColors.black,
      body: Container(
        child: ListView(
          children: <Widget>[
            SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 80,
                      right: 80,
                      top: 50,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                left: 40,
                right: 40,
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: (MediaQuery.of(context).size.height / 3) - 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.alternate_email,
                          color: CatchupColors.darkRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gothic',
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email:',
                            contentPadding: const EdgeInsets.only(
                              left: 1,
                              bottom: 0,
                              right: 1,
                            ),
                            hintStyle: TextStyle(
                              color: CatchupColors.lightGray,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: CatchupColors.lightGray,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: CatchupColors.gray,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: CatchupColors.lightGray,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _signup,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        color: CatchupColors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          'Reset',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gothic',
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

