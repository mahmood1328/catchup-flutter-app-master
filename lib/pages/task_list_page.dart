import 'dart:io';

import 'package:catchup/api/projects.dart';
import 'package:catchup/api/auth.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/project.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/pages/GoalPageDetail.dart';
import 'package:catchup/pages/TasksListPage.dart';
import 'package:catchup/pages/acceptor_tasks_page.dart';
import 'package:catchup/ui/AddProjectDialog.dart';
import 'package:catchup/ui/AddUserDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/SearchBox.dart';
import 'package:catchup/ui/picker.dart';
import 'package:catchup/ui/user_card.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart';

class TaskListPageArchive extends StatefulWidget {
  
  final id;

  const TaskListPageArchive({
    @required this.id,
    Key key,
  }) : super(key: key);

  @override
  _ProjectsListPageState createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<TaskListPageArchive> {
  Offset position = Offset(150.0, 150.0);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _searchController = TextEditingController();

  final _listKey = GlobalKey();

  GlobalKey<CircularMenuState> key = GlobalKey<CircularMenuState>();

  GlobalKey _keyCupertino = GlobalKey();
  static final ctrl = FixedExtentScrollController();

  List<Task> _tasks;
  List<Task> _filteredTasks;

  int _selectedIndex = 0;

  void _loadProjects() async {
    try {
      List<Task> tasks = [];
      
        tasks = await Tasks.archive(widget.id);

      setState(() {
        _tasks = tasks;
        _filteredTasks = tasks;
      });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  void _openProject(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalPageDetail(task: task, isAdmin: task.createdBy == Global.user.username,isArchived: true,)
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    Global.screenSize = MediaQuery.of(context).copyWith().size;

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
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 20,
                      right: 20,
                    ),
                    child: SearchBox(
                      controller: _searchController,
                      onSearch: (text) {
                        setState(() {
                          text = text.trim().toLowerCase();

                          if (text.isEmpty) {
                            _filteredTasks = _tasks;
                            return;
                          }

                          _filteredTasks = _tasks.where((p) {
                            return p.title.toLowerCase().startsWith(text);
                          }).toList();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  key: _listKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: (_filteredTasks == null ||
                        _filteredTasks.isEmpty)
                        ? Center(
                      child: Text(
                        'No Project Found!',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gothic',
                          fontSize: 20,
                        ),
                      ),
                    )
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
                          _openProject(_tasks[_selectedIndex]);
                        }
                      },
                      child: UserPicker(
                        key: _keyCupertino,
                        scrollController: ctrl,
                        backgroundColor: Colors.transparent,
                        children: _filteredTasks.map((project) {
                          return UserCard(
                            title: project.title,
                            showAvatar: false,
                            value: project.completionPercentage / 100,
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
          MenuFloat(position: position)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }
}
