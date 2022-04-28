import 'dart:async';

import 'package:catchup/models/project.dart';
import 'package:catchup/components/expansion_tasks_list.dart';
import 'package:catchup/ui/AddTaskDialog.dart';
import 'package:flutter/material.dart';
import 'package:catchup/pages/accpted_task_list.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../colors.dart';

class AcceptorTaskPage extends StatefulWidget {
  final Project project;
  final bool admin;

//  static StreamController<bool> streamController = StreamController();
 // static Stream<bool> streamListener = streamController.stream.asBroadcastStream();

  AcceptorTaskPage({@required this.project, this.admin = false});

  @override
  _AcceptorTaskPageState createState() => _AcceptorTaskPageState();
}

class _AcceptorTaskPageState extends State<AcceptorTaskPage> {

  GlobalKey target1 = GlobalKey();
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

  List<TargetFocus> targets = [];
  bool coach = true;
  SharedPreferences sharedPreferences;
  bool visible = true;
  TutorialCoachMark tutorialCoachMark;
  getShared() async{
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey('mark_pending_list')){
      coach = sharedPreferences.getBool('mark_pending_list');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await getShared();
      if(coach && widget.admin){
        targets.add(
          TargetFocus(
            identify: "Target 1",
            keyTarget: target1,
            contents: [
              TargetContent(
                  align: ContentAlign.top,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Add new Task",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "you can define new task for own project",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ),
        );

        await Future.delayed(Duration(seconds: 1));
        setState(() {
          tutorialCoachMark=TutorialCoachMark(
            context,
            targets: targets,
            textSkip: "SKIP",
            alignSkip: AlignmentDirectional.bottomStart,
            opacityShadow: 0.6,
            onFinish: () async {
              await sharedPreferences.setBool('mark_pending_list', false);
              setState(() {
                visible = false;
              });
            },
            onClickTarget: (target) {
              print('onClickTarget: $target');
            },
            onSkip: () async {
              await sharedPreferences.setBool('mark_pending_list', false);
              setState(() {
                visible = false;
              });
            },
            onClickOverlay: (target) {
              print('onClickOverlay: $target');
            },
          )..show();

        });

      }else{
        setState(() {
          visible = false;
        });
      }
    });
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
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: CatchupColors.darkRed,
            bottom: TabBar(
              indicatorColor: CatchupColors.red,
              labelStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Gothic',
              ),
              tabs: [
                Tab(text: 'Accepted'),
                Tab(text: 'Pending'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              AcceptedList(
                project: widget.project,
                admin: widget.admin,
              ),
              ExpansionTasksList(
                project: widget.project,
                admin: widget.admin,
              ),
            ],
          ),
          floatingActionButton: widget.admin
              ?
          Visibility(
            key: target1,
            visible: visible,
            child: FloatingActionButton(
              onPressed: () {
              },
              backgroundColor: CatchupColors.red,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )
              : SizedBox(),
        ),
      ),
    );
  }
}
