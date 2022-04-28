import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/goals.dart';
import 'package:catchup/models/goal.dart';
import 'package:catchup/models/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_rounded_date_picker/rounded_picker.dart';

import '../colors.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal goal;
  final Task task;

  final Function(Goal goal) onGoalCreated;

  const EditGoalDialog({
    Key key,
    this.task,
    this.goal,
    this.onGoalCreated,
  }) : super(key: key);

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<EditGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _percentageController = TextEditingController();

  DateTime deadLine;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    _percentageController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.goal.title;
    _descriptionController.text = widget.goal.description;
    _deadlineController.text = "${widget.goal.endDate.year}-${widget.goal.endDate.month}-${widget.goal.endDate.day}";
    deadLine = widget.goal.endDate;
    _percentageController.text = widget.goal.completionPercentage.toString();
  }

  void _openDatePicker() async {

    //before today can not choose
    List<DateTime> disableDates = List.generate(365, (index) =>   DateTime.now().subtract(Duration(days: index+1)));

    final DateTime newDateTime = await showRoundedDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      borderRadius: 16,
      theme: ThemeData(primarySwatch: Colors.red),
      listDateDisabled: disableDates
    );

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
      final Goal goal = await Goals.update(
        widget.goal.id,
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
    return Dialog(
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
              onTap: () async {
                await _addGoal();

                Navigator.pop(context);
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
    );
  }
}
