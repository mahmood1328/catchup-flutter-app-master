
import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/db_controller.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/ProjectsListPage.dart';
import 'package:catchup/pages/SignUpPage.dart';
import 'package:catchup/pages/forget_password.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/LoadingSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../global.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> loginGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(LoadingSnackBar('in progress'));

    try {
      User user = await Auth.google(googleAuth.idToken);

      _scaffoldKey.currentState.hideCurrentSnackBar();

      if (user == null) {
        _scaffoldKey.currentState
            .showSnackBar(ErrorSnackBar("Cannot signup now. Try again later!"));

        return;
      }

      user.save();

      Global.user = user;
      Global.firebaseToken = await Global.firebaseMessaging.getToken();
      await Auth.updateGoogle(Global.firebaseToken);
      Navigator.pushReplacement(
        context,
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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    DBController.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _login() async {
    FocusScope.of(_scaffoldKey.currentContext).requestFocus(FocusNode());
    _scaffoldKey.currentState.hideCurrentSnackBar();

    String error = "";

    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
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
      _scaffoldKey.currentState.showSnackBar(LoadingSnackBar("Loging up..."));

      final user = await Auth.login(User(
        email: email,
        password: password,
      ));

      _scaffoldKey.currentState.hideCurrentSnackBar();

      if (user == null) {
        _scaffoldKey.currentState
            .showSnackBar(ErrorSnackBar("Cannot signup now. Try again later!"));

        return;
      }

      user.save();

      Global.user = user;

      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UsersListPage()),
      );*/

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setBool('mark_add_task', false);
      await sharedPreferences.setBool('mark_pending_list', false);
      await sharedPreferences.setBool('mark_menu', false);
      await sharedPreferences.setBool('mark_project_admin_list', false);
      await sharedPreferences.setBool('mark_project_list', false);
      await sharedPreferences.setBool('mark_add_goal', false);
      await sharedPreferences.setBool('mark_add_project', false);

      Global.firebaseToken = await Global.firebaseMessaging.getToken();
      print(Global.firebaseToken);
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

  void _openSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.black,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: ListView(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 80,
                      right: 80,
                      top: 50,
                      bottom: 50,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                    ),
                  ),
                  Platform.isIOS ?
                  SizedBox(
                    width: 250,
                    child: SignInWithAppleButton(
                      onPressed: () async {
                        final credential = await SignInWithApple.getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                        );

                        print(credential);

                        // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                        // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                      },
                    ),
                  ) :
                  GestureDetector(
                    onTap: loginGoogle,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 250, maxWidth: 250),
                      margin: const EdgeInsets.only(
                        left: 40,
                        right: 40,
                        bottom: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      decoration: BoxDecoration(
                        color: CatchupColors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Signup with Google',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gothic',
                                fontSize: 17,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  GestureDetector(
                    onTap: _openSignUpPage,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 250, maxWidth: 250),
                      margin: const EdgeInsets.only(
                        bottom: 30,
                        left: 40,
                        right: 40,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      decoration: BoxDecoration(
                        color: CatchupColors.lightGray,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.alternate_email,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Signup with Email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gothic',
                                fontSize: 17,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 30),
                Expanded(
                  child: Container(
                    height: 1,
                    color: CatchupColors.lightGray,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'OR',
                  style: TextStyle(
                    color: CatchupColors.lightGray,
                    fontFamily: 'Gothic',
                    fontSize: 17,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: CatchupColors.lightGray,
                  ),
                ),
                SizedBox(width: 30),
              ],
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
                          FontAwesomeIcons.envelope,
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
                  SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          FontAwesomeIcons.lock,
                          color: CatchupColors.darkRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
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
                  SizedBox(height: 30),
                  GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword(),));
                      },
                      child: Text(
                    'Forget Password?',
                    style: TextStyle(
                        color: CatchupColors.red,
                        decoration: TextDecoration.underline),
                  )),
                  SizedBox(height: 50),
                  InkWell(
                    onTap: _login,
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
                          'Login',
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
                ],
              ),
            ),
            SizedBox(height: 350),
          ],
        ),
      ),
    );
  }
}
