import 'package:catchup/api/auth.dart';
import 'package:catchup/components/ensure_visible_when_focused.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/ProjectsListPage.dart';
import 'package:catchup/pages/terms_service.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/LoadingSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors.dart';
import 'dart:io';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _mobileFocus = FocusNode();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();

    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _mobileFocus.dispose();

    super.dispose();
  }

  void _signup() async {
    FocusScope.of(_scaffoldKey.currentContext).requestFocus(FocusNode());
    _scaffoldKey.currentState.hideCurrentSnackBar();

    String error = "";

    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    String mobile = _mobileController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        mobile.isEmpty) {
      error = "Please fill all fields!";
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      error = "Please enter a valid email!";
    } else if (password.length < 8) {
      error = "Password must be at least 8 characters!";
    }

    if (error.isNotEmpty) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(error));

      return;
    }

    try {
      _scaffoldKey.currentState.showSnackBar(LoadingSnackBar("Siging up..."));

      User user = await Auth.signup(User(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
      ));

      _scaffoldKey.currentState.hideCurrentSnackBar();

      if (user == null) {
        _scaffoldKey.currentState
            .showSnackBar(ErrorSnackBar("Cannot signup now. Try again later!"));

        return;
      }

      print(user);

      user = await Auth.login(User(
        email: email,
        password: password,
      ));

      user.save();

      Global.user = user;

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setBool('mark_add_task', true);
      await sharedPreferences.setBool('mark_pending_list', true);
      await sharedPreferences.setBool('mark_menu', true);
      await sharedPreferences.setBool('mark_project_admin_list', true);
      await sharedPreferences.setBool('mark_project_list', true);
      await sharedPreferences.setBool('mark_add_goal', true);
      await sharedPreferences.setBool('mark_add_project', true);

      Global.firebaseToken = await Global.firebaseMessaging.getToken();
      await Auth.updateGoogle(Global.firebaseToken);
      Navigator.pushReplacement(
        context,
        //todo project list
        MaterialPageRoute(builder: (context) => ProjectsListPage()),
      );
    } on SocketException {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.person,
                          color: CatchupColors.darkRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: EnsureVisibleWhenFocused(
                          focusNode: _firstNameFocus,
                          child: TextFormField(
                            focusNode: _firstNameFocus,
                            controller: _firstNameController,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gothic',
                              fontSize: 17,
                            ),
                            textInputAction: TextInputAction.go,
                            onEditingComplete: () {
                              _lastNameFocus.requestFocus();
                            },
                            decoration: InputDecoration(
                              hintText: 'First Name:',
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
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.person,
                          color: CatchupColors.darkRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: EnsureVisibleWhenFocused(
                          focusNode: _lastNameFocus,
                          child: TextFormField(
                            textInputAction: TextInputAction.go,
                            onEditingComplete: () {
                              _usernameFocus.requestFocus();
                            },
                            focusNode: _lastNameFocus,
                            controller: _lastNameController,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gothic',
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Last Name:',
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
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.account_circle,
                          color: CatchupColors.darkRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: EnsureVisibleWhenFocused(
                          focusNode: _usernameFocus,
                          child: TextFormField(
                            textInputAction: TextInputAction.go,
                            onEditingComplete: () {
                              _emailFocus.requestFocus();
                            },
                            focusNode: _usernameFocus,
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gothic',
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Username:',
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
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
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
                        child: EnsureVisibleWhenFocused(
                          focusNode: _emailFocus,
                          child: TextFormField(
                            textInputAction: TextInputAction.go,
                            onEditingComplete: () {
                              _passwordFocus.requestFocus();
                            },
                            focusNode: _emailFocus,
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
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.lock,
                          color: CatchupColors.darkRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: EnsureVisibleWhenFocused(
                          focusNode: _passwordFocus,
                          child: TextFormField(
                            textInputAction: TextInputAction.go,
                            onEditingComplete: () {
                              _mobileFocus.requestFocus();
                            },
                            focusNode: _passwordFocus,
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gothic',
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Password:',
                              contentPadding: const EdgeInsets.only(
                                left: 1,
                                bottom: 5,
                                right: 0,
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
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.phone_android,
                          color: CatchupColors.darkRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: EnsureVisibleWhenFocused(
                          focusNode: _mobileFocus,
                          child: TextFormField(
                            focusNode: _mobileFocus,
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gothic',
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Mobile:',
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
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Wrap(
                    direction: Axis.horizontal,
                    children: [
                      Text(
                        'Creating an account means you’re okay with our ',
                        style: TextStyle(
                          color: CatchupColors.red,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TermsService(),
                              ));
                        },
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                              color: CatchupColors.red,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
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
                          'Sign Up',
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
                  SizedBox(height: 300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
