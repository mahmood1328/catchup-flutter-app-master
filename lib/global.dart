import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'models/user.dart';

class Global {
  static User user;
  static Map profile;
  static Size screenSize;
  static bool isFirstFloatingMenuInit=true;

  static String firebaseToken;

  static String currentChattingUsername;

  static StreamController<Map> chatStreamController = StreamController<Map>();
  static Stream<Map> updateChat = chatStreamController.stream.asBroadcastStream();

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  static StreamController<String> updateProcessController = StreamController<String>();
  static Stream<String> updateProcess = updateProcessController.stream.asBroadcastStream();


  static StreamController<String> clearChatNumberController = StreamController<String>();
  static Stream<String> clearChatNumber = clearChatNumberController.stream.asBroadcastStream();

  //for poll
  static int index = -1;
  static List<User> usersPoll;

  //
  static bool increeseChatNumber=true;


}
