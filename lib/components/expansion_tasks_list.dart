import 'dart:async';
import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/goals.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/goal.dart';
import 'package:catchup/models/json/TaskWithGoal.dart';
import 'package:catchup/models/project.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/ui/AddGoalDialog.dart';
import 'package:catchup/ui/AddTaskDialog.dart';
import 'package:catchup/ui/ErrorDialog.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:catchup/ui/LoadingSnackBar.dart';
import 'package:catchup/ui/SuccessSnackBar.dart';
import 'package:catchup/ui/editGoalDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:catchup/colors.dart';
import 'package:catchup/components/custom_expansion_tile.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:catchup/api/tasks.dart' as TaskApi;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ExpansionTasksList extends StatefulWidget {
  final Project project;
  final bool admin;

  ExpansionTasksList({this.project, this.admin});

  @override
  _ExpansionTasksListState createState() => _ExpansionTasksListState();
}

class _ExpansionTasksListState extends State<ExpansionTasksList> {
  List<Datum> _listTask;
  TextEditingController commentController;

  Offset position = Offset(40.0, 40.0);

  StreamSubscription subscription;

  bool coach = true;
  SharedPreferences sharedPreferences;
  List<int> loadingItems=[];
  static const _whiteTextStyle =
      const TextStyle(color: Colors.white, fontFamily: 'Gothic', fontSize: 14);

  void _addGoal(int id , BuildContext ccontext) {
    showDialog(
      context: ccontext,
      builder: (BuildContext context) => AddGoalDialog(
        task: Task(
          title: _listTask[id].title,
          completionPercentage: _listTask[id].completionPercentage,
          status: _listTask[id].status,
          description: _listTask[id].description,
          createdAt: _listTask[id].createdAt,
          id: _listTask[id].taskId,
          progressType: _listTask[id].progressType,
        ),
        onGoalCreated: (Goal goal) {
          if(_listTask[id].progressType == 2){
            showDialog(context: ccontext , builder: (context) => ErrorDialog(
              text: 'when choose manual , you must be add goals until sum of percent 100',
            ),);
          }
          setState(() {
            _listTask[id].goals.add(goal);
          });
        },
      ),
    );
  }

