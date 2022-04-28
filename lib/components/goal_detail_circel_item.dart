
import 'package:catchup/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GoalDetailCircleItem extends StatelessWidget{

  final bool active;
  final Widget child;
  final String date;
  final String id;

  final Function(String id) action;


  GoalDetailCircleItem({@required this.active , @required this.child , @required this.date , this.action , this.id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if (action != null) {
          action(id);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            !active ? SizedBox(height: MediaQuery.of(context).size.height/200,) : SizedBox(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: active ? MediaQuery.of(context).size.height/100 * 3 : MediaQuery.of(context).size.height/100 * 2,
                  height: active ? MediaQuery.of(context).size.height/100 * 3 : MediaQuery.of(context).size.height/100 * 2,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CatchupColors.red
                  ),
                  child: child,
                ),
              ],
            ),
            !active ? SizedBox(height: MediaQuery.of(context).size.height/100,) : SizedBox(height: MediaQuery.of(context).size.height/200),
            Text(date , style: TextStyle(color: Colors.white , fontFamily: 'Gothic' , fontSize: 8 , )),
          ],
        ),
      ),
    );
  }

}