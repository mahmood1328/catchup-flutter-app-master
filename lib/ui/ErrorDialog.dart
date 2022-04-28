import 'package:catchup/pages/payment_page.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class ErrorDialog extends StatefulWidget {
  final String text;

  const ErrorDialog({Key key, this.text}) : super(key: key);

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(50),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(widget.text ,style: TextStyle(color: Colors.black),),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, true);
               if (widget.text.contains('buy a plan')) {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => PaymentPage(),
                   ),
                 );
               }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                  color: CatchupColors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'OK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gothic',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
