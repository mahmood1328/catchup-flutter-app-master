import 'package:catchup/api/profile.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/components/custom_chart_paint.dart';
import 'package:catchup/components/menu_float.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/json/score.dart';
import 'package:catchup/ui/MyCircularPercentIndicator.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class FeedBackProfilePage extends StatefulWidget {

  final String username;

  FeedBackProfilePage({@required this.username});

  @override
  _FeedBackProfilePageState createState() => _FeedBackProfilePageState();
}

class _FeedBackProfilePageState extends State<FeedBackProfilePage> {
  List<dynamic> projects;

  List<Score> scores;

  List<double> time,
      efficiency,
      taskDelegation,
      follow,
      report,
      taskComp,
      work,
      overall;

  double timeS,
      efficiencyS,
      taskDelegationS,
      followS,
      reportS,
      taskCompS,
      workS,
      overallS;

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

  _getScores(String id) async {
    scores = await Profile.getDataSoccer(id , widget.username);

    time = [];
    efficiency = [];
    taskDelegation = [];
    follow = [];
    report = [];
    taskComp = [];
    work = [];
    overall = [];

    timeS = 0;
    efficiencyS = 0;
    taskDelegationS = 0;
    followS = 0;
    reportS = 0;
    taskCompS = 0;
    workS = 0;
    overallS = 0;

    if (scores != null) {
      for (Score s in scores) {
        double tempTime = s.timeManagement.toDouble() * 100 / 6;
        time.add(tempTime);
        timeS += tempTime;
        double tempEfficiency = s.efficiency.toDouble() * 100 / 6;
        efficiency.add(tempEfficiency);
        efficiencyS += tempEfficiency;
        double tempTaskDelegation = s.taskDelegation.toDouble() * 100 / 6;
        taskDelegation.add(tempTaskDelegation);
        taskDelegationS += tempTaskDelegation;
        double tempFollow = s.followUp.toDouble() * 100 / 6;
        follow.add(tempFollow);
        followS += tempFollow;
        double tempReport = s.reportUpdates.toDouble() * 100 / 6;
        report.add(tempReport);
        reportS += tempReport;
        double tempTaskComp = s.taskCompletion.toDouble() * 100 / 6;
        taskComp.add(tempTaskComp);
        taskCompS += tempTaskComp;
        double tempWork = s.workQuality.toDouble() * 100 / 6;
        work.add(tempWork);
        workS += tempWork;
        double tempOverall = s.overallScore.toDouble() * 100 / 6;
        overall.add(tempOverall);
        overallS += tempOverall;
      }

      print('overla' + overallS.toString());
    }

    if (!mounted) return;
    setState(() {});
  }

