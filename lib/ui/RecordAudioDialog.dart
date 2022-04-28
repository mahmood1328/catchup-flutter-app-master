import 'dart:async';

import 'package:catchup/colors.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class RecordAudioDialog extends StatefulWidget {
  final Function(Recording) onRecordDone;

  const RecordAudioDialog({Key key, this.onRecordDone}) : super(key: key);

  @override
  _RecordAudioDialogState createState() => _RecordAudioDialogState();
}

class _RecordAudioDialogState extends State<RecordAudioDialog> {

  bool _isRecording = false;
  int recordTimeSecond = 0;
  int recordTimeMinute = 0;
  Timer t;

  Widget _getRecordButton(BuildContext c) {
    if (_isRecording) {
      return FlatButton(
        textColor: Colors.white,
        color: CatchupColors.red,
        child: Text(
          'Recording... Tap to stop',
          style: TextStyle(
            fontFamily: 'Gothic',
          ),
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: CatchupColors.darkRed,
            width: 2,
          ),
        ),
        onPressed: () async {
          bool isRecording = await AudioRecorder.isRecording;

          if (!isRecording) {
            return;
          }

          final Recording recording = await AudioRecorder.stop();

          setState(() {
            _isRecording = false;
          });

          Navigator.pop(c);

          if (widget.onRecordDone != null) {
            widget.onRecordDone(recording);
          }
        },
      );
    }

    return OutlineButton(
      textColor: Colors.grey,
      highlightedBorderColor: CatchupColors.mediumGray,
      child: Text(
        'Start Recording',
        style: TextStyle(
          fontFamily: 'Gothic',
        ),
      ),
      shape: StadiumBorder(),
      onPressed: () async {
        if (!(await Permission.microphone.request().isGranted)) {
          return;
        }

        if (!(await Permission.storage.request().isGranted)) {
          return;
        }

        if (!(await AudioRecorder.hasPermissions)) {
          return;
        }

        setState(() {
          _isRecording = true;
        });

        t = Timer.periodic(Duration(seconds: 1), (timer) {
          if (recordTimeSecond == 59) {
            recordTimeSecond = 0;
            recordTimeMinute++;
          }else{
            recordTimeSecond ++;
          }

          if (!mounted) {
            return;
          }
          setState(() {});
        });

        final directory = await getApplicationDocumentsDirectory();
        final String filename = 'voice-${DateTime.now().toIso8601String().replaceAll(' ', '')}';

        await AudioRecorder.start(path: '${directory.path}/$filename', audioOutputFormat: AudioOutputFormat.AAC);
      },
    );
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Icon(
              Icons.keyboard_voice,
              size: 90,
              color: _isRecording ? CatchupColors.red : CatchupColors.gray,
            ),
            SizedBox(height: 20),
            _getRecordButton(context),
            SizedBox(height: 20),
            Text(recordTimeMinute > 10 ? recordTimeMinute.toString() + ":" +
                (recordTimeSecond >10? recordTimeSecond.toString() : "0"+recordTimeSecond.toString()):
            "0"+recordTimeMinute.toString() + ":" +
              (recordTimeSecond >10? recordTimeSecond.toString() : "0"+recordTimeSecond.toString()),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (t!=null && t.isActive) {
      t.cancel();
    }
    super.dispose();
  }
}
