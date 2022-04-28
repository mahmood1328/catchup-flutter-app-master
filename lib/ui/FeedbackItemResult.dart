import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../colors.dart';
import 'MyCircularPercentIndicator.dart';

class FeedbackItemResult extends StatefulWidget {
  final String title;
  final int star;

  const FeedbackItemResult({
    Key key,
    this.title,
    this.star,
  }) : super(key: key);

  @override
  _FeedbackItemResultState createState() => _FeedbackItemResultState();
}

class _FeedbackItemResultState extends State<FeedbackItemResult> {
  List<Widget> _getStars() {
    List<Widget> list = new List();

    for (int i = 0; i < widget.star; i++) {
      list.add(Icon(
        FontAwesomeIcons.check,
        color: CatchupColors.red,
      ));

      list.add(SizedBox(width: 10));
    }

    for (int i = 0; i < 6 - widget.star; i++) {
      list.add(Icon(
        FontAwesomeIcons.times,
        color: Colors.white,
      ));

      list.add(SizedBox(width: 10));
    }

    return list;
  }

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gothic',
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: _getStars(),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: MyCircularProgressIndicator(
                  value: widget.star / 6,
                  strokeWidth: 4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_getColor(widget.star / 6)),
                ),
              ),
              Transform.rotate(
                angle: 2 * math.pi * (widget.star / 6 + 0.03),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: MyCircularProgressIndicator(
                    value: math.max(0, (1 - widget.star / 6) - 0.06),
                    strokeWidth: 4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xff949595)),
                  ),
                ),
              ),
              Text(
                '${widget.star * 100 ~/ 6}%',
                style: TextStyle(
                  color: _getColor(widget.star / 6),
                  fontFamily: 'Gothic',
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
