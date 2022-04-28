import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../colors.dart';
import 'AddUserDialog.dart';

class AddTaskDialog extends StatefulWidget {
  final int projectId;

  final Function(Task task) onTaskCreated;

  const AddTaskDialog({
    Key key,
    this.projectId,
    this.onTaskCreated,
  }) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  List<User> _users;
  Set<int> _selectedAcceptors = Set();
  int _progressType = 2; // Manual

  bool _isLoadingButton = false;

  Key target2 = GlobalKey();
  Key target1 = GlobalKey();
  Key target3 = GlobalKey();
  Key target4 = GlobalKey();
  Key target5 = GlobalKey();
  Key target6 = GlobalKey();
  List<TargetFocus> targets = [];

  bool coach = true;
  SharedPreferences sharedPreferences;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TutorialCoachMark tutorialCoachMark;
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _addTask() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;

    if (title.isEmpty || description.isEmpty || _selectedAcceptors.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingButton = true;
    });

    final List<String> users = List();

    for (final i in _selectedAcceptors) {
      users.add(_users[i].username);
    }

    try {
      final task = await Tasks.add(
        widget.projectId,
        title,
        description,
        users,
        _progressType,
      );

      widget.onTaskCreated(task);
      Navigator.pop(context, true);
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

  getShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey('mark_add_task')){
      coach = sharedPreferences.getBool('mark_add_task');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) async{
          await getShared();
      if(coach){
        addTargets();
        setState(() {
          tutorialCoachMark=TutorialCoachMark(
            context,
            targets: targets,
            textSkip: "SKIP",
            alignSkip: AlignmentDirectional.bottomStart,
            paddingFocus: 10,
            opacityShadow: 0.6,
            onFinish: () async {
              await sharedPreferences.setBool('mark_add_task', false);
            },
            onClickTarget: (target) {
              print('onClickTarget: $target');
            },
            onSkip: () async {
              await sharedPreferences.setBool('mark_add_task', false);
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
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
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
                Column(
                  children: <Widget>[
                    ListTile(
                      key: target3,
                      title: const Text('Manual'),
                      onTap: () {
                        setState(() {
                          _progressType = 2;
                        });
                      },
                      leading: Radio(
                        value: 2,
                        groupValue: _progressType,
                        onChanged: (int value) {
                          setState(() {
                            _progressType = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      key: target4,
                      title: const Text('Automatic'),
                      onTap: () {
                        setState(() {
                          _progressType = 1;
                        });
                      },
                      leading: Radio(
                        value: 1,
                        groupValue: _progressType,
                        onChanged: (int value) {
                          setState(() {
                            _progressType = value;
                          });
                        },
                      ),
                    ),
                  ],
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
                      key: target5,
                      icon: Icon(Icons.add),
                      onPressed: _addUser,
                    )
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: Container(
                    key: target6,
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
                  onTap: _addTask,
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


  void addTargets() {
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
                        "You can place the TITLE / NAME OF THE SPECIFIC TASK",
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
                        "Next is to add a brief DESCRIPTION OF THE TASK.",
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
        keyTarget: target5,
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
        keyTarget: target6,
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
