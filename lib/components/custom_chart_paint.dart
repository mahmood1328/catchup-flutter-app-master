
import 'dart:ui';
import 'package:catchup/colors.dart';
import 'package:flutter/material.dart';

class CustomChart extends CustomPainter {

  final List<double> data;
  double topOffsetEnd;
  double drawingWidth;
  double drawingHeight;

  static const int NUMBER_OF_HORIZONTAL_LINES = 5;

  CustomChart({@required this.data});

  @override
  void paint(Canvas canvas, Size size) {

    final paintLine = new Paint()
      ..color = Colors.grey[500];
    paintLine.strokeWidth = 3;

    double distance = (size.width-30) / 10;
    double topOffset = (size.height-5) / 100;


    canvas.drawLine(Offset(30 , size.height-5), Offset(30, 0), paintLine);
    canvas.drawLine(Offset(30 , size.height-5), Offset(size.width, size.height-5), paintLine);

    ParagraphBuilder builder = new  ParagraphBuilder(
      new  ParagraphStyle(
        fontSize: 10.0,
        textAlign: TextAlign.right,
      ),
    );
    builder.addText('50');
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: 4));

    TextSpan span = new TextSpan(style: new TextStyle(   color: Colors.white, fontFamily: 'Gothic' , fontSize: 10), text: '%25' , );
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left , textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(5 ,((100-25)*topOffset)));

    TextSpan span50 = new TextSpan(style: new TextStyle(   color: Colors.white, fontFamily: 'Gothic' , fontSize: 10), text: '%50' , );
    TextPainter tp50 = new TextPainter(text: span50, textAlign: TextAlign.left , textDirection: TextDirection.ltr);
    tp50.layout();
    tp50.paint(canvas, new Offset(5 ,((100-50)*topOffset)));

    TextSpan span75 = new TextSpan(style: new TextStyle(   color: Colors.white, fontFamily: 'Gothic' , fontSize: 10), text: '%75' , );
    TextPainter tp75 = new TextPainter(text: span75, textAlign: TextAlign.left , textDirection: TextDirection.ltr);
    tp75.layout();
    tp75.paint(canvas, new Offset(5 ,((100-75)*topOffset)));

    TextSpan span100 = new TextSpan(style: new TextStyle(   color: Colors.white, fontFamily: 'Gothic' , fontSize: 10), text: '%100' , );
    TextPainter tp100 = new TextPainter(text: span100, textAlign: TextAlign.left , textDirection: TextDirection.ltr);
    tp100.layout();
    tp100.paint(canvas, new Offset(4 ,((100-100)*topOffset)));

    int max = data.length > 10 ? data.length : 10;
    for(int i = 0 ; i < max ; i++){

      if (i < data.length) {
        final paintLine = new Paint()
          ..color = Colors.grey[500];
        paintLine.strokeWidth = 2;

        Paint paint = Paint();
        if(data[i] <= 25){
          paint.color = CatchupColors.red;
        }else if(data[i] <= 50){
          paint.color = Color(0xffdf4900);
        }else if (data[i] <= 75){
          paint.color = Color(0xfffebd00);
        }else{
          paint.color =  Color(0xff01c501);
        }
        if (i < data.length-1) {
          canvas.drawLine(Offset((((i+1)*distance)+30) , (100 - data[i])*topOffset),
              Offset((((i+2)*distance)+30) , (100 - data[i+1])*topOffset),
              paintLine);
        }
        canvas.drawCircle(Offset(((i+1)*distance)+30, (100 - data[i])*topOffset), 4, paint);
      }

      TextSpan span = new TextSpan(style: new TextStyle(   color: Colors.white, fontFamily: 'Gothic'), text: '${i+1}');
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left , textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, new Offset(((i+1)*distance+30), size.height));
    }

  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;


}