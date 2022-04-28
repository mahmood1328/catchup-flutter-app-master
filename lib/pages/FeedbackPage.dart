import 'dart:math' as math;

import 'package:catchup/components/menu_float.dart';
import 'package:catchup/ui/FeedbackItemResult.dart';
import 'package:catchup/ui/MyCircularPercentIndicator.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
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
      backgroundColor: CatchupColors.black,
      body: Stack(
        children : [
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
                      value: 0.86,
                      strokeWidth: 7,
                      valueColor: AlwaysStoppedAnimation<Color>(_getColor(0.86)),
                    ),
                  ),
                  Transform.rotate(
                    angle: 2 * math.pi * (0.86 + 0.03),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: MyCircularProgressIndicator(
                        value: math.max(0, (1 - 0.86) - 0.06),
                        strokeWidth: 7,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xff949595)),
                      ),
                    ),
                  ),
                  Text(
                    '${86}%',
                    style: TextStyle(
                      color: _getColor(0.86),
                      fontFamily: 'Gothic',
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Container(
                        height: 4,
                        color: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Gothic',
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: CatchupColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Gothic',
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: CatchupColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Gothic',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: CatchupColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                '4',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Gothic',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: CatchupColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                '5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Gothic',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: CatchupColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              FeedbackItemResult(
                title: 'Team Managment',
                star: 1,
              ),
              FeedbackItemResult(
                title: 'Efficiency',
                star: 3,
              ),
              FeedbackItemResult(
                title: 'Task Delegation',
                star: 4,
              ),
              FeedbackItemResult(
                title: 'Follow-up',
                star: 5,
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/profile.jpg'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    Expanded(
                      child: Text(
                        'Some text here. This is a test text. Hello world!',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gothic',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
          MenuFloat(position: Offset(40, 40),),
        ]
      ),
    );
  }
}
