import 'package:catchup/colors.dart';
import 'package:flutter/material.dart';

class LoadingSnackBar extends SnackBar {
  final String text;

  LoadingSnackBar(this.text)
      : super(
          duration: const Duration(minutes: 1),
          backgroundColor: CatchupColors.gray,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Gothic',
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ],
          ),
        );
}
