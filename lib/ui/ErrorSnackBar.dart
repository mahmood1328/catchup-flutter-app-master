import 'package:catchup/colors.dart';
import 'package:flutter/material.dart';

class ErrorSnackBar extends SnackBar {
  final String text;

  ErrorSnackBar(this.text)
      : super(
          backgroundColor: CatchupColors.red,
          content: Text(
            text,
            style: TextStyle(
              fontFamily: 'Gothic',
              color: Colors.white,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        );
}
