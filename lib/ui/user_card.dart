import 'dart:math' as math;

import 'package:catchup/colors.dart';
import 'package:catchup/pages/feedback_page.dart';
import 'package:catchup/ui/MyCircularPercentIndicator.dart';
import 'package:flutter/material.dart';

final _bgColors = [
  Colors.white,
//  Color(0xff4f4d4e),
//  Color(0xff666566),
//  Color(0xff909090),
//  Color(0xffa5a5a5),
];

//final _random = Random();

class UserCard extends StatelessWidget {
//  final _myBgColor = _bgColors[_random.nextInt(_bgColors.length)];
  final _myBgColor = Colors.white;

  final String title, imageUrl;
  final double value;
  final bool showAvatar, notification, isArchive;

  UserCard({
    this.title,
    this.imageUrl,
    this.value = 0.5,
    this.showAvatar = true,
    this.isArchive = false,
    this.notification = false,
  });

  Widget _getPercentWidget() {
    if (value < 0) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          width: 40,
          height: 40,
        ),
        Transform.rotate(
          angle: 2 * math.pi * (value + 0.03),
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(CatchupColors.red),
              backgroundColor: Color(0xff949595),
            ),
          ),
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            color: CatchupColors.red,
            fontFamily: 'Gothic',
            fontSize: 22,
          ),
        ),
      ],
    );
  }

  Widget _getAvatar() {
    if (!showAvatar) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          width: 60,
          height: 60,
          child: MyCircularProgressIndicator(
            value: 0.7,
            strokeWidth: 4,
            reversed: true,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff01d567)),
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageUrl == null
                  ? AssetImage('assets/profile.jpg')
                  : NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _myBgColor,
        border: Border.all(
          width: 3,
          color: CatchupColors.red,
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 10),
          _getAvatar(),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title == null ? 'Unnamed Project' : title,
              style: TextStyle(
                color: CatchupColors.gray,
                fontFamily: 'Gothic',
                fontSize: 17,
              ),
            ),
          ),

          if (notification)
            Icon(
              Icons.notifications_active,
              color: Colors.black,
            ),
          _getPercentWidget(),
       /*   if (isArchive)
            InkWell(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 , vertical: 10),
                  child: Icon(Icons.more_horiz_outlined)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedBackPageData(),
                    ));
              },
            ),*/
          SizedBox(width: 30),
          /*GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _myBgColor,
                border: Border.all(
                  width: 1,
                  color: CatchupColors.red,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text("Delete",style: TextStyle(fontSize: 15),),
              ),
            ),
            onTap: (){
              print("tapp");
            },
          ),*/


        ],
      ),
    );
  }
}
