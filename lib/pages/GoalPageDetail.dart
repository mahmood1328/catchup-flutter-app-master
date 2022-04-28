import 'dart:collection';
import 'dart:convert';

import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:io' as io;
import 'package:catchup/pages/show_users_list_page.dart';
import 'package:catchup/provider/GoalProvider.dart';
import 'package:open_file/open_file.dart';
import 'package:catchup/api/goals.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/components/goal_detail_circel_item.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/comment.dart';
import 'package:catchup/models/goal.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/pages/feed_back_page_task.dart';
import 'package:catchup/ui/AddGoalDialog.dart';
import 'package:catchup/ui/CommentWidget.dart';
import 'package:catchup/ui/MyCircularPercentIndicator.dart' as myProgress;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../colors.dart';

class GoalPageDetail extends StatefulWidget {
  final Task task;
  final bool isAdmin;
  final bool isArchived;
  GoalPageDetail({@required this.task, @required this.isAdmin,@required this.isArchived});

  @override
  _GoalPageDetail createState() => _GoalPageDetail();
}

class _GoalPageDetail extends State<GoalPageDetail> {
  bool loadingSend = false;
  Color _getColor(double percent) {
    if (percent <= 0.25) {
      return CatchupColors.red;
    }

    if (percent <= 0.5) {
      return Color(0xffdf4900);
    }

    if (percent <= 0.75) {
      return Color(0xfffebd00);
    }

    return Color(0xff01c501);
  }

  bool uploading = false;

  String _localPath;

  List<Goal> goals;
  List<Comment> comments;
  int valueUpload = 0;
  int id = 0;
  int index = 0;

  int location= 0;

  ReceivePort _port = ReceivePort();

  Map<String, int> values = HashMap<String, int>();

  io.File select;

  TextEditingController controller = TextEditingController();

  _getGoals() async {
    goals = await Goals.all(widget.task.id);
    if (goals.length > 0) {
      id = goals[0].id;
      location = 0;
      //get comments
      _getComment(goals[0].id.toString());
    } else {
      setState(() {});
    }
  }

