import 'dart:io';
import 'package:catchup/api/goals.dart';
import 'package:catchup/models/project.dart';
import 'package:path/path.dart' as p;

import 'package:catchup/colors.dart';
import 'package:catchup/components/text_box.dart';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class MyFile {
  String filename;
  bool isUploading = false;
  int uploadValue = 0;

  MyFile(this.filename, {this.isUploading = false, this.uploadValue = 0});
}

class CreateGoalDialog extends StatefulWidget {

  final Project project;


  CreateGoalDialog({@required this.project});

  @override
  _CreateGoalDialogState createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<CreateGoalDialog> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController desController = TextEditingController();

  static const _blackTextStyle = const TextStyle(
    color: Colors.black,
    fontFamily: 'Gothic',
  );

  final _filesListKey = GlobalKey<AnimatedListState>();

  List<MyFile> _files = [
    MyFile('awesome-file.jpg'),
  ];

  DateTime _currentDate = DateTime.now();

  bool _isUploading = false;

  int _radioValue = 0;

  double _flex = 34.0;

  void _pickFile() async {
    final File file = await FilePicker.getFile();

    if (file == null) {
      return;
    }

    _files.add(MyFile(p.basename(file.path)));
    _filesListKey.currentState.insertItem(_files.length - 1);
  }

  Widget _getUploadButton() {
    if (_isUploading) {
      return FlatButton(
        textColor: Color(0xff5dac97),
        color: Color(0xffb5e8df),
        disabledColor: Color(0xffb5e8df),
        child: Text('Uploading...'),
        shape: StadiumBorder(
          side: BorderSide(
            color: Color(0xff98e1ce),
            width: 2,
          ),
        ),
        onPressed: null,
      );
    }

    return OutlineButton(
      textColor: Colors.grey,
      highlightedBorderColor: CatchupColors.mediumGray,
      child: Text('Upload'),
      shape: StadiumBorder(),
      onPressed: () async {
        setState(() => _isUploading = true);

        for (final file in _files) {
          setState(() => file.isUploading = true);

          await Future.delayed(Duration(seconds: 2));

          setState(() => file.isUploading = false);
        }

        setState(() => _isUploading = false);
      },
    );
  }

  Widget _buildFileItem(
      MyFile file, Animation animation, GestureTapCallback onTap) {
    return FadeTransition(
      opacity: animation,
      child: SizedBox(
        height: 50,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Color(0xffd8d8d8),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    file.filename,
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          file.isUploading ? Icons.cancel : Icons.delete,
                          color: CatchupColors.mediumGray,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  onTap: onTap,
                ),
              ],
            ),
            Opacity(
              opacity: file.isUploading ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xffd8d8d8),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(CatchupColors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GrayTextBox(
                  controller: nameController,
                  textColor: Colors.black,
                  hint: 'Goal Name',
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GrayTextBox(
                  controller: desController,
                  textColor: Colors.black,
                  hint: 'Description',
                ),
              ),
              SizedBox(height: 20),
              AnimatedList(
                key: _filesListKey,
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 25,
                ),
                shrinkWrap: true,
                initialItemCount: _files.length,
                itemBuilder: (
                  BuildContext context,
                  int index,
                  Animation<double> animation,
                ) {
                  return _buildFileItem(_files[index], animation, () {
                    final _removedItem = _files.removeAt(index);

                    _filesListKey.currentState.removeItem(
                      index,
                      (context, animation) {
                        return _buildFileItem(_removedItem, animation, () {});
                      },
                    );
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 40),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: CatchupColors.mediumGray,
                          ),
                        ),
                      ),
                      onTap: _pickFile,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlineButton(
                            textColor: Colors.grey,
                            highlightedBorderColor: CatchupColors.mediumGray,
                            child: Text('Cancel'),
                            shape: StadiumBorder(),
                            onPressed: () {},
                          ),
                          SizedBox(width: 15),
                          _getUploadButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Radio(
                          value: 0,
                          groupValue: _radioValue,
                          onChanged: (value) => setState(() => _radioValue = value),
                        ),
                        Text(
                          'Manual',
                          style: TextStyle(fontFamily: 'Gothic'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: (value) => setState(() => _radioValue = value),
                        ),
                        Text(
                          'Automatic',
                          style: TextStyle(fontFamily: 'Gothic'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Slider(
                        value: _flex,
                        min: 1,
                        max: 100,
                        onChanged: (newFlex) => setState(() => _flex = newFlex),
                      ),
                    ),
                    SizedBox(width: 40, child: Text('%${_flex.toInt()}')),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CalendarCarousel(
                  selectedDateTime: _currentDate,
                  onDayPressed: (date, events) {
                    setState(() => _currentDate = date);
                  },
                  customGridViewPhysics: NeverScrollableScrollPhysics(),
                  height: 380,
                  markedDateWidget: Container(
                    height: 0,
                    width: 0,
                  ),
                  markedDateCustomShapeBorder: CircleBorder(
                    side: BorderSide(
                      color: CatchupColors.red,
                      width: 2,
                    ),
                  ),
                  showOnlyCurrentMonthDate: true,
                  iconColor: Colors.black,
                  daysTextStyle: _blackTextStyle,
                  weekendTextStyle: TextStyle(
                    color: CatchupColors.red,
                    fontFamily: 'Gothic',
                  ),
                  weekdayTextStyle: const TextStyle(
                    color: Color(0xffe5962d),
                    fontFamily: 'Gothic',
                  ),
                  headerTextStyle: _blackTextStyle,
                  todayButtonColor: Colors.transparent,
                  todayTextStyle: _blackTextStyle,
                  selectedDayButtonColor: CatchupColors.red.withOpacity(0.4),
                  selectedDayTextStyle: _blackTextStyle,
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () async{
                    //todo handle start and end time & manual or automatic
                    await Goals.add(widget.project.id, _flex , nameController.text,
                        desController.text, _currentDate, _currentDate);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 40,
                    decoration: BoxDecoration(
                      color: CatchupColors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        'Finish!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gothic',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
