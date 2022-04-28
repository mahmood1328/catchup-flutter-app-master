import 'dart:io';

import 'package:catchup/api/urls.dart';
import 'package:flutter/material.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import '../colors.dart';

class Bubble extends StatelessWidget {
  final Function(String url) onImageClicked;

  Bubble({
    this.message,
    this.time,
    this.delivered = false,
    this.isMe = false,
    this.seen = false,
    this.file,
    this.showSender = false,
    this.onImageClicked,
  });

  final String message, time, file;
  final bool delivered, isMe, seen, showSender;

  Future<String> _findLocalPath() async {
    final directory =
    //Theme.of(context).platform == TargetPlatform.android
    //  ?
    await getExternalStorageDirectory();
    //    :
    // await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Widget _textContentWidget(Color textColor) {
    return Padding(
      padding: EdgeInsets.only(
        right: file == null ? 48.0 : 0,
        bottom: file == null ? 20 : 20.0,
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Gothic',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _imageContentWidget(BuildContext context) {
    final String filename = file.split('/').last;

    if (filename == null || filename.isEmpty) {
      return Text('CROPTED FILE');
    }

    final String extension = filename.split('.').last;

    final bool isImage =
        ['png', 'jpg', 'gif', 'jpeg', 'bmp'].contains(extension.toLowerCase());

    Widget widgetToShow;

    if (isImage) {
      widgetToShow = GestureDetector(
        onTap: () {
              print('aclla');
        },
        child: Container(
          width: MediaQuery.of(context).size.width/3*2,
          height: 200,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(Urls.HOST + file,)
              )
          ),
        ),
      );
    }else {
      widgetToShow = GestureDetector(
        onTap: () async{

          String _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

          final savedDir = Directory(_localPath);
          bool hasExisted = await savedDir.exists();
          if (!hasExisted) {
            savedDir.create();
          }

          String taskId = await FlutterDownloader.enqueue(
            url: Urls.HOST + file,
            savedDir: _localPath,
            showNotification: true,
            openFileFromNotification: true,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CatchupColors.gray,
              ),
              child: Icon(
                isImage ? Icons.image : Icons.cloud_download,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text(
              filename,
              style: TextStyle(
                color: CatchupColors.black,
                fontFamily: 'Gotham',
                fontSize: 15,
              ),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isImage ? 20.0 : 5.0),
      child: widgetToShow,
    );
  }

  Widget _contentWidget(BuildContext context) {
    final textColor = isMe ? CatchupColors.black : Colors.white;

    if (file == null) {
      return _textContentWidget(textColor);
    }

    return _imageContentWidget(context);
  }

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.white : CatchupColors.red;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final icon =
        delivered ? (seen ? Icons.done_all : Icons.done) : Icons.watch_later;
    final radius = isMe
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
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(8.0),
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
          child: Stack(
            children: <Widget>[
              _contentWidget(context),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 10.0,
                      ),
                    ),
                    SizedBox(width: 3.0),
                    Icon(
                      icon,
                      size: 12.0,
                      color: Colors.black38,
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
