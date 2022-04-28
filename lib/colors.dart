import 'dart:ui';

import 'package:flutter/scheduler.dart';

class CatchupColors {
  static var brightness = SchedulerBinding.instance.window.platformBrightness;
  static bool isDarkMode(){
    if(brightness == Brightness.dark)
      return true;
    return false;
  }
  void main() {
  }
  static  Color black = Color(0xff211f20);//white
  static  Color red = Color(0xfff04a32);
  static  Color darkRed = Color(0xffb8352b);
  static  Color gray = Color(0xff514f50);
  static  Color lightGray = Color(0xff757172);
  static  Color bgLightGray = Color(0xffc1c0c0);
  static  Color orange = Color(0xfff7901e);
  static  Color pink = Color(0xffffb3b3);
  static  Color mediumGray = Color(0xff939aa2);

  static void initialColosrs(){

    /*print(isDarkMode());
       black = isDarkMode()?Color(0xff211f20):Color(0xfff06a32);
       red = isDarkMode()?Color(0xfff04a32):Color(0xff211f20);
       darkRed = isDarkMode()?Color(0xffb8352b):Color(0xff211f20);*/
       /*gray = isDarkMode()?Color(0xff514f50);
       lightGray = isDarkMode()?Color(0xff757172);
       bgLightGray = isDarkMode()?Color(0xffc1c0c0);
       orange = isDarkMode()?Color(0xfff7901e);
       pink = isDarkMode()?Color(0xffffb3b3);
       mediumGray = isDarkMode()?Color(0xff939aa2);*/
  }
}
