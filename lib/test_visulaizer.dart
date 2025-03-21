/*
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> targets = List();

@override
void initState() {
  targets.add(
      TargetFocus(
          identify: "Target 1",
          keyTarget: keyButton,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                child: Container(
                  child:Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Titulo lorem ipsum",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                          style: TextStyle(
                              color: Colors.white
                          ),),
                      )
                    ],
                  ),
                )
            )
          ]
      )
  );

  targets.add(
      TargetFocus(
          identify: "Target 2",
          keyTarget: keyButton4,
          contents: [
            TargetContent(
                align: ContentAlign.left,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Multiples content",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                          style: TextStyle(
                              color: Colors.white
                          ),),
                      )
                    ],
                  ),
                )
            ),
            TargetContent(
                align: ContentAlign.top,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Multiples content",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                          style: TextStyle(
                              color: Colors.white
                          ),),
                      )
                    ],
                  ),
                )
            )
          ]
      )
  );

  targets.add(
      TargetFocus(
          identify: "Target 3",
          keyTarget: keyButton5,
          contents: [
            TargetContent(
                align: ContentAlign.right,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Title lorem ipsum",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                          style: TextStyle(
                              color: Colors.white
                          ),),
                      )
                    ],
                  ),
                )
            )
          ]
      )
  );
}

void showTutorial(BuildContext context) {
  TutorialCoachMark(
    context,
    targets: targets, // List<TargetFocus>
    colorShadow: Colors.red, // DEFAULT Colors.black
    // alignSkip: Alignment.bottomRight,
    // textSkip: "SKIP",
    // paddingFocus: 10,
    // opacityShadow: 0.8,
    onClickTarget: (target){
      print(target);
    },
    onClickOverlay: (target){
      print(target);
    },
    onSkip: (){
      print("skip");
    },
    onFinish: (){
      print("finish");
    },
  )..show();
}*/
