
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../colors.dart';

class ConnectionRefusedDialog extends StatefulWidget {
  @override
  _ConnectionRefusedDialogState createState() => _ConnectionRefusedDialogState();
}

class _ConnectionRefusedDialogState extends State<ConnectionRefusedDialog> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(15.0),
              height:MediaQuery.of(context).size.height/2.7,

              decoration: ShapeDecoration(
                  color: CatchupColors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0))),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: SizedBox()),
                      InkWell(
                          onTap: (){
                            SystemNavigator.pop();

                          },
                          child: Icon(Icons.close,color: CatchupColors.black,)),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/30,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/nosignal.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/30,
                  ),
                  Text(
                      "Please check your internet connection and try again",
                      style: TextStyle(color: CatchupColors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/30,
                  ),
                  GestureDetector(
                    onTap: (){
                      SystemNavigator.pop();

                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height/28,
                      width: MediaQuery.of(context).size.width/6,
                      decoration: BoxDecoration(
                       // color: Colors.white,

                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: CatchupColors.black),
                      ),
                      child: Center(child: Text("Ok",style: TextStyle(color: CatchupColors.black),)),
                    ),
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
}
