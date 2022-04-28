import 'dart:io';

import 'package:catchup/api/projects.dart';
import 'package:catchup/api/auth.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/models/project.dart';
import 'package:catchup/pages/acceptor_tasks_page.dart';
import 'package:catchup/pages/task_list_page.dart';
import 'package:catchup/ui/AddProjectDialog.dart';
import 'package:catchup/ui/AddUserDialog.dart';
import 'package:catchup/ui/DeleteDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/SearchBox.dart';
import 'package:catchup/ui/picker.dart';
import 'package:catchup/ui/user_card.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../global.dart';

class ProjectsListPage extends StatefulWidget {
  final bool createNew;
  final bool isAdmin;
  final bool archive;

  const ProjectsListPage({
    Key key,
    this.createNew = false,
    this.isAdmin = false,
    this.archive = false,
  }) : super(key: key);

  @override
  _ProjectsListPageState createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  Offset position = Offset(150.0, 150.0);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _searchController = TextEditingController();

  final _listKey = GlobalKey();

  GlobalKey<CircularMenuState> key = GlobalKey<CircularMenuState>();

  GlobalKey _keyCupertino = GlobalKey();
  static final ctrl = FixedExtentScrollController();

  List<Project> _projects;
  List<Project> _filteredProjects;

  int _selectedIndex = 0;

  Key target1 = GlobalKey();
  Key target2 = GlobalKey();
  GlobalKey target10 = GlobalKey();
  List<TargetFocus> targets = [];

