import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/project.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/pages/GoalPageDetail.dart';
import 'package:catchup/ui/AddTaskDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/picker.dart';
import 'package:catchup/ui/user_card.dart';
import 'package:flutter/material.dart';


class TasksListPage extends StatefulWidget {
  final Project project;

  const TasksListPage({Key key, this.project}) : super(key: key);

  @override
  _TasksListPageState createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _listKey = GlobalKey();

  List<Task> _tasks;

  int _selectedIndex = 0;

  GlobalKey _keyCupertino = GlobalKey();
  static final ctrl = FixedExtentScrollController();

  void _addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddTaskDialog(
        projectId: widget.project.id,
        onTaskCreated: (task) {
          setState(() {
            if (_tasks.length == 0) {
              _keyCupertino = GlobalKey();
            }

            _tasks.add(task);

            if (_tasks.length > 1) {
              ctrl.animateToItem(
                _tasks.length - 1,
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            }
          });
        },
      ),
    );
  }

  void _loadTasks() async {
    try {
      final tasks = await Tasks.all(widget.project.id);

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalPageDetail(task: task, isAdmin: Global.user.username == task.createdBy,isArchived: false,),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.black,
      body: Stack(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
                child: IconButton(icon: Icon(Icons.arrow_back_ios , color: Colors.white,size: 30,), onPressed: ()=>Navigator.pop(context))),
          ),
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
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: _addTask,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: Text(
                        '+ Add Task',
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
}
