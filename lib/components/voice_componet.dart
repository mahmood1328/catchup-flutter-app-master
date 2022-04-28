import 'package:catchup/api/urls.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/circularbar_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;

class VoiceComponet extends StatefulWidget {
  final String time;
  final String file;

  final bool delivered, isMe, seen;

  VoiceComponet({
    Key key,
    @required this.time,
    @required this.file,
    this.delivered = false,
    this.isMe = false,
    this.seen = false,
  }) : super(key: key);

  @override
  _VoiceComponetState createState() => _VoiceComponetState();
}

class _VoiceComponetState extends State<VoiceComponet> {
  String _localPath;
  AudioPlayer player;
  Duration duration;
  bool downloaded = false;
  List<int> dataUpdate = [];
  double position = 0;

  String _showTime(int time) {
    if (time < 10) {
      return '00:0$time';
    } else if (time < 60) {
      return '00:$time';
    } else {
      int minute = time ~/ 60;
      int sec = time % 60;

      if (sec < 10) {
        return '0$minute:0$time';
      } else if (sec < 60) {
        return '0$minute:$time';
      }
    } //todo more than 10 minute
  }

  _getData() async {
    player = AudioPlayer();
   downloaded =  await getDownloader();
   print(downloaded.toString()+"vvvvvvvvvvvv");
   if(!downloaded){
     await download();
     downloaded=true;
   }
   setState(() {
   });


    player.positionStream.listen((d) {

      if (d.compareTo(duration) == 0) {
        player.stop();
        dataUpdate = [];
      }
      if(!mounted){
        return;
      }
      setState(() {
        position = d.inSeconds.toDouble();
      });
    });

    player.startVisualizer(
        enableFft: true,
        captureRate: 10000,
        captureSize: 1024,
        enableWaveform: true);

    player.visualizerWaveformStream.listen((event) {
      dataUpdate = event.data.toList();
      setState(() {});
    });
  }

  @override
  void initState() {

    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isMe ? Colors.white : CatchupColors.red;
    final mainColor = widget.isMe ? CatchupColors.red : Colors.white;
    final icon = widget.delivered
        ? (widget.seen ? Icons.done_all : Icons.done)
        : Icons.watch_later;
    final radius = widget.isMe
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );
    return Container(
      margin: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: .5,
            spreadRadius: 1.0,
            color: Colors.black.withOpacity(.12),
          )
        ],
        color: bg,
        borderRadius: radius,
      ),
      width: MediaQuery.of(context).size.width / 3 * 2,
      height: 80,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: CustomPaint(
                  painter: CircularBarVisualizer(
                      width: 80,
                      height: 80,
                      color: mainColor,
                      waveData: dataUpdate),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: GestureDetector(
                  onTap: () {
                    print('licked');
                    if (downloaded == true) {
                      print("download");
/*
                      OpenFile.open(_localPath+widget.file.substring(widget.file.lastIndexOf("/"))); //todo saeed
*/

                    player.setAsset(_localPath+widget.file.substring(widget.file.lastIndexOf("/")));

                      player.playing ? player.pause() : player.play();
                    }
                  },
                  child: Icon(
                    downloaded == false
                        ? FontAwesomeIcons.truckLoading
                        : player.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                    size: 30,
                    color: mainColor,
                  ),
                ),
              )
            ],
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Slider(
              min: 0,
              max: duration == null ? 1 : duration.inSeconds.toDouble(),
              value: position,
              onChanged: (newValue) {
                position = newValue;
                player.seek(Duration(seconds: position.toInt()));
                setState(() {});
              },
            ),
            Row(
              children: [
                Text(
                (position == 0 && downloaded== false)
                      ? duration!=null?_showTime(duration.inSeconds):""
                      : _showTime(position.toInt()),
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Expanded(child: SizedBox()),
                Text(widget.time,
                    style: TextStyle(fontSize: 10, color: widget.isMe ? Colors.grey : Colors.white )),
                SizedBox(
                  width: 3,
                ),
                Icon(
                  icon,
                  size: 10,
                  color: Colors.grey,
                )
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    player.stopVisualizer();
    super.dispose();
  }
    Future<String> _findLocalPath() async {
      final directory =
      //Theme.of(context).platform == TargetPlatform.android
      //  ?
      await getExternalStorageDirectory();
      //    :
      // await getApplicationDocumentsDirectory();
      return directory.path;
    }
    Future<void> setAddress() async{
      //todo create file for app
      _localPath = (await _findLocalPath()) + io.Platform.pathSeparator + 'Download';

      final savedDir = io.Directory(_localPath);

      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }


    }

  Future<bool> getDownloader() async{
    await setAddress();
    var syncPath = _localPath+widget.file.substring(widget.file.lastIndexOf("/"));

    bool downloaded=await io.File(syncPath).exists();
    print(downloaded.toString()+"gggggggggg");
    return downloaded;
  }
  Future<String> download() async{


    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
      String taskId = await FlutterDownloader.enqueue(
        url: Urls.HOST + widget.file,
        savedDir: _localPath,
        showNotification: false, //todo majid
        openFileFromNotification: false,
      );
    return taskId;

  }
  Future<String> getPath() async{
    var syncPath = _localPath+widget.file.substring(widget.file.lastIndexOf("/"));
    return syncPath;
  }
}