  _getComment(String id) async {
    comments = await Goals.getComments(id);
    for(int i=0 ; i< comments.length ; i++){
      if(comments[i].file!=null ){
        bool s = await getDownloader(comments[i]);
        String g= await getPath(comments[i]);
        comments[i].downloaded = s;
        comments[i].localPath=g;
    }
      }


    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getGoals();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int value = data[2];
      setState(() {
        if (values.containsKey(id)) {
          values[id] = value;
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
    setAddress();

    Global.updateProcess.listen((event) {
      if(mounted){
        _getComment(id.toString());
      }
    });
  }

  setAddress() async{
    //todo create file for app
    _localPath = (await _findLocalPath()) + io.Platform.pathSeparator + 'Download';

    final savedDir = io.Directory(_localPath);

    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }


  }
  Future<String> _findLocalPath() async {
    final directory =
    //await getExternalStorageDirectory();
    await getApplicationDocumentsDirectory();

    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchupColors.black,
      body: Stack(
        children: [
          SafeArea(
            child: (goals != null && goals.length == 0)
                ? Center(
                    child: Text(
                      'Is Empty!',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: myProgress.MyCircularProgressIndicator(
                              value: widget.task.completionPercentage / 100,
                              strokeWidth: 7,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getColor(
                                    widget.task.completionPercentage / 100),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: 2 *
                                math.pi *
                                (widget.task.completionPercentage / 100 + 0.03),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: myProgress.MyCircularProgressIndicator(
                                value: math.max(
                                    0,
                                    1 - widget.task.completionPercentage / 100 -
                                        0.06),
                                strokeWidth: 7,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xff949595)),
                              ),
                            ),
                          ),
                          Text(
                            goals == null
                                ? '0'
                                : widget.task.completionPercentage
                                            .toString()
                                            .length >
                                        4
                                    ? widget.task.completionPercentage
                                        .toString()
                                        .substring(0, 4)
                                    : widget.task.completionPercentage
                                        .toString(),
                            style: TextStyle(
                              color: _getColor(
                                  widget.task.completionPercentage / 100),
                              fontFamily: 'Gothic',
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height /
                                      100 *
                                      1.5),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height / 400,
                                color: Colors.white,
                              ),
                            ),
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: goals != null
                                      ? goals.map((e) {
                                          if (e.id == id) {
                                            return GoalDetailCircleItem(
                                                id: e.id.toString(),
                                                active: true,
                                                child: (e.seen != null &&
                                                        !e.seen &&
                                                        widget.isAdmin)
                                                    ? Icon(
                                                        Icons
                                                            .notifications_active,
                                                        color: Colors.black,
                                                  size: 17,
                                                      )
                                                    : SizedBox(),
                                                date: e.endDate
                                                    .toString()
                                                    .substring(0, 10));
                                          } else {
                                            return GoalDetailCircleItem(
                                                id: e.id.toString(),
                                                action: (id) {
                                                  this.id = int.parse(id);
                                                  location = goals.indexOf(e);
                                                  _getComment(id);
                                                },
                                                active: false,
                                                child: (e.seen != null &&
                                                    !e.seen &&
                                                    widget.isAdmin)
                                                    ? Icon(
                                                  Icons
                                                      .notifications_active,
                                                  color: Colors.black,
                                                  size: 12,
                                                ) : SizedBox(),
                                                date: e.endDate
                                                    .toString()
                                                    .substring(0, 10));
                                          }
                                        }).toList()
                                      : [],
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          SizedBox(width: 25),
                          Text(
                              (goals == null || id == null) ? '-' : goals[goals.indexOf(Goal(id: id))].description,
                            style: TextStyle(
                                color: CatchupColors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Gothic'),
                          ),
                          Expanded(child: SizedBox()),
                          Text(
                            (goals == null || id == null)
                                ? '-'
                                : goals[goals.indexOf(Goal(id: id))]
                                        .endDate
                                        .year
                                        .toString() +
                                    '/' +
                                    goals[goals.indexOf(Goal(id: id))]
                                        .endDate
                                        .month
                                        .toString() +
                                    '/' +
                                    goals[goals.indexOf(Goal(id: id))]
                                        .endDate
                                        .day
                                        .toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Gothic'),
                          ),
                          SizedBox(width: 25),
                        ],
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 2.7,
                        child: comments == null
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : comments.length == 0
                                ? Center(
                                    child: Text(
                                      'Is Empty',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                )
                                : ListView.builder(
                                    itemCount: comments.length,
                                    itemBuilder: (listContext, index) {
                                      return  CommentWidget(
                                            value: comments[index].taskId ==
                                                null
                                                ? -1
                                                : values.containsKey(
                                                comments[index].taskId)
                                                ? values[comments[index].taskId]
                                                : -1,
                                            comment: comments[index],
                                            download: () {
                                              _startDownload(comments[index])
                                                  .then((value) {
                                                setState(() {
                                                  comments[index].taskId =
                                                      value;
                                                });
                                              });
                                            },
                                            like: () async {
                                              bool result = false;
                                              if (comments[index].youLiked) {
                                                result =
                                                await Goals.unlikeComment(
                                                    comments[index].id
                                                        .toString());
                                              } else {
                                                result =
                                                await Goals.likeComment(
                                                    comments[index].id
                                                        .toString());
                                              }
                                              if (result) {
                                                setState(() {
                                                  bool s = comments[index]
                                                      .youLiked;
                                                  s
                                                      ? comments[index]
                                                      .likesCount--
                                                      : comments[index]
                                                      .likesCount++;
                                                  comments[index].youLiked = !s;
                                                });
                                              }
                                            },
                                          );

                                    } ) ),
                      SizedBox(height: 15),
                      IgnorePointer(
                        ignoring:  (goals == null || id == null) ? true : goals[goals.indexOf(Goal(id: id))].status == 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            select == null
                                ? SizedBox()
                                : Expanded(
                              child: ListTile(
                                leading: Icon(
                                  Icons.file_copy,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  select.path.substring(
                                    select.path.lastIndexOf('/') + 1,
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: uploading
                                    ? LinearProgressIndicator(
                                  value: valueUpload.toDouble() / 100,
                                  backgroundColor: CatchupColors.gray,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      CatchupColors.orange),
                                )
                                    : SizedBox(),
                              ),
                            ),
                            SizedBox(width: 5),
                            IconButton(
                              onPressed: () async {
                                //add file
                                select = await FilePicker.getFile();
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              height: 40,
                              decoration: BoxDecoration(
                                color: CatchupColors.red,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _sendMessage();
                                },
                                child: Center(
                                  child: loadingSend ? CircularProgressIndicator()
                                  :Text(
                                    'SEND',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 25),
                          Expanded(
                            child: TextFormField(
                              readOnly:(goals == null || id == null) ? true : goals[goals.indexOf(Goal(id: id))].status == 2,
                              controller: controller,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gothic',
                              ),
                              decoration: InputDecoration(
                                hintText: (goals == null || id == null) ? 'Comment...' : goals[goals.indexOf(Goal(id: id))].status == 2 ?
                                'can not send after end goal' : 'Comment...',
                                contentPadding: const EdgeInsets.only(
                                  left: 1,
                                  bottom: 0,
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
                          SizedBox(width: 25),
                        ],
                      ),
                      SizedBox(height: 20),
                      if(widget.isAdmin)
                      Row(
                        children: [
                          SizedBox(width: 20,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowUsersListPage(taskId: widget.task.id,isTaskFinished: widget.isArchived,),
                                ),
                              );
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Review"),
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(width: 100,)
                        ],
                      ),
                        SizedBox(height: 20),

                    ],
                  ),
          ),
          MenuFloat(
            position: Offset(40, 40),
          ),
          if (widget.isAdmin)
            GestureDetector(
              onTap: () async {
                if (goals[location].status == 1) {
                  MultiData multi = await  Tasks.checkEnd(id);
                Global.usersPoll = multi.users;
                widget.task.completionPercentage = multi.complete == null ?
                widget.task.completionPercentage : multi.complete;

                goals[location].status = 2;
                  setState(() {});
                  if (Global.usersPoll != null) {
                    Global.index = 0;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FeedBackPageTask(Global.index, widget.task.id),
                        ));
                  }else{

                  }
                }
              },
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 35, horizontal: 10),
                  child: Text(
                    (goals != null && goals.length > 0 ) ?  goals[location].status == 1 ? 'END' : 'ENDED' : '-',
                    style: TextStyle(
                        color: CatchupColors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 35, horizontal: 10),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String message = controller.text;
    FlutterUploader uploader;
    setState(() {
      loadingSend = true;
    });
    if (select == null) {
      Comment comment =
          await Goals.addCommentWithoutFile(id.toString(), message);
      setState(() {
        controller.text = '';
        comments.insert(0, comment);
        loadingSend = false;
      });
    } else {
      setState(() {
        uploading = true;
        loadingSend = false;
      });
      uploader = await Goals.uploadFile(file: select, json: {
        'token': Global.user.token,
        'goal_id': id,
        'message': message
      });

      uploader.progress.listen((event) {
        setState(() {
          valueUpload = event.progress;
        });
      });

      uploader.result.listen((event) {
        if (event.statusCode == 200) {
          controller.text = '';
          select = null;
          uploading = false;
          Comment comment = Comment.fromJson(json.decode(event.response));
          setState(() {
            comments.insert(0, comment);
          });
        }
      });
    }
  }

  void _addGoal() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddGoalDialog(
        task: widget.task,
        onGoalCreated: (Goal goal) {
          goals.add(goal);
          id = goal.id;
          location = goals.indexOf(goal);
          _getComment(goal.id.toString());
        },
      ),
    );
  }

  Future<bool> getDownloader(Comment comment) async{

    var syncPath = _localPath+comment.file.substring(comment.file.lastIndexOf("/"));

    bool downloaded=await io.File(syncPath).exists();
    return downloaded;
  }
  Future<String> getPath(Comment comment) async{
    var syncPath = _localPath+comment.file.substring(comment.file.lastIndexOf("/"));
    return syncPath;
  }

  Future<String> _startDownload(Comment comment) async {
    print(comment.downloaded.toString()+"666666666666666666666666666666666666666666666");
    if(comment.downloaded  || (values.containsKey(comment.taskId) && values[comment.taskId] == 100)){
      if((values.containsKey(comment.taskId) && values[comment.taskId] == 100)){
        setState(() {
          comment.downloaded = true;
        });
      }
      OpenFile.open(comment.localPath);
    }else{
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      String taskId = await FlutterDownloader.enqueue(
        url: Urls.HOST + comment.file,
        savedDir: _localPath,
        showNotification: false, //todo majid
        openFileFromNotification: false,
      );
      values[taskId] = 0;
      /*comment.downloaded=true;*/
      return taskId;
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

//todo after start -> can dialog and delete

}
