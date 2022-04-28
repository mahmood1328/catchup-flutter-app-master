import 'package:flutter/material.dart';

class SuccessSnackBar extends SnackBar {
  final String text;

  SuccessSnackBar(this.text)
      : super(
          backgroundColor: Colors.green,
          content: Text(
            text,
            style: TextStyle(
              fontFamily: 'Gothic',
              fontSize: 15,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
}
