
import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/tasks.dart';
import 'package:catchup/models/user.dart';
import 'package:catchup/pages/feed_back_page_task.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../colors.dart';
import '../global.dart';



class ShowUsersListPage extends StatefulWidget {
  final int taskId;
  final bool isTaskFinished;
  const ShowUsersListPage({Key key, this.taskId,this.isTaskFinished}) : super(key: key);
  @override
  _ShowUsersListPageState createState() => _ShowUsersListPageState();
}

class _ShowUsersListPageState extends State<ShowUsersListPage> {
  List<User> usersList=[];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _loadTaskUsers() async {
    try {
      List<User> user = [];

      user = await Tasks.getTaskUsers(widget.taskId);
      print(user);
      setState(() {
        usersList = user;
      });
    } on SocketException {
      _scaffoldKey.currentState
          .showSnackBar(ErrorSnackBar("Connection refused!"));
    } on AuthException catch (e) {
      _scaffoldKey.currentState.showSnackBar(ErrorSnackBar(e.cause));
    }
  }
  @override
  void initState() {
    setState(() {
      /*usersList.add(User(firstName: "ali",lastName: "alavi",score: 3,username: "adsf"));
      usersList.add(User(firstName: "ali",lastName: "alavi",username: "adsf"));
      usersList.add(User(firstName: "ali",lastName: "alavi",score: 3,username: "adsf"));
      usersList.add(User(firstName: "ali",lastName: "alavi",score: 3,username: "adsf"));
      usersList.add(User(firstName: "ali",lastName: "alavi",username: "adsf"));
      print(Global.user.token);
      print(widget.taskId);
      print("#####");*/
      print(widget.taskId);
      print("#####");
      _loadTaskUsers();
      //todo get userlist from api

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CatchupColors.black,
      body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 90 ,left: 20),
              child: Text(
                  "User List",
                  style: TextStyle(
                  color: Colors.white, fontSize: 19))),
          FutureBuilder<String>(
             // async work
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting: return Text('Loading....');
                default:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  else
                    return Text('Result: ${snapshot.data}');
              }
            },
          ),
          /*Padding(
            padding: const EdgeInsets.only(top: 110 ),
            child: Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
              child: SingleChildScrollView(
                child: Wrap(
                  children:
                  usersList.map((user) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.height / 13,
                            height: MediaQuery.of(context).size.height / 13,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/profile.jpg')),
                                shape: BoxShape.circle),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.height / 18,),
                          Text(user.fullName),
                          Expanded(child: SizedBox(width: MediaQuery.of(context).size.height / 12,)),
                          widget.isTaskFinished?
                            (user.score!=null?
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

                                },
                                allowHalfRating: false,
                                initialRating: user.score.toDouble(),
                                itemSize: 25,
                                itemCount: 6,
                              ):
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                height: 30,
                                decoration: BoxDecoration(
                                  color: CatchupColors.red,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Global.usersPoll= [user];
                                    if (Global.usersPoll != null) {
                                      Global.index = 0;
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FeedBackPageTask(Global.index, widget.taskId),
                                          ));
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'SEND FEEDBACK',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ),
                              )):
                            SizedBox(),
                          Expanded(child: SizedBox())
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),*/
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
}
