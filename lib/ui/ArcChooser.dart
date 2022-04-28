import 'dart:math';
import 'dart:ui';

import 'package:catchup/pages/ProfilePage.dart';
import 'package:catchup/pages/ProjectsListPage.dart';
import 'package:catchup/pages/UsersListPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../colors.dart';

class ArcChooser extends StatefulWidget {
  ArcSelectedCallback arcSelectedCallback;
  Function onItemClicked;

  @override
  State<StatefulWidget> createState() {
    return ChooserState(arcSelectedCallback);
  }
}

class ChooserState extends State<ArcChooser>
    with SingleTickerProviderStateMixin {
  var slideValue = 200;
  Offset centerPoint;

  double userAngle = 0.0;

  double startAngle;

  static double center = 270.0;
  static double centerInRadians = degreeToRadians(center);
  static double angle = 45.0;

  static double angleInRadians = degreeToRadians(angle);
  static double angleInRadiansByTwo = angleInRadians / 2;
  static double centerItemAngle = degreeToRadians(center - (angle / 2));
  List<ArcItem> arcItems;

  AnimationController animation;
  double animationStart;
  double animationEnd = 0.0;

  int currentPosition = 0;

  Offset startingPoint;
  Offset endingPoint;

  ArcSelectedCallback arcSelectedCallback;

  final _pages = [
    ProjectsListPage(), // Archive
    UsersListPage(), // Contact
    ProfilePage(), // Profile
    ProjectsListPage(isAdmin: true, createNew: true), // Add Project
    ProjectsListPage(isAdmin: true), // My Projects
    ProjectsListPage(isAdmin: true, createNew: true), // Add Project
    ProjectsListPage(isAdmin: true), // My Projects
    ProjectsListPage(), // Projects
  ];

  ChooserState(ArcSelectedCallback arcSelectedCallback) {
    this.arcSelectedCallback = arcSelectedCallback;
  }

  static double degreeToRadians(double degree) {
    return degree * (pi / 180);
  }

  static double radianToDegrees(double radian) {
    return radian * (180 / pi);
  }

  @override
  void initState() {
    arcItems = List<ArcItem>();

    arcItems.add(ArcItem("Add Project", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle));

    arcItems.add(ArcItem("My Projects", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle + (angleInRadians)));

    arcItems.add(ArcItem("Projects", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle + (2 * angleInRadians)));

    arcItems.add(ArcItem("Archive", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle + (3 * angleInRadians)));

    arcItems.add(ArcItem("Contact", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle + (4 * angleInRadians)));

    arcItems.add(ArcItem("Profile", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle + (5 * angleInRadians)));

    arcItems.add(ArcItem("Add Project", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle));

    arcItems.add(ArcItem("My Projects", [CatchupColors.red, CatchupColors.red],
        angleInRadiansByTwo + userAngle + (angleInRadians)));

    animation = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation.addListener(() {
      userAngle = lerpDouble(animationStart, animationEnd, animation.value);
      setState(() {
        for (int i = 0; i < arcItems.length; i++) {
          arcItems[i].startAngle =
              angleInRadiansByTwo + userAngle + (i * angleInRadians);
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double centerX = MediaQuery.of(context).size.width;
    double centerY = MediaQuery.of(context).size.height;

    centerPoint = Offset(centerX, centerY);

    return GestureDetector(
      onTap: () {
        // call on item clicked
        widget.onItemClicked();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _pages[currentPosition],
          ),
        );
      },
      onPanStart: (DragStartDetails details) {
        startingPoint = details.globalPosition;
        var deltaX = centerPoint.dx - details.globalPosition.dx;
        var deltaY = centerPoint.dy - details.globalPosition.dy;
        startAngle = atan2(deltaY, deltaX);
      },
      onPanUpdate: (DragUpdateDetails details) {
        endingPoint = details.globalPosition;
        var deltaX = centerPoint.dx - details.globalPosition.dx;
        var deltaY = centerPoint.dy - details.globalPosition.dy;
        var freshAngle = atan2(deltaY, deltaX);
        userAngle += freshAngle - startAngle;
        setState(() {
          for (int i = 0; i < arcItems.length; i++) {
            arcItems[i].startAngle =
                angleInRadiansByTwo + userAngle + (i * angleInRadians);
          }
        });
        startAngle = freshAngle;
      },
      onPanEnd: (DragEndDetails details) {
        //find top arc item with Magic!!
        bool rightToLeft = startingPoint.dy > endingPoint.dy;

//        Animate it from this values
        animationStart = userAngle;
        if (rightToLeft) {
          animationEnd += angleInRadians;
          currentPosition--;
          if (currentPosition < 0) {
            currentPosition = arcItems.length - 1;
          }
        } else {
          animationEnd -= angleInRadians;
          currentPosition++;
          if (currentPosition >= arcItems.length) {
            currentPosition = 0;
          }
        }

        if (arcSelectedCallback != null) {
          arcSelectedCallback(
              currentPosition,
              arcItems[(currentPosition >= (arcItems.length - 1))
                  ? 0
                  : currentPosition + 1]);
        }

        animation.forward(from: 0.0);
      },
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width , MediaQuery.of(context).size.height/2),
        painter: ChooserPainter(arcItems, angleInRadians),
      ),
    );
  }
}

// draw the arc and other stuff
class ChooserPainter extends CustomPainter {
  final blackPaint = new Paint()
    ..color = CatchupColors.black //0xFFF9D976
    ..strokeWidth = 1.0
    ..style = PaintingStyle.fill;

  List<ArcItem> arcItems;
  double angleInRadians;
  double angleInRadiansByTwo;
  double angleInRadians1;
  double angleInRadians2;
  double angleInRadians3;
  double angleInRadians4;

  ChooserPainter(List<ArcItem> arcItems, double angleInRadians) {
    this.arcItems = arcItems;
    this.angleInRadians = angleInRadians;
    this.angleInRadiansByTwo = angleInRadians / 2;

    angleInRadians1 = angleInRadians / 6;
    angleInRadians2 = angleInRadians / 3;
    angleInRadians3 = angleInRadians * 4 / 6;
    angleInRadians4 = angleInRadians * 5 / 6;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //common calc
    double centerX = size.width;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);
    double radius = sqrt((size.width * size.width) / 2);

    final double rr = 220;
    final double off = 70;

    //for black arc at bottom
    double leftX = centerX - rr - off;
    double topY = centerY - rr;
    double rightX = centerX + rr - off;
    double bottomY = centerY + rr;

    //for items
    double radiusItems = radius * 1.5;
    double leftX2 = centerX - radiusItems;
    double topY2 = centerY - radiusItems;
    double rightX2 = centerX + radiusItems;
    double bottomY2 = centerY + radiusItems;

    double radiusText = radius * 1.30;
    var arcRect = Rect.fromLTRB(leftX2, topY2, rightX2, bottomY2);

    var dummyRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int i = 0; i < arcItems.length; i++) {
      canvas.drawArc(
          arcRect,
          arcItems[i].startAngle,
          angleInRadians,
          true,
          new Paint()
            ..style = PaintingStyle.fill
            ..shader = new LinearGradient(
              colors: arcItems[i].colors,
            ).createShader(dummyRect));

      //Draw text
      TextSpan span = new TextSpan(
          style: new TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 25.0,
              fontFamily: 'Gothic',
              color: Colors.white),
          text: arcItems[i].text);
      TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      //find additional angle to make text in center
      double f = tp.width / 2;
      double t = sqrt((radiusText * radiusText) + (f * f));

      double additionalAngle = acos(
          ((t * t) + (radiusText * radiusText) - (f * f)) /
              (2 * t * radiusText));

      double tX = center.dx +
          radiusText *
              cos(arcItems[i].startAngle +
                  angleInRadiansByTwo -
                  additionalAngle); // - (tp.width/2);
      double tY = center.dy +
          radiusText *
              sin(arcItems[i].startAngle +
                  angleInRadiansByTwo -
                  additionalAngle); // - (tp.height/2);

      canvas.save();
      canvas.translate(tX, tY);
//      canvas.rotate(arcItems[i].startAngle + angleInRadiansByTwo);
      canvas.rotate(arcItems[i].startAngle +
          angleInRadians +
          angleInRadians +
          angleInRadiansByTwo);
      tp.paint(canvas, new Offset(0.0, 0.0));
      canvas.restore();
    }

    //shadow
//    Path shadowPath = new Path();
//    shadowPath.addArc(
//        Rect.fromLTRB(leftX3, topY3, rightX3, bottomY3),
//        ChooserState.degreeToRadians(180.0),
//        ChooserState.degreeToRadians(180.0));
//    canvas.drawShadow(shadowPath, Colors.black, 18.0, true);

    // bottom black arc
    canvas.drawArc(
        Rect.fromLTRB(leftX, topY, rightX, bottomY),
        ChooserState.degreeToRadians(180.0),
        ChooserState.degreeToRadians(360.0),
        true,
        blackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

typedef void ArcSelectedCallback(int position, ArcItem arcitem);

class ArcItem {
  String text;
  List<Color> colors;
  double startAngle;

  ArcItem(this.text, this.colors, this.startAngle);
}
