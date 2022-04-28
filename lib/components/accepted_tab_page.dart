
import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/picker.dart';
import 'package:catchup/ui/user_card.dart';
import 'package:flutter/material.dart';

class AcceptedTabPage extends StatefulWidget{
  @override
  _AcceptedTabPageState createState() => _AcceptedTabPageState();
}

class _AcceptedTabPageState extends State<AcceptedTabPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _listKey = GlobalKey();

  List<Task> _tasks;

 /* void _loadTasks() async {
    try {
      final tasks = await Tasks.accepted(widget.project.id);

      setState(() {
        _tasks = tasks;
      });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }*/

  int _selectedIndex = 0;

  GlobalKey _keyCupertino = GlobalKey();
  static final ctrl = FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.bgLightGray,
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
                    child: _tasks == null
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
                       //   _openTask(_tasks[_selectedIndex]);
                        }
                      },
                      child: UserPicker(
                        key: _keyCupertino,
                        scrollController: ctrl,
                        backgroundColor: Colors.transparent,
                        children: _tasks.map((task) {
                          return UserCard(
                            title: task.title,
                            imageUrl: task.acceptors.length > 0
                                ? Urls.HOST +
                                task.acceptors.first.profileImage
                                : null,
                            value: task.completionPercentage / 100,
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
          MenuFloat(position: Offset(40, 40),),
        ],
      ),
    );
  }

  _addGoal(){}

}