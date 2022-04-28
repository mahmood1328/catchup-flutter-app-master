import 'package:catchup/api/auth.dart';
import 'package:catchup/api/profile.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/components/text_box.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/FeedBackProfilePage.dart';
import 'package:catchup/pages/LoginPage.dart';
import 'package:catchup/pages/terms_service.dart';
import 'package:catchup/ui/LoadingSnackBar.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  User user;

  File select;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  getData() async {
    user = await Profile.getUser();
    setState(() {
      controllerName.text = user.firstName;
      controllerEmail.text = user.email;
      controllerPassword.text = user.password;
      controllerUserName.text = user.username;
    });
  }

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerUserName = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Profile.setProfile(
            name: controllerName.text,
            email: controllerEmail.text,
            pass: controllerPassword.text);
        return true;
      },
      child: Scaffold(
        key: _globalKey,
        backgroundColor: Color(0xff211f20),
        body: Stack(
          children: [
            user == null
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(bottom: 45),
                              padding: const EdgeInsets.all(20),
                              color: CatchupColors.red,
                              constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height *
                                          0.45),
                              child: Center(
                                child: SafeArea(
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              spreadRadius: 10,
                                              blurRadius: 25,
                                              offset: Offset.zero,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: user != null
                                              ? Image.network(
                                                  Urls.HOST + user.profileImage,
                                                  width: 150,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  'assets/profile.jpg',
                                                  width: 150,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 5,
                                        bottom: 10,
                                        child: GestureDetector(
                                          onTap: () async {
                                            select = await FilePicker.getFile();
                                            if (select != null) {
                                              _globalKey.currentState
                                                  .showSnackBar(LoadingSnackBar(
                                                      'in progress... please wait'));
                                              await Profile.setImageProfile(
                                                  select);
                                              _globalKey.currentState
                                                  .hideCurrentSnackBar();
                                              getData();
                                            }
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                FontAwesomeIcons.pencilAlt,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 30,
                              right: 30,
                              child: GestureDetector(
                                onTap: () {
                                  Profile.setProfile(
                                      name: controllerName.text,
                                      email: controllerEmail.text,
                                      pass: controllerPassword.text);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FeedBackProfilePage(username: Global.user.username,),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: CatchupColors.red,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 15,
                                        offset: Offset.zero,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.insert_chart,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'View Project Score',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gothic',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: SafeArea(
                                child: GestureDetector(
                                  onTap: () {
                                    Profile.setProfile(
                                        name: controllerName.text,
                                        email: controllerEmail.text,
                                        pass: controllerPassword.text);
                                    Navigator.of(context).pop();
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: SafeArea(
                                child: GestureDetector(
                                  onTap: () async{
                                   await Auth.logOut();
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage(),), (route) => false);
                                  },
                                  child: Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: <Widget>[
                              GrayTextBox(
                                //      initialValue: user != null ? user.firstName :  '-',
                                hint: 'Your Name',
                                textAlign: TextAlign.center,
                                controller: controllerName,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  size: 25,
                                  color: CatchupColors.lightGray,
                                ),
                              ),
                              SizedBox(height: 40),
                              GrayTextBox(
                                //      initialValue: user != null ? user.firstName :  '-',
                                hint: 'Your User Name',
                                textAlign: TextAlign.center,
                                readOnly: true,
                                controller: controllerUserName,
                                prefixIcon: Icon(
                                  Icons.account_circle,
                                  size: 25,
                                  color: CatchupColors.lightGray,
                                ),
                              ),
                              SizedBox(height: 40),
                              GrayTextBox(
                                // initialValue:  user.email,
                                hint: 'Your Email',
                                textAlign: TextAlign.center,
                                controller: controllerEmail,
                                prefixIcon: Icon(
                                  Icons.email,
                                  size: 25,
                                  color: CatchupColors.lightGray,
                                ),
                              ),
                              SizedBox(height: 40),
                              GrayTextBox(
                                //    initialValue: user != null ? user.password :  '-',
                                hint: 'Your Password',
                                controller: controllerPassword,
                                textAlign: TextAlign.center,
                                //   readOnly: true,
                                obscureText: true,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 25,
                                  color: CatchupColors.lightGray,
                                ),
                              ),
                              SizedBox(height: 40),
                              GrayTextBox(
                                initialValue: user.score.toString(),
                                hint: 'Your Rank',
                                textAlign: TextAlign.center,
                                textColor: CatchupColors.red,
                                readOnly: true,
                                prefixIcon: Icon(
                                  Icons.star,
                                  size: 25,
                                  color: CatchupColors.lightGray,
                                ),
                              ),
                              SizedBox(height: 40),
                              GrayTextBox(
                                initialValue: '3',
                                hint: 'Your Accounts Count',
                                textAlign: TextAlign.center,
                                textColor: CatchupColors.red,
                                readOnly: true,
                                prefixIcon: Icon(
                                  Icons.person,
                                  size: 25,
                                  color: CatchupColors.lightGray,
                                ),
                              ),
                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: CatchupColors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 15,
                                      offset: Offset.zero,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    FontAwesomeIcons.question,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TermsService(),
                                          ));
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 110,
                                      decoration: BoxDecoration(
                                        color: CatchupColors.red,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            spreadRadius: 3,
                                            blurRadius: 15,
                                            offset: Offset.zero,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Terms of service ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Gothic',
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,

                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: (){
                                      if (Platform.isAndroid) {
                                        // Android-specific code
                                      } else if (Platform.isIOS) {
                                        // iOS-specific code
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 110,
                                      decoration: BoxDecoration(
                                        color: CatchupColors.red,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            spreadRadius: 3,
                                            blurRadius: 15,
                                            offset: Offset.zero,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Share App',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Gothic',
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
            MenuFloat(
              position: Offset(40, 40),
            ),
          ],
        ),
      ),
    );
  }
}
