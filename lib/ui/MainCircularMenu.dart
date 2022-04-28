import 'package:catchup/colors.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import 'ArcChooser.dart';

class MainCircularMenu extends StatefulWidget {
  @override
  _MainCircularMenuState createState() => _MainCircularMenuState();
}

class _MainCircularMenuState extends State<MainCircularMenu>
    with TickerProviderStateMixin {
  int slideValue = 200;
  int lastAnimPosition = 2;

  AnimationController animation;

  double location = -Global.screenSize.width - 30;

  @override
  void initState() {
    super.initState();

    animation = new AnimationController(
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 400.0,
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    animation.animateTo(slideValue.toDouble());
  }

  void _close() {
    setState(() {
      if (location == -Global.screenSize.width - 30) {
        location = -190;
      } else {
        location = -Global.screenSize.width - 30;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).copyWith().size.width /* / 1.2*/,
      height: MediaQuery.of(context).copyWith().size.height,
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            duration: Duration(milliseconds: 150),
            right: location,
            child: Center(
              child: ArcChooser()
                ..onItemClicked = () {
                  _close();
                }
                ..arcSelectedCallback = (int pos, ArcItem item) {
                  int animPosition = pos - 2;
                  if (animPosition > 3) {
                    animPosition = animPosition - 4;
                  }

                  if (animPosition < 0) {
                    animPosition = 4 + animPosition;
                  }

                  if (lastAnimPosition == 3 && animPosition == 0) {
                    animation.animateTo(4 * 100.0);
                  } else if (lastAnimPosition == 0 && animPosition == 3) {
                    animation.forward(from: 4 * 100.0);
                    animation.animateTo(animPosition * 100.0);
                  } else if (lastAnimPosition == 0 && animPosition == 1) {
                    animation.forward(from: 0.0);
                    animation.animateTo(animPosition * 100.0);
                  } else {
                    animation.animateTo(animPosition * 100.0);
                  }

                  lastAnimPosition = animPosition;
                },
            ),
          ),
          Positioned(
            right: -25,
            top: MediaQuery.of(context).copyWith().size.height / 2 - 25,
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                _close();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CatchupColors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
