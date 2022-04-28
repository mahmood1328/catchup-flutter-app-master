import 'package:catchup/global.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/project.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/pages/GoalPageDetail.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/picker.dart';
import 'package:catchup/ui/user_card.dart';

class AcceptedList extends StatefulWidget {

  final Project project;
  final bool admin;

  AcceptedList({this.project, this.admin});

  @override
  _TasksListPageState createState() => _TasksListPageState();
}

class _TasksListPageState extends State<AcceptedList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _listKey = GlobalKey();

  List<Task> _tasks;

  int _selectedIndex = 0;

  GlobalKey _keyCupertino = GlobalKey();
  static final ctrl = FixedExtentScrollController();


  void _loadTasks() async {
    try {
      List<Task> tasks;
      if (widget.admin) {
         tasks = await Tasks.acceptedAdmin(widget.project.id);
      }  else {
         tasks = await Tasks.accepted(widget.project.id);
      }
      if(mounted)
        setState(() {
          _tasks = tasks;
        });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  void _openTask(Task task) {
    if (task.status == 2 && !widget.admin) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar('task in pending , please wait for all acceptor'));
    }else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GoalPageDetail(
                task: task, isAdmin: task.createdBy == Global.user.username,isArchived: false,),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _loadTasks();

    Global.updateProcess.listen((event) {
      if (mounted) {
        _loadTasks();
      }
    });
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
                Expanded(
                  key: _listKey,
                  child: _tasks == null ? Center(child: CircularProgressIndicator()) : Padding(
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
                          _openTask(_tasks[_selectedIndex]);
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
              ],
            ),
          ),
          MenuFloat(position: Offset(40, 40),),
        ],
      ),
    );
  }
}