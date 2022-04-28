import 'package:catchup/api/tasks.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/global.dart';
import 'package:catchup/pages/ProjectsListPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedBackPageTask extends StatefulWidget {
  final int index;
  final int task;

  FeedBackPageTask(this.index, this.task);

  @override
  _FeedBackPageTaskState createState() => _FeedBackPageTaskState();
}

class _FeedBackPageTaskState extends State<FeedBackPageTask> {
  int _valueTimeM = 0;
  int _valueEfficiency = 0;
  int _valueTaskDel = 0;
  int _valueFollow = 0;
  int _valueReport = 0;
  int _valueComTask = 0;
  int _valueQuality = 0;
  int _valueOverall = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchupColors.black,
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height / 5,
          width: MediaQuery.of(context).size.width,
          color: CatchupColors.red,
        ),
        Positioned(
            top: MediaQuery.of(context).size.height / 100 * 13,
            left: MediaQuery.of(context).size.width / 10,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.height / 10,
                  height: MediaQuery.of(context).size.height / 10,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/profile.jpg')),
                      shape: BoxShape.circle),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  Global.usersPoll[widget.index].username,
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Gothic', fontSize: 20),
                ),
              ],
            )),
        Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 3.2,
              left: 20,
              right: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Time Management',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueTimeM = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      'Efficiency',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueEfficiency = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      'Task Delegation',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueTaskDel = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      'Follow-up',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueFollow = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      'Report/Update',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueReport = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      'Completion of Task',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueComTask = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      'Quality of Work',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueQuality = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      'Overall Score',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gothic'),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    RatingBar(
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.check,
                          color: CatchupColors.red,
                          size: 20,
                        ),
                        half: null,
                        empty: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onRatingUpdate: (value) {
                        _valueOverall = value.toInt();
                      },
                      allowHalfRating: false,
                      initialRating: 0,
                      itemSize: 25,
                      itemCount: 6,
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      decoration: BoxDecoration(
                        color: CatchupColors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          //request poll save
                          await Tasks.sendPoll(
                              Global.usersPoll[Global.index].username,
                              widget.task,
                              _valueTimeM,
                              _valueEfficiency,
                              _valueTaskDel,
                              _valueFollow,
                              _valueReport,
                              _valueComTask,
                              _valueQuality,
                              _valueOverall);

                          Global.index++;

                          if (Global.index == Global.usersPoll.length) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectsListPage(),
                                ),
                                (route) => false);
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedBackPageTask(
                                      Global.index, widget.task),
                                ));
                          }
                        },
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Gothic'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectsListPage(),
                              ),
                                  (route) => false);
                        },
                        child: Center(
                          child: Text(
                            'LATER',
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
              ],
            ),
          ),
        )
      ]),
    );
  }
}