  SharedPreferences sharedPreferences;
  bool showCoache = true;
  TutorialCoachMark tutorialCoachMark;
  bool loadingItem=false;
  void _addProject() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddProjectDialog(
        onProjectCreated: (Project project) {
          setState(() {
            _projects.add(project);
            /*     if (_projects.length == 0) {
             _keyCupertino = GlobalKey();
            }

            if (_projects.length > 1) {
              ctrl.animateToItem(
                _projects.length - 1,
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            }*/
          });
        },
      ),
    );
  }

  void _addUser() {

    showDialog(
      context: context,
      builder: (BuildContext context) => AddUserDialog(
        onItemClick: (username) async {
          final profile = await Auth.profile(
            username: username,
          );
        },
      ),
    );
  }

  Widget _getAddProjectWidget() {
    if (!widget.isAdmin) {
      return Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: _addUser,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 20),
            child: Text(
              '+ Add User',
              key: target2,
              style: TextStyle(
                color: CatchupColors.red,
                fontFamily: 'Gothic',
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        key: target10,
        onTap: _addProject,
        child: Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20),
          child: Text(
            '+ Add Project',
            style: TextStyle(
              color: CatchupColors.red,
              fontFamily: 'Gothic',
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _loadProjects() async {
    try {
      List<Project> projects = [];
      if (widget.archive) {
        projects = await Projects.archive();
      } else {
        projects = await Projects.all(isAdmin: widget.isAdmin);
      }

      if(mounted)
      setState(() {
        _projects = projects;
        _filteredProjects = projects;
      });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  void _openProject(Project project) {
/*    if (project.isCurrentUserAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TasksListPage(
            project: project,
          ),
        ),
      );
      return;
    }*/

    if (widget.archive) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TaskListPageArchive(id: project.id)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AcceptorTaskPage(
            project: project,
            admin: project.isCurrentUserAdmin,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _loadProjects();

    if (!widget.isAdmin) {
        Global.updateProcess.listen((event) {
          if (mounted) {
            _loadProjects();
          }
        });
    }

    initTargets();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      sharedPreferences = await SharedPreferences.getInstance();
      if(widget.isAdmin){
        if(sharedPreferences.containsKey('mark_project_admin_list')) {
          showCoache = sharedPreferences.getBool('mark_project_admin_list');
        }
      }else{
        if(sharedPreferences.containsKey('mark_project_list')) {
          showCoache = sharedPreferences.getBool('mark_project_list');
        }
      }

     if (showCoache) {
         showTutorial();
     }
    });
  }

  @override
  Widget build(BuildContext context) {
    Global.screenSize = MediaQuery.of(context).copyWith().size;

    return WillPopScope(
      onWillPop:() async {
        if(tutorialCoachMark!=null)
          tutorialCoachMark.finish();
        Navigator.pop(context);

        return false;
      },
      child: Scaffold(
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
                              _filteredProjects = _projects;
                              return;
                            }

                            _filteredProjects = _projects.where((p) {
                              return p.title.toLowerCase().startsWith(text);
                            }).toList();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    key: _listKey,
                    child: _projects == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: (_filteredProjects == null ||
                                    _filteredProjects.isEmpty)
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
                                :
                                /*Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(top: 100, bottom: 100),

                                  child: ListWheelScrollView(
                                    itemExtent: 280,

                                    children: _filteredProjects.map((project) {
                                      return UserCard(
                                        title: project.title,
                                        showAvatar: false,
                                        isArchive: widget.archive,
                                        value:
                                        project.completionPercentage / 100,
                                      );
                                    }).toList(),
                                  ),
                                )*/
                            GestureDetector(

                                    onTapUp: (TapUpDetails details) {
                                      final x = details.globalPosition.dx;

                                      final RenderBox box = _listKey
                                          .currentContext
                                          .findRenderObject();

                                      final pos = box.localToGlobal(Offset.zero);
                                      final size = box.size;

                                      final y =
                                          details.globalPosition.dy - pos.dy;

                                      final w = MediaQuery.of(context)
                                              .copyWith()
                                              .size
                                              .width -
                                          30;
                                      final h = 104.0;

                                      final yStart = (size.height - h) / 2;
                                      final yEnd = (size.height + h) / 2;

                                      /*if(!widget.archive)
                                        {  if (x >= w-38 &&
                                              x <= w &&
                                              y >= yStart-19 &&
                                              y <= yStart+19)
                                        {
                                            showDialog(
                                              barrierDismissible: !loadingItem,

                                              context: context,
                                              builder: (BuildContext context) =>
                                                 StatefulBuilder(builder: (context, StateSetter innerState) {
                                                   return AlertDialog(

                                                      title: Text("Delete Project" , style: TextStyle(color: CatchupColors.red),),
                                                      content: Stack(
                                                        children: [
                                                          Container(
                                                              height: 20,
                                                              child: Text('you want to delete this item?' , style: TextStyle(color: Colors.white),)),
                                                          loadingItem?Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            children: [
                                                              Expanded(child: SizedBox()),
                                                              CircularProgressIndicator(),
                                                              Expanded(child: SizedBox()),
                                                            ],
                                                          ):SizedBox()
                                                        ],
                                                      ),
                                                      backgroundColor: CatchupColors.black,
                                                      actions: [
                                                        IgnorePointer(
                                                          child: GestureDetector(
                                                            onTap: () async{
                                                              innerState(() {
                                                                loadingItem=true;
                                                              });
                                                              _deleteTask(_projects[_selectedIndex].id,_selectedIndex,innerState);
                                                            },
                                                            child: Container(
                                                              width: 60,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
                                                                color: loadingItem?CatchupColors.gray:CatchupColors.red,
                                                              ),
                                                              padding: EdgeInsets.symmetric(vertical: 4 , horizontal: 6),
                                                              child: Center(child: Text('Yes')),
                                                            ),
                                                          ),
                                                          ignoring: loadingItem,
                                                        ),

                                                        IgnorePointer(
                                                          child: GestureDetector(
                                                            onTap: (){
                                                              Navigator.pop(context);
                                                            },
                                                            child: Container(
                                                              width: 60,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
                                                                color: loadingItem?CatchupColors.gray:CatchupColors.red,
                                                              ),
                                                              padding: EdgeInsets.symmetric(vertical: 4 , horizontal: 10),
                                                              child: Center(child: Text('No')),
                                                            ),
                                                          ),
                                                          ignoring: loadingItem,
                                                        ),
                                                      ],
                                                    );}),
                                            );
                                          }
                                          else if (x >= 30 &&
                                              x <= w &&
                                              y >= yStart &&
                                              y <= yEnd) {
                                            _openProject(_projects[_selectedIndex]);
                                          }}*/
                                      //else{
                                        if (x >= 30 &&
                                            x <= w &&
                                            y >= yStart &&
                                            y <= yEnd) {
                                          _openProject(_projects[_selectedIndex]);
                                        }
                                      //}

                                    }
                                    ,
                                    child: UserPicker(
                                      key: _keyCupertino,
                                      scrollController: ctrl,
                                      backgroundColor: Colors.transparent,
                                      children: _filteredProjects.map((project) {
                                        return Stack(
                                          children: [
                                            SizedBox(
                                            child: UserCard(
                                              title: project.title,
                                              showAvatar: false,
                                              isArchive: widget.archive,
                                              value:
                                                  project.completionPercentage / 100,
                                            ),
                                            height: 320,
                                          ),
                                            /*!widget.archive && widget.isAdmin?GestureDetector(
                                              child: Align(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: Colors.red,

                                                  ),
                                                  child: Icon(Icons.delete_forever,size: 25,),
                                                  height: 38,
                                                  width: 38,
                                                ),

                                                alignment: Alignment.topRight,
                                              ),

                                            ):SizedBox()*/
                                          ],
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
                  _getAddProjectWidget(),
                ],
              ),
            ),
            MenuFloat(
              position: position,
              keyData: target1,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }
  void _deleteTask(int projectId,int index, StateSetter innerState) async {


    try {
      await Projects.delete(projectId,);
      Navigator.pop(context);
      setState(() {
        _projects.remove(_projects[index]);

      });


    } on SocketException {
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
//      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
    innerState(() {
      loadingItem=false;

    });
  }
  void initTargets() {
    if (widget.isAdmin) {
      targets.add(
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "Target 10",
          keyTarget: target10,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "ADD Project",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "The main screen allows you to ASSIGN NEW or see the ongoing ASSIGNED PROJECT along with the PERCENTAGE OF COMPLETION for each ",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      );
    } else {
      targets.add(
        TargetFocus(
          identify: "Target 1",
          keyTarget: target1,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "MENU BUTTON",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "This will allow you to access the different options once you click it, inside are the following items arrange in circular order (clockwise arrangement)"
                              "\n 1. USER ACCOUNT PROFILE \n 2. CHAT BOX \n 3. ADD PROJECT \n 4. ARCHIVES"
                              "\n 5. MANAGE TASK FOLDER \n 6. NEW TASK FOLDER \n 7. CLOSE OPTIONS (in the middle)",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      );

      targets.add(
        TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "Target 2",
          keyTarget: target2,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "ADD USER BUTTON",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "This icon allows you to ADD NEW USER in the system ",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      );
    }
  }

  void showTutorial() async{
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      setState(() {
        tutorialCoachMark=TutorialCoachMark(
          context,
          targets: targets,
          textSkip: "SKIP",
          alignSkip: AlignmentDirectional.bottomStart,
          paddingFocus: 10,
          opacityShadow: 0.6,
          onFinish: () async {
            if (widget.isAdmin) {
              await sharedPreferences.setBool('mark_project_admin_list', false);
            } else {
              await sharedPreferences.setBool('mark_project_list', false);
            }
          },
          onClickTarget: (target) {
            print('onClickTarget: $target');
          },
          onSkip: () async {
            if (widget.isAdmin) {
              await sharedPreferences.setBool('mark_project_admin_list', false);
            } else {
              await sharedPreferences.setBool('mark_project_list', false);
            }
          },
          onClickOverlay: (target) {
            print('onClickOverlay: $target');
          },
        )..show();
      });

  }
}
