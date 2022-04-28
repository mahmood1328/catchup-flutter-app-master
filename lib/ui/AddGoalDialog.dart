import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/goals.dart';
import 'package:catchup/models/goal.dart';
import 'package:catchup/models/task.dart';
import 'package:flutter/material.dart';

import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../colors.dart';

class AddGoalDialog extends StatefulWidget {
  final Task task;

  final Function(Goal goal) onGoalCreated;

  const AddGoalDialog({
    Key key,
    this.task,
    this.onGoalCreated,
  }) : super(key: key);

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _percentageController = TextEditingController();

  DateTime deadLine;

  bool coach = true;
  SharedPreferences sharedPreferences;

  Key target2 = GlobalKey();
  Key target1 = GlobalKey();
  Key target3 = GlobalKey();
  Key target4 = GlobalKey();
  Key target5 = GlobalKey();
  List<TargetFocus> targets = [];
  TutorialCoachMark tutorialCoachMark;
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    _percentageController.dispose();

    super.dispose();
  }

  getShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey('mark_add_goal')){
      coach = sharedPreferences.getBool('mark_add_goal');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
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
             await sharedPreferences.setBool('mark_add_goal', false);
           },
           onClickTarget: (target) {
             print('onClickTarget: $target');
           },
           onSkip: () async {
             await sharedPreferences.setBool('mark_add_goal', false);
           },
           onClickOverlay: (target) {
             print('onClickOverlay: $target');
           },
         )..show();

       });
     }
    });
  }

  void _openDatePicker() async {
    //before today can not choose
    List<DateTime> disableDates = List.generate(
        365, (index) => DateTime.now().subtract(Duration(days: index + 1)));

    final DateTime newDateTime = await showRoundedDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 1),
        borderRadius: 16,
        theme: ThemeData(primarySwatch: Colors.red),
        listDateDisabled: disableDates);

    deadLine = newDateTime;

    _deadlineController.text =
        '${newDateTime.year}/${newDateTime.month}/${newDateTime.day}';
  }

  Future _addGoal() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final String percentageText = _percentageController.text;

    double percentage;

    if (title.isEmpty || description.isEmpty || deadLine == null) {
      return;
    }

    if (widget.task.isManual) {
      if (percentageText.isEmpty) {
        return;
      }

      percentage = double.tryParse(percentageText);

      if (percentage == null || percentage < 1 || percentage > 100) {
        return;
      }
    }

    try {
      final Goal goal = await Goals.add(
        widget.task.id,
        percentage,
        title,
        description,
        DateTime.now(),
        deadLine,
      );

      widget.onGoalCreated(goal);
    } on SocketException {
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
//      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
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
                keyboardType: TextInputType.text,
                maxLines: 1,
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
              TextFormField(
                key: target3,
                controller: _deadlineController,
                keyboardType: TextInputType.text,
                enableInteractiveSelection: false,
                readOnly: true,
                onTap: _openDatePicker,
                style: TextStyle(
                  color: CatchupColors.black,
                  fontFamily: 'Gothic',
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  hintText: 'Deadline:',
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
              Opacity(
                opacity: widget.task.isManual ? 1 : 0,
                child: TextFormField(
                  key: target4,
                  controller: _percentageController,
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  style: TextStyle(
                    color: CatchupColors.black,
                    fontFamily: 'Gothic',
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Percentage:',
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
              ),
              SizedBox(height: 20),
              GestureDetector(
                key: target5,
                onTap: () async {
                  Navigator.pop(context);
                  await _addGoal();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 40,
                  width: 120,
                  decoration: BoxDecoration(
                    color: CatchupColors.red,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      'FINISH!',
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
                        "Write the Title of the TASK",
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
                        "Put a brief description of the task",
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
                      "DeadLine",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Put the Deadline of the Task",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );

    if(widget.task.isManual) {
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
                        "PERCENTAGE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Then the PERCENTAGE COMPLETION of the specific task",
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
    targets.add(
      TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Target 5",
        keyTarget: target5,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "FINISH",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Then click FINISH button to complete the process",
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
