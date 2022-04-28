/*

import 'dart:isolate';
import 'dart:ui';

import 'package:catchup/api/urls.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/models/comment.dart';
import 'package:catchup/my_flutter_app_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;

  const CommentWidget({Key key, this.comment}) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  bool downloading = false;
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 30,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                 image: DecorationImage(
                image: NetworkImage( comment.user.picture),
                fit: BoxFit.cover,
              ),
                ),
          ),
          SizedBox(width: 10),
          Expanded(
              child:  comment.file == null
                  ? Text(
                       comment.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gothic',
                        fontSize: 15,
                      ),
                    )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                           comment.message,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gothic',
                            fontSize: 15,
                          ),
                        ),
                        ListTile(
                          onTap: (){
                            setState(() {
                              downloading = true;
                            });
                                _startDL();
                          },
                          leading: Icon(MyFlutterApp.file , color: Colors.white,size: 20,),
                          title: Text( comment.file.substring(
                               comment.file.lastIndexOf('/') + 1
                          ),style: TextStyle(color: Colors.white , fontSize: 12),),
                          subtitle : downloading ? LinearProgressIndicator( value: value.toDouble(),
                              backgroundColor: CatchupColors.gray,
                              valueColor: AlwaysStoppedAnimation<Color>(CatchupColors.orange),) : SizedBox(),
                        ),
                      ],
                    )),
          SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${ comment.likesCount}',
                      style: TextStyle(
                        color: CatchupColors.red,
                        fontFamily: 'Gothic',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                       comment.youLiked
                          ? FontAwesomeIcons.solidThumbsUp
                          : FontAwesomeIcons.thumbsUp,
                      color: CatchupColors.red,
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: 5,),
                Text( comment.createdAt.year.toString() + '/'
                  +  comment.createdAt.month.toString() + '/'
                  +  comment.createdAt.day.toString(),
                  style: TextStyle(fontSize: 12 , color: Colors.white , fontFamily: 'Gothic'),)
              ],
            ),
          ),
        ],
      ),
    );
  }

  _startDL() async{
    String address = await _localPath;
    final taskId = await FlutterDownloader.enqueue(
      url: Urls.HOST +  comment.file,
      savedDir: address ,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
  }

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      value = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //todo after start -> can dialog and delete

}
*/

import 'package:catchup/colors.dart';
import 'package:catchup/models/comment.dart';
import 'package:catchup/my_flutter_app_icons.dart';
import 'package:catchup/pages/FeedBackProfilePage.dart';
import 'package:catchup/provider/GoalProvider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final int value;
  final Function like;
  final Function download;

  CommentWidget(
      {@required this.comment,
      this.value = -1,
      @required this.download,
      @required this.like});

  @override
  Widget build(BuildContext context) {
    print(
      value.toDouble(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 30,
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FeedBackProfilePage(username: comment.user.username),
                  ));
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(comment.user.picture),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),

          Expanded(
              child: comment.file == null
                  ? Text(
                      comment.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gothic',
                        fontSize: 15,
                      ),
                    )
                  :  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.message,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gothic',
                            fontSize: 15,
                          ),
                        ),
                        ListTile(
                            onTap: () {
                              download();
                            },
                            leading: Icon(
                              MyFlutterApp.file,
                              color: Colors.white,
                              size: 20,
                            ),
                            title:  Text(
                              comment.file
                                  .substring(comment.file.lastIndexOf('/') + 1),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            subtitle: comment.downloaded || value==100
                                ? Text(
                                    'downloaded',
                                    style: TextStyle(color: CatchupColors.red),
                                  )
                                : value == -1
                                    ? SizedBox()
                                    : LinearProgressIndicator(
                                        value: value.toDouble(),
                                        backgroundColor: CatchupColors.gray,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                CatchupColors.orange),
                                      )),
                      ],
                    ),),
          SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${comment.likesCount}',
                      style: TextStyle(
                        color: CatchupColors.red,
                        fontFamily: 'Gothic',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: like,
                      child: Icon(
                        comment.youLiked
                            ? FontAwesomeIcons.solidThumbsUp
                            : FontAwesomeIcons.thumbsUp,
                        color: CatchupColors.red,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  comment.createdAt.year.toString() +
                      '/' +
                      comment.createdAt.month.toString() +
                      '/' +
                      comment.createdAt.day.toString(),
                  style: TextStyle(
                      fontSize: 12, color: Colors.white, fontFamily: 'Gothic'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