  _getData() async {
    try {
      projects = await Profile.getProjectSoccer(widget.username);

      if (projects.length > 0) {
        _getScores(projects[0]['project_id'].toString());
      } else {
        setState(() {});
      }
    }catch(_){}
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  Offset postion = Offset(40, 40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchupColors.black,
      appBar: AppBar(
        backgroundColor: CatchupColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body:
      Stack(children: [
        SafeArea(
          child: (time != null)
              ? scores == null
                  ? ListView(children: <Widget>[
                      SizedBox(height: 25),
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: MyCircularProgressIndicator(
                              value: 1,
                              strokeWidth: 7,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _getColor(overallS / overall.length / 100)),
                            ),
                          ),
                          Transform.rotate(
                            angle: 2 *
                                math.pi *
                                (overallS / overall.length / 100 + 0.03),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: MyCircularProgressIndicator(
                                value: math.max(
                                    0,
                                    (1 - overallS / overall.length / 100) -
                                        0.06),
                                strokeWidth: 7,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xff949595)),
                              ),
                            ),
                          ),
                          Text(
                            '${(overallS / overall.length).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _getColor(overallS / overall.length / 100),
                              fontFamily: 'Gothic',
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 50,
                          child: Stack(
                            alignment: AlignmentDirectional.topCenter,
                            children: <Widget>[
                              Container(
                                height: 4,
                                margin: EdgeInsets.only(top: 9),
                                color: Colors.white,
                              ),
                              projects == null
                                  ? SizedBox()
                                  : ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: projects.map((e) {
                                        return ItemCircel(e['project_id'],
                                            e['project_title']);
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                          'In Progress',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Gothic'),
                        ),
                      )
                    ])
                  : ListView(
                      children: <Widget>[
                        SizedBox(height: 25),
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: MyCircularProgressIndicator(
                                value: overallS / overall.length / 100,
                                strokeWidth: 7,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _getColor(overallS / overall.length / 100)),
                              ),
                            ),
                            Transform.rotate(
                              angle: 2 *
                                  math.pi *
                                  (overallS / overall.length / 100 + 0.03),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: MyCircularProgressIndicator(
                                  value: math.max(
                                      0,
                                      (1 - overallS / overall.length / 100) -
                                          0.06),
                                  strokeWidth: 7,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xff949595)),
                                ),
                              ),
                            ),
                            Text(
                              '${(overallS / overall.length).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color:
                                    _getColor(overallS / overall.length / 100),
                                fontFamily: 'Gothic',
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            height: 50,
                            child: Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: <Widget>[
                                Container(
                                  height: 4,
                                  margin: EdgeInsets.only(top: 9),
                                  color: Colors.white,
                                ),
                                projects == null
                                    ? SizedBox()
                                    : ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: projects.map((e) {
                                          return ItemCircel(e['project_id'],
                                              e['project_title']);
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),

                        //todo add data
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Time Management",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gothic'),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 180,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: CustomPaint(
                                      painter: CustomChart(
                                        data: time,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MyCircularProgressIndicator(
                                    value: timeS / time.length / 100,
                                    strokeWidth: 7,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColor(timeS / time.length / 100)),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 2 *
                                      math.pi *
                                      (timeS / time.length / 100 + 0.06),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: MyCircularProgressIndicator(
                                      value: math.max(
                                          0,
                                          (1 - timeS / time.length / 100) -
                                              0.12),
                                      strokeWidth: 7,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff949595)),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(timeS / time.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getColor(timeS / time.length / 100),
                                    fontFamily: 'Gothic',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Efficiency",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gothic'),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 180,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: CustomPaint(
                                      painter: CustomChart(
                                        data: efficiency,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MyCircularProgressIndicator(
                                    value:
                                        efficiencyS / efficiency.length / 100,
                                    strokeWidth: 7,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColor(efficiencyS /
                                            efficiency.length /
                                            100)),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 2 *
                                      math.pi *
                                      (efficiencyS / efficiency.length / 100 +
                                          0.06),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: MyCircularProgressIndicator(
                                      value: math.max(
                                          0,
                                          (1 -
                                                  efficiencyS /
                                                      efficiency.length /
                                                      100) -
                                              0.12),
                                      strokeWidth: 7,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff949595)),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(efficiencyS / efficiency.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getColor(
                                        efficiencyS / efficiency.length / 100),
                                    fontFamily: 'Gothic',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Task Delegation",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gothic'),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 180,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: CustomPaint(
                                      painter: CustomChart(
                                        data: taskDelegation,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MyCircularProgressIndicator(
                                    value: taskDelegationS /
                                        taskDelegation.length /
                                        100,
                                    strokeWidth: 7,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColor(taskDelegationS /
                                            taskDelegation.length /
                                            100)),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 2 *
                                      math.pi *
                                      (taskDelegationS /
                                              taskDelegation.length /
                                              100 +
                                          0.06),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: MyCircularProgressIndicator(
                                      value: math.max(
                                          0,
                                          (1 -
                                                  taskDelegationS /
                                                      taskDelegation.length /
                                                      100) -
                                              0.12),
                                      strokeWidth: 7,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff949595)),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(taskDelegationS / taskDelegation.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getColor(taskDelegationS /
                                        taskDelegation.length /
                                        100),
                                    fontFamily: 'Gothic',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Follow Up",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gothic'),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 180,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: CustomPaint(
                                      painter: CustomChart(
                                        data: follow,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MyCircularProgressIndicator(
                                    value: followS / follow.length / 100,
                                    strokeWidth: 7,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColor(
                                            followS / follow.length / 100)),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 2 *
                                      math.pi *
                                      (followS / follow.length / 100 + 0.06),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: MyCircularProgressIndicator(
                                      value: math.max(
                                          0,
                                          (1 - followS / follow.length / 100) -
                                              0.12),
                                      strokeWidth: 7,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff949595)),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(followS / follow.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getColor(
                                        followS / follow.length / 100),
                                    fontFamily: 'Gothic',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Report Updates",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gothic'),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 180,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: CustomPaint(
                                      painter: CustomChart(
                                        data: report,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MyCircularProgressIndicator(
                                    value: reportS / report.length / 100,
                                    strokeWidth: 7,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColor(
                                            reportS / report.length / 100)),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 2 *
                                      math.pi *
                                      (reportS / report.length / 100 + 0.06),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: MyCircularProgressIndicator(
                                      value: math.max(
                                          0,
                                          (1 - reportS / report.length / 100) -
                                              0.12),
                                      strokeWidth: 7,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff949595)),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(reportS / report.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getColor(
                                        reportS / report.length / 100),
                                    fontFamily: 'Gothic',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Task Completion",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gothic'),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 180,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: CustomPaint(
                                      painter: CustomChart(
                                        data: taskComp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MyCircularProgressIndicator(
                                    value: taskCompS / taskComp.length / 100,
                                    strokeWidth: 7,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColor(
                                            taskCompS / taskComp.length / 100)),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 2 *
                                      math.pi *
                                      (taskCompS / taskComp.length / 100 +
                                          0.06),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: MyCircularProgressIndicator(
                                      value: math.max(
                                          0,
                                          (1 -
                                                  taskCompS /
                                                      taskComp.length /
                                                      100) -
                                              0.12),
                                      strokeWidth: 7,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff949595)),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(taskCompS / taskComp.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getColor(
                                        taskCompS / taskComp.length / 100),
                                    fontFamily: 'Gothic',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Work Quality",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gothic'),
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 180,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: CustomPaint(
                                      painter: CustomChart(
                                        data: work,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MyCircularProgressIndicator(
                                    value: workS / work.length / 100,
                                    strokeWidth: 7,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColor(workS / work.length / 100)),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 2 *
                                      math.pi *
                                      (workS / work.length / 100 + 0.06),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: MyCircularProgressIndicator(
                                      value: math.max(
                                          0,
                                          (1 - workS / work.length / 100) -
                                              0.12),
                                      strokeWidth: 7,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xff949595)),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(workS / work.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getColor(workS / work.length / 100),
                                    fontFamily: 'Gothic',
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                        SizedBox(height: 25),
                      ],
                    )
              : (projects != null && projects.length == 0)
                  ? Center(
                      child: Text('is Empty'),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
        ),
        MenuFloat(
          position: postion,
        ),
      ]),
    );
  }

  Widget ItemCircel(int id, String name) {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _getScores(id.toString());
            },
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: CatchupColors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Text(
            name,
            style: TextStyle(
                fontFamily: 'Gothic', fontSize: 15, color: Colors.white),
          )
        ],
      ),
    );
  }
}
