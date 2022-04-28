import 'dart:io';
import 'dart:math' as math;

import 'package:catchup/api/auth.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/models/user_profile.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/FeedbackItemResult.dart';
import 'package:catchup/ui/MyCircularPercentIndicator.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  UserProfile _userProfile = UserProfile();

  @override
  void initState() {
    super.initState();

    _loadProfileInfo();
  }

  void _loadProfileInfo() async {
    // _scaffoldKey.currentState.hideCurrentSnackBar();

    try {
      final Map userDetails =
          await Auth.profile(username: widget.user.username);

      setState(() {
        _userProfile = UserProfile.fromJson(userDetails['user_profile']);
      });
    } on SocketException {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.hideCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  Color _getColor(double percent) {
    if (percent <= 0.25) {
      return CatchupColors.red;
    }

    if (percent <= 0.5) {
      return Color(0xffdf4900);
    }

    if (percent <= 0.75) {
      return Color(0xfffebd00);
    }

    return Color(0xff01c501);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.black,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              children: <Widget>[
                SizedBox(height: 25),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: MyCircularProgressIndicator(
                        value: _userProfile.overallScore / 100,
                        strokeWidth: 7,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_getColor(0.86)),
                      ),
                    ),
                    Transform.rotate(
                      angle: 2 *
                          math.pi *
                          (_userProfile.overallScore / 100 + 0.03),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: MyCircularProgressIndicator(
                          value: math.max(
                              0, (1 - _userProfile.overallScore / 100) - 0.06),
                          strokeWidth: 7,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xff949595)),
                        ),
                      ),
                    ),
                    Text(
                      '${_userProfile.overallScore}%',
                      style: TextStyle(
                        color: _getColor(_userProfile.overallScore / 100),
                        fontFamily: 'Gothic',
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                FeedbackItemResult(
                  title: 'Tasks Done Counter',
                  star: _userProfile.tasksDoneCounterStar,
                ),
                FeedbackItemResult(
                  title: 'Time Managment',
                  star: _userProfile.timeManagementStar,
                ),
                FeedbackItemResult(
                  title: 'Efficiency',
                  star: _userProfile.efficiencyStar,
                ),
                FeedbackItemResult(
                  title: 'Task Delegation',
                  star: _userProfile.taskDelegationStar,
                ),
                FeedbackItemResult(
                  title: 'Follow-up',
                  star: _userProfile.followUpStar,
                ),
                FeedbackItemResult(
                  title: 'Report Updates',
                  star: _userProfile.reportUpdatesStar,
                ),
                FeedbackItemResult(
                  title: 'Task Completion',
                  star: _userProfile.taskCompletionStar,
                ),
                FeedbackItemResult(
                  title: 'Work Quality',
                  star: _userProfile.workQualityStar,
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
          MenuFloat(
            position: Offset(40, 40),
          ),
        ],
      ),
    );
  }
}
