import 'package:catchup/colors.dart';
import 'package:catchup/pages/ChatsTabsPage.dart';
import 'package:catchup/pages/ProjectsListPage.dart';
import 'package:catchup/pages/my_profile_page.dart';
import 'package:catchup/provider/NewChatProvider.dart';
import 'package:catchup/ui/AddProjectDialog.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import "package:catchup/my_flutter_app_icons.dart" as CustomIcon;
import 'package:catchup/icon_new_icons.dart' as IconApp;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:path/path.dart' as Path;
import '../global.dart';
import 'dart:developer';

// ignore: must_be_immutable
class MenuFloat extends StatefulWidget {
  Offset position;
  Key keyData;

  MenuFloat({@required this.position, this.keyData});

  @override
  _MenuFloatState createState() => _MenuFloatState();
}

class _MenuFloatState extends State<MenuFloat> {
  bool showData = true;
  Key target1 = GlobalKey();
  Key target2 = GlobalKey();
  Key target3 = GlobalKey();
  Key target4 = GlobalKey();
  Key target5 = GlobalKey();
  Key target6 = GlobalKey();
  int newChatNumber = 0;
  List<TargetFocus> targets = [];

  SharedPreferences sharedPreferences;
  TutorialCoachMark tutorialCoachMark;

  void _addProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext contextNew) =>
          AddProjectDialog(onProjectCreated: (_) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Container(
              height: 60,
              child: ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('Successfully added'),
              ),
            ),
          ),
        );
      }),
    );
  }

  getShare() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('mark_menu')) {
      showData = sharedPreferences.getBool('mark_menu');
    }
  }

  @override
  void initState() {
    init(context);
    getShare();
    super.initState();
  }

  void init(BuildContext context) {
    /* Global.updateChat.listen((Map message) {
      print(Global.increeseChatNumber.toString()+"^&^&^&");
      if(message.containsKey('notification')&& message["notification"]["body"]!=null)
      {  if(message["data"]["task"]==null)
          if(Global.increeseChatNumber)
            {
              if (mounted) {
                SharedPreferences.getInstance().then((pref) {
                  if(pref.getInt("newChatNumber")==null)
                    pref.setInt("newChatNumber", 1);
                  else
                    pref.setInt("newChatNumber", pref.getInt("newChatNumber")+1);
                  setState(() {
                    newChatNumber=pref.getInt("newChatNumber");
                    print(pref.getInt("newChatNumber"));
                  });
                  print(pref.getInt("newChatNumber").toString()+"************");
                });
              }
          }
      }

    });*/

    if (Global.isFirstFloatingMenuInit)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Global.isFirstFloatingMenuInit = false;
        var myModel = Provider.of<ChatModel>(context, listen: false);
        log('data: "init menu float"');
        myModel.setNewChatNumerFromPrefs();

        myModel.listenToStream();
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (tutorialCoachMark != null) tutorialCoachMark.finish();
        Navigator.pop(context);

        return false;
      },
      child: Consumer<ChatModel>(builder: (context, myModel, child) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: EdgeInsets.only(
                left: widget.position.dx, top: widget.position.dy),
            child: Draggable(
              feedback: Container(
                margin: EdgeInsets.only(left: 35, top: 35),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: CatchupColors.darkRed, shape: BoxShape.circle),
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              child: SizedBox(
                key: widget.keyData,
                height: 120,
                width: 120,
                child: CircularMenu(
                  toggleButtonOnPressed: () {
                    _callProcess(context);
                  },
                  radius: 50,
                  toggleButtonSize: 24,
                  alignment: Alignment.center,
                  toggleButtonColor: CatchupColors.red,
                  backgroundWidget: Container(
                    width: 30,
                    height: 30,
                  ),
                  items: [
                    CircularMenuItem(
                      enableBadge: myModel.newChatNumber == 0 ? false : true,
                      badgeColor: Colors.green,
                      badgeLabel: myModel.newChatNumber.toString(),
                      keyData: target1,
                      iconSize: 20,
                      icon: CustomIcon.MyFlutterApp.chat,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactsTabsPage(),
                          ),
                        );
                      },
                      color: CatchupColors.red,
                      iconColor: Colors.white,
                    ),
                    CircularMenuItem(
                      keyData: target2,
                      iconSize: 20,
                      icon: CustomIcon.MyFlutterApp.add,
                      onTap: () {
                        _addProject(context);
                      },
                      color: CatchupColors.red,
                      iconColor: Colors.white,
                    ),
                    CircularMenuItem(
                      keyData: target3,
                      iconSize: 20,
                      icon: CustomIcon.MyFlutterApp.archive,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectsListPage(
                                archive: true,
                              ),
                            ),
                            (route) => false);
                      },
                      color: CatchupColors.red,
                      iconColor: Colors.white,
                    ),
                    CircularMenuItem(
                      keyData: target4,
                      iconSize: 20,
                      icon: CustomIcon.MyFlutterApp.folder,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectsListPage(
                                isAdmin: true,
                              ),
                            ),
                            (route) => false);
                      },
                      color: CatchupColors.red,
                      iconColor: Colors.white,
                    ),
                    CircularMenuItem(
                      keyData: target5,
                      iconSize: 20,
                      icon: CustomIcon.MyFlutterApp.file,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectsListPage(
                                isAdmin: false,
                              ),
                            ),
                            (route) => false);
                      },
                      color: CatchupColors.red,
                      iconColor: Colors.white,
                    ),
                    CircularMenuItem(
                      keyData: target6,
                      iconSize: 20,
                      icon: IconApp.IconNew.man,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProfilePage(),
                          ),
                        );
                      },
                      color: CatchupColors.red,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ),
              childWhenDragging: SizedBox(child: Container()),
              onDragEnd: (details) {
                if (details.offset.dx > 0 &&
                    details.offset.dx < MediaQuery.of(context).size.width &&
                    details.offset.dy > 0 &&
                    details.offset.dy < MediaQuery.of(context).size.height) {
                  setState(
                    () {
                      widget.position = details.offset;
                    },
                  );
                }
              },
            ),
          ),
        );
      }),
    );
  }

  void _callProcess(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});

    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: target1,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "CHAT",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "This icon allows you to chat directly with the user.it has an option of both personal / direct chat or group chat.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 2",
        keyTarget: target2,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "ADD PROJECT",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "This icon allows you to add NEW PROJECTS along with the descriptions and the project acceptors.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 3",
        keyTarget: target3,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "ARCHIVE",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "This icon allows you to ARCHIVE THE TASK THAT HAS BEEN DONE",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 4",
        keyTarget: target4,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "MANAGE TASK FOLDER",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "This icon allows you to MANAGE AN EXISTING TASK FOR THE SPECIFIC ACCEPTOR.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 5",
        keyTarget: target5,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "NEW TASK FOLDER",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "This icon allows you to ADD NEW TASK TO THE USER and save it to the system ",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 6",
        keyTarget: target6,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "USER ACCOUNT PROFILE",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "This will show the basic information about the USER and other statistics",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );

    if (showData) {
      setState(() {
        tutorialCoachMark = TutorialCoachMark(
          context,
          targets: targets,
          textSkip: "SKIP",
          alignSkip: AlignmentDirectional.bottomStart,
          paddingFocus: 10,
          opacityShadow: 0.6,
          onFinish: () async {
            await sharedPreferences.setBool('mark_menu', false);
            showData = false;
          },
          onClickTarget: (target) {
            print('onClickTarget: $target');
          },
          onSkip: () async {
            await sharedPreferences.setBool('mark_menu', false);
            showData = false;
          },
          onClickOverlay: (target) {
            print('onClickOverlay: $target');
          },
        )..show();
      });
    }
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}
