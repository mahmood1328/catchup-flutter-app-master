import 'dart:io';

import 'package:catchup/api/goals.dart';
import 'package:catchup/api/auth.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/goal.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/ui/AddGoalDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/picker.dart';
import 'package:catchup/ui/user_card.dart';
import 'package:flutter/material.dart';

class GoalsListPage extends StatefulWidget {
  final Task task;

  const GoalsListPage({Key key, this.task}) : super(key: key);

  @override
  _GoalsListPageState createState() => _GoalsListPageState();
}

class _GoalsListPageState extends State<GoalsListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _listKey = GlobalKey();

  List<Goal> _goals = List();

  int _selectedIndex = 0;

  void _addGoal() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddGoalDialog(
        task: widget.task,
        onGoalCreated: (Goal goal) {
          print("call me");
          setState(() {
            _goals.add(goal);
          });
        },
      ),
    );
  }

  void _loadGoals() async {
    try {
      final goals = await Goals.all(widget.task.id);

      setState(() {
        _goals = goals;
      });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  @override
  void initState() {
    super.initState();

    _loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.black,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 50,
                      right: 50,
                      top: 20,
                    ),
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
                Expanded(
                  key: _listKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _goals == null
                        ? Container()
                        : GestureDetector(
                            onTapUp: (TapUpDetails details) {
                              final x = details.globalPosition.dx;

                              final RenderBox box =
                                  _listKey.currentContext.findRenderObject();

                              final pos = box.localToGlobal(Offset.zero);
                              final size = box.size;

                              final y = details.globalPosition.dy - pos.dy;

                              final w =
                                  MediaQuery.of(context).copyWith().size.width -
                                      30;
                              final h = 104.0;

                              final yStart = (size.height - h) / 2;
                              final yEnd = (size.height + h) / 2;

                              if (x >= 30 &&
                                  x <= w &&
                                  y >= yStart &&
                                  y <= yEnd) {
                                // _openTask(_goals[_selectedIndex]);
                              }
                            },
                            child: UserPicker(
                              backgroundColor: Colors.transparent,
                              children: _goals.length == 0
                                  ? []
                                  : _goals.map((task) {
                                      return UserCard(
                                        title: task.title,
                                        value: task.completionPercentage
                                            .toDouble(),
                                        showAvatar: false,
                                      );
                                    }).toList(),
                              itemExtent: 150,
                              //height of each item
                              looping: false,
                              onSelectedItemChanged: (int index) {
                                _selectedIndex = index;
                              },
                            ),
                          ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: _addGoal,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: Text(
                        '+ Add Goal',
                        style: TextStyle(
                          color: CatchupColors.red,
                          fontFamily: 'Gothic',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
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
