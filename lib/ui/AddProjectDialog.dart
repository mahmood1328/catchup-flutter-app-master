import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/projects.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/project.dart';
import 'package:catchup/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../colors.dart';
import 'AddUserDialog.dart';

class AddProjectDialog extends StatefulWidget {
  final Function(Project project) onProjectCreated;

  const AddProjectDialog({Key key, this.onProjectCreated}) : super(key: key);

  @override
  _AddProjectDialogState createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  List<User> _users;
  Set<int> _selectedAcceptors = Set();

  bool _isLoadingButton = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _addProject() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;

    if (title.isEmpty || description.isEmpty || _selectedAcceptors.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingButton = true;
    });

    final List<String> users = List();
    final List<User> usersToReturn = List();

    for (final i in _selectedAcceptors) {
      usersToReturn.add(_users[i]);
      users.add(_users[i].username);
    }

    try {
      final projectId = await Projects.add(title, description, users);

      if (projectId != -1) {
        widget.onProjectCreated(Project(
          id: projectId,
          title: title,
          description: description,
          users: usersToReturn,
          admin: Global.user,
        ));
        Navigator.pop(context, true);
      } else {
        // TODO: Project is NOT added!
      }
    } on SocketException {
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
//      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  void _loadContacts() async {
    try {
      final users = await Auth.users();

      setState(() {
        _users = users;
      });
    } on SocketException {
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
//      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }

  Key target1 = GlobalKey();
  Key target2 = GlobalKey();
  Key target3 = GlobalKey();
  Key target4 = GlobalKey();
  List<TargetFocus> targets = [];
  TutorialCoachMark tutorialCoachMark;
  SharedPreferences sharedPreferences;
  bool showCoach = true;

  getShare() async{
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey('mark_add_project')){
      showCoach = sharedPreferences.getBool('mark_add_project');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) async{
          await getShare();
          if(showCoach){
            initTarget();
            setState(() {
              tutorialCoachMark=TutorialCoachMark(
                context,
                targets: targets,
                textSkip: "SKIP",
                alignSkip: AlignmentDirectional.bottomStart,
                paddingFocus: 10,
                opacityShadow: 0.6,
                onFinish: () async {
                  await sharedPreferences.setBool('mark_add_project', false);
                },
                onClickTarget: (target) {
                  print('onClickTarget: $target');
                },
                onSkip: () async {
                  await sharedPreferences.setBool('mark_add_project', false);
                },
                onClickOverlay: (target) {
                  print('onClickOverlay: $target');
                },
              )..show();

            });
          }
    });

    _loadContacts();
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddUserDialog(
        onItemClick: (String username) {
          if (_users == null) {
            _users = List();
          }

          final user = User(
            username: username,
          );

          if (!_users.contains(user)) {
            _users.add(user);

            // Update State
            setState(() {});
          }
        },
      ),
    );
  }

  Widget noUserWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.group_add,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'Add Users',
            style: TextStyle(
              fontFamily: 'Gothic',
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async {
        if(tutorialCoachMark!=null)
          tutorialCoachMark.finish();
        Navigator.pop(context);

        return false;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  key: target1,
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: CatchupColors.black,
                    fontFamily: 'Gothic',
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title:',
                    contentPadding: const EdgeInsets.only(
                      left: 1,
                      bottom: 5,
                      right: 1,
                    ),
                    hintStyle: TextStyle(
                      color: CatchupColors.lightGray,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CatchupColors.lightGray,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CatchupColors.gray,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CatchupColors.lightGray,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  key: target2,
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  style: TextStyle(
                    color: CatchupColors.black,
                    fontFamily: 'Gothic',
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Description:',
                    contentPadding: const EdgeInsets.only(
                      left: 1,
                      bottom: 5,
                      right: 1,
                    ),
                    hintStyle: TextStyle(
                      color: CatchupColors.lightGray,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CatchupColors.lightGray,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CatchupColors.gray,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CatchupColors.lightGray,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Acceptors:',
                      style: TextStyle(
                        color: CatchupColors.black,
                        fontFamily: 'Gothic',
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      key: target3,
                      icon: Icon(Icons.add),
                      onPressed: _addUser,
                    )
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom == 0 ? 150 : 60,
                  child: Container(
                    key: target4,
                    decoration: BoxDecoration(
                      color: CatchupColors.bgLightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _users == null || _users.isEmpty
                        ? noUserWidget()
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              bool _contains = _selectedAcceptors.contains(index);

                              return Container(
                                decoration: BoxDecoration(
                                  color: _contains
                                      ? CatchupColors.gray
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  selected: _contains,
                                  onTap: () {
                                    // on click
                                    if (_contains) {
                                      _selectedAcceptors.remove(index);
                                    } else {
                                      _selectedAcceptors.add(index);
                                    }

                                    setState(() => {}); // Update UI
                                  },
                                  leading: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage('assets/profile.jpg'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    _users[index].username,
                                    style: TextStyle(
                                      fontFamily: 'Gothic',
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: _users.length,
                          ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _addProject,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      color: CatchupColors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: _isLoadingButton ? CircularProgressIndicator() : Text(
                        'ADD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gothic',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initTarget() {
    targets.add(
      TargetFocus(
        shape: ShapeLightFocus.RRect,
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
                      "TITLE",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "You can place the TITLE / NAME OF THE SPECIFIC PROJECT",
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
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "DESCRIPTION",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Next is to add a brief DESCRIPTION OF THE PROJECT.",
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
        identify: "Target 3",
        keyTarget: target3,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Add ACCEPTOR",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Next is to assign the ACCEPTOR (team member / staff) of the specific task.",
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
        identify: "Target 4",
        keyTarget: target4,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "List ACCEPTOR",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "After assigning the ACCEPTOR of the specific task. You can now assign a TASK to the specific ACCEPTOR",
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
