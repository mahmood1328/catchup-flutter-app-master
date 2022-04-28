import 'dart:math' as math;

import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/project.dart';
import 'package:catchup/ui/MyCircularPercentIndicator.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import 'TasksListPage.dart';

class SingleProjectPage extends StatefulWidget {
  final Project project;

  const SingleProjectPage({Key key, this.project}) : super(key: key);

  @override
  _SingleProjectPageState createState() => _SingleProjectPageState();
}

class _SingleProjectPageState extends State<SingleProjectPage> {
  double _percentage = 0.61;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _loadInfo() {
    setState(() {
      _percentage = widget.project.completionPercentage / 100;
    });
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

  void _openTasksList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasksListPage(
          project: widget.project,
        ),
      ),
    );
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
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: _openTasksList,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, top: 10),
                      child: Text(
                        'Tasks',
                        style: TextStyle(
                          color: CatchupColors.red,
                          fontFamily: 'Gothic',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: MyCircularProgressIndicator(
                        value: _percentage,
                        strokeWidth: 7,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _getColor(_percentage)),
                      ),
                    ),
                    Transform.rotate(
                      angle: 2 * math.pi * (_percentage + 0.03),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: MyCircularProgressIndicator(
                          value: math.max(0, (1 - _percentage) - 0.06),
                          strokeWidth: 7,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xff949595)),
                        ),
                      ),
                    ),
                    Text(
                      '${(_percentage * 100).toInt()}%',
                      style: TextStyle(
                        color: _getColor(_percentage),
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
                          margin: const EdgeInsets.only(
                            bottom: 15,
                            left: 15,
                            right: 15,
                          ),
                          height: 4,
                          color: Colors.white,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Center(
                                    child: Text(
                                      '1',
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
                                SizedBox(height: 5),
                                Text(
                                  '2020/1/15',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gothic',
                                    fontSize: 10,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Center(
                                    child: Text(
                                      '2',
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
                                SizedBox(height: 5),
                                Text(
                                  '2020/1/24',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gothic',
                                    fontSize: 10,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
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
                                SizedBox(height: 5),
                                Text(
                                  '2020/2/13',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gothic',
                                    fontSize: 10,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
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
                                SizedBox(height: 5),
                                Text(
                                  '2020/2/19',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gothic',
                                    fontSize: 10,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
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
                                SizedBox(height: 5),
                                Text(
                                  '2020/2/29',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gothic',
                                    fontSize: 10,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

  @override
  void initState() {
    super.initState();

    _loadInfo();
  }
}