  void _editGoal(int id, Goal gg, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print(gg);
        return EditGoalDialog(
          task: Task(
            title: _listTask[id].title,
            completionPercentage: _listTask[id].completionPercentage,
            status: _listTask[id].status,
            description: _listTask[id].description,
            createdAt: _listTask[id].createdAt,
            id: _listTask[id].taskId,
            progressType: _listTask[id].progressType,
          ),
          goal: gg,
          onGoalCreated: (Goal goal) {
            setState(() {
              _listTask[id].goals[index] = goal;
            });
          },
        );
      },
    );
  }

  void _deleteGoal(int id, Goal gg, int index , BuildContext ccontext) {
    showDialog(
      context: ccontext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are You Sure?' , style: TextStyle(color: CatchupColors.red),),
          content: Container(
            height: 20,
              child: Text('you want delete this goal?' , style: TextStyle(color: Colors.white),)),
          backgroundColor: CatchupColors.black,
          actions: [
            GestureDetector(
              onTap: () async{
                Navigator.pop(context);
                try{
                  Scaffold.of(ccontext).showSnackBar(LoadingSnackBar('in progress...'));
                  await  Goals.delete(gg.id);
                  Scaffold.of(ccontext).hideCurrentSnackBar();
                  Scaffold.of(ccontext).showSnackBar(SuccessSnackBar('deleted successfully'));
                }on AuthException catch(e){
                  Scaffold.of(ccontext).hideCurrentSnackBar();
                  Scaffold.of(ccontext).showSnackBar(ErrorSnackBar(e.cause));
                }

                setState(() {
                  _listTask[id].goals.removeAt(index);
                });
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CatchupColors.red,
                ),
                padding: EdgeInsets.symmetric(vertical: 4 , horizontal: 6),
                child: Center(child: Text('Yes')),
              ),
            ),

            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CatchupColors.red,
                ),
                padding: EdgeInsets.symmetric(vertical: 4 , horizontal: 10),
                child: Center(child: Text('No')),
              ),
            ),
          ],
        );
      },
    );
  }

  getData() {
    if (_listTask != null && _listTask.length > 0) {
      _listTask.clear();
    }

    if (widget.admin) {
      TaskApi.Tasks.pendingAdmin(widget.project.id).then((value) {
        setState(() {
          _listTask = value;


        });
      });
    } else {
      TaskApi.Tasks.pending(widget.project.id).then((value) {

        setState(() {
          _listTask = value;
        });
      });
    }
  }

  GlobalKey target1 = GlobalKey();
  List<TargetFocus> targets = [];

  getShared() async{
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey('mark_pending_list')){
      coach = sharedPreferences.getBool('mark_pending_list');
    }
  }

  void showCoachMarkFAB() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = target1.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: target1.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Text("Tap on button\nto add a task",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
        });
  }

  @override
  void initState() {
    commentController = TextEditingController();
    getData();
    super.initState();

    Global.updateProcess.listen((event) {
      if (mounted) {
        getData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchupColors.black,
      body: Stack(
        children: [
          _listTask == null
              ? Align(
                  alignment: AlignmentDirectional.center,
                  child: CircularProgressIndicator(),
                )
              : Container(
                  color: CatchupColors.black,
                  child: (_listTask != null && _listTask.length > 0)
                      ? ListView.builder(
                          itemCount: _listTask.length,
                          padding: const EdgeInsets.all(20),
                          itemBuilder: (BuildContext context, int index) {
                            final EventList<Event> _markedDateMap =
                                EventList<Event>(
                              events: {},
                            );

                            for (Goal g in _listTask[index].goals) {
                              _markedDateMap.add(
                                g.endDate,
                                Event(
                                  date: g.endDate,
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomExpansionTile(
                                    initiallyExpanded: false,
                                    title: GestureDetector(
                                      onTap: () async {
                                        if (widget.admin) {
                                          await TaskApi.Tasks.seenAdmin(
                                              _listTask[index].taskId);
                                        }
                                      },
                                      child:
                                          (widget.admin && !_listTask[index].seen)
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      _listTask[index].title,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: 'Gothic',
                                                      ),
                                                    ),
                                                    Expanded(child: SizedBox()),
                                                    Icon(
                                                      Icons.notifications_active,
                                                      color: Colors.black,
                                                    )
                                                  ],
                                                )
                                              : Text(
                                                  _listTask[index].title,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Gothic',
                                                  ),
                                                ),
                                    ),
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 50),
                                        child: CalendarCarousel(
                                          customGridViewPhysics:
                                              NeverScrollableScrollPhysics(),
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
                                          markedDatesMap: _markedDateMap,
                                          showOnlyCurrentMonthDate: true,
                                          iconColor: Colors.white,
                                          daysTextStyle: _whiteTextStyle,
                                          weekendTextStyle: TextStyle(
                                            color: CatchupColors.red,
                                            fontFamily: 'Gothic',
                                          ),
                                          weekdayTextStyle: _whiteTextStyle,
                                          headerTextStyle: _whiteTextStyle,
                                          todayButtonColor: Colors.transparent,
                                          selectedDayButtonColor:
                                              Colors.transparent,
                                          selectedDateTime:
                                              _listTask[index].goals.length > 0
                                                  ? _listTask[index]
                                                      .goals[0]
                                                      .endDate
                                                  : DateTime.now(),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: SizedBox(
                                          height: (widget.admin
                                                  ? _listTask[index].goals.length *
                                                      40
                                                  : _listTask[index].goals.length *
                                                      33)
                                              .toDouble(),
                                          child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount:
                                                _listTask[index].goals.length,
                                            itemBuilder: (context, i) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: Row(
                                                  children: [
                                                    widget.admin
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _deleteGoal(
                                                                  index,
                                                                  _listTask[index]
                                                                      .goals[i],
                                                                  i , context);
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      shape: BoxShape
                                                                          .circle),
                                                              width: 20,
                                                              height: 20,
                                                              padding:
                                                                  EdgeInsets.all(5),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .trashAlt,
                                                                size: 10,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    widget.admin ?
                                                    SizedBox(width: 5,)
                                                    : SizedBox(),
                                                    widget.admin
                                                        ? GestureDetector(
                                                      onTap: () {
                                                        _editGoal(
                                                            index,
                                                            _listTask[index]
                                                                .goals[i],
                                                            i);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                        BoxDecoration(
                                                            color: Colors
                                                                .red,
                                                            shape: BoxShape
                                                                .circle),
                                                        width: 20,
                                                        height: 20,
                                                        padding:
                                                        EdgeInsets.all(5),
                                                        child: Icon(
                                                          FontAwesomeIcons
                                                              .pencilAlt,
                                                          size: 10,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                        : SizedBox(),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child:Text(
                                                          _listTask[index]
                                                              .goals[i]
                                                              .title,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.white,
                                                              fontFamily: 'Gothic'),
                                                          textAlign: TextAlign.left,
                                                        ),),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      _listTask[index]
                                                              .goals[i]
                                                              .endDate
                                                              .year
                                                              .toString() +
                                                          "/" +
                                                          _listTask[index]
                                                              .goals[i]
                                                              .endDate
                                                              .month
                                                              .toString() +
                                                          "/" +
                                                          _listTask[index]
                                                              .goals[i]
                                                              .endDate
                                                              .day
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontFamily: 'Gothic'),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,

                                      ),
                                      if (widget.admin)
                                        SizedBox(
                                          height:
                                              (_listTask[index].declines.length *
                                                      60)
                                                  .toDouble(),
                                          child: ListView.builder(
                                            itemCount:
                                                _listTask[index].declines.length,
                                            itemBuilder: (context, indexMessage) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: NetworkImage(Urls
                                                                  .HOST +
                                                              _listTask[index]
                                                                  .declines[
                                                                      indexMessage]
                                                                  .user
                                                                  .profileImage),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 25),
                                                    Expanded(
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'Gothic',
                                                        ),
                                                        decoration: InputDecoration(
                                                          hintText: _listTask[index]
                                                              .declines[
                                                                  indexMessage]
                                                              .message,
                                                          contentPadding:
                                                              const EdgeInsets.only(
                                                            left: 1,
                                                            bottom: 0,
                                                            right: 1,
                                                          ),
                                                          hintStyle: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                          border:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: CatchupColors
                                                                  .lightGray,
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: CatchupColors
                                                                  .gray,
                                                            ),
                                                          ),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: CatchupColors
                                                                  .lightGray,
                                                              width: 2,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      if (!widget.admin)
                                        TextFormField(
                                          controller: commentController,
                                          style: _whiteTextStyle,
                                          decoration: InputDecoration(
                                            hintText: 'Comment...',
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
                                      if (!widget.admin) SizedBox(height: 20),
                                      if (!widget.admin)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: CatchupColors.red,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  print("tap");
                                                  if(_listTask[index].goals.length == 0){
                                                    showDialog(context: context , builder: (context) => ErrorDialog(
                                                      text: 'task after have one or more goals can accepted',
                                                    ),);
                                                  }else {
                                                    TaskApi.Tasks.accept(
                                                        1,
                                                        _listTask[index].taskId,
                                                        commentController.text);
                                                    //  getData();
                                                    setState(() {
                                                      _listTask.removeAt(index);
                                                    });
                                                  }
                                                },
                                                child: Center(
                                                  child: Text(
                                                    'ACCEPT',
                                                    textAlign: TextAlign.center,
                                                    style: _whiteTextStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  TaskApi.Tasks.accept(
                                                      2,
                                                      _listTask[index].taskId,
                                                      commentController.text);
                                                  setState(() {
                                                    commentController.text = '';
                                                  });
                                                },
                                                child: Center(
                                                  child: Text(
                                                    'DECLINE',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Gothic',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (widget.admin)
                                        GestureDetector(
                                          onTap: () {
                                            _addGoal(index , context);
                                          },
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional.centerStart,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: CatchupColors.red,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'ADD GOAL',
                                                  textAlign: TextAlign.center,
                                                  style: _whiteTextStyle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                ),
                                  ),
                                  /*widget.admin?GestureDetector(
                                    child: Align(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          color: Colors.red,

                                        ),
                                        child: loadingItems.contains(index)?
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        ):
                                        Icon(Icons.delete_forever,size: 25,),
                                        height: 38,
                                        width: 38,
                                      ),

                                      alignment: Alignment.topRight,
                                    ),
                                    onTap: (){
                                      setState(() {
                                        loadingItems.add(index);
                                      });
                                      _deleteTask(_listTask[index].taskId,index);
                                    },
                                  ):SizedBox()*/
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "New Task Not found",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: "Gothic",
                            ),
                          ),
                        ),
                ),
          MenuFloat(position: position),
        ],
      ),
      floatingActionButton: widget.admin
          ?
      FloatingActionButton(
        heroTag: null,

        key: target1,
              onPressed: () {
                _addTask();
              },
              backgroundColor: CatchupColors.red,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
         : SizedBox(),
    );
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddTaskDialog(
        projectId: widget.project.id,
        onTaskCreated: (task) {
          getData();
        },
      ),
    );
  }
  void _deleteTask(int tskId,int index) async {


    try {
      await Tasks.delete(tskId,);

      setState(() {
        _listTask.remove(_listTask[index]);

      });


    } on SocketException {
//      _scaffoldKey.currentState
//          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
//      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
    setState(() {
      loadingItems.remove(index);

    });
  }
}
