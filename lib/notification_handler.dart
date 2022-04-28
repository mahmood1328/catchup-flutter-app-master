import 'package:catchup/models/group_chat.dart';
import 'package:catchup/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:convert';

import 'global.dart';
import 'models/project.dart';
import 'navigation_service.dart';

class NotificationHandler {
  static final NotificationHandler _notificationHandler =
      NotificationHandler._internal();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationHandler() {
    return _notificationHandler;
  }

  NotificationHandler._internal();

  static Future initialize() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    var initializationSettings = InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: selectNotification
    );

  }

  static Future selectNotification(String payloadStr) async {


    Map valueMap = json.decode(payloadStr);

    print(valueMap);

    if(valueMap["type"]=="chatUser")
    {
      navService.pushNamed('/ChatPageUser', args: User(username: valueMap["username"],firstName:  valueMap["first_name"] ,lastName:  valueMap["last_name"]));
    }
    else if(valueMap["type"]=="chatGroup")
    {
      //todo set group id
      navService.pushNamed('/ChatPageGroup', args: GroupChat(null, valueMap["username"]));
    }
    else if(valueMap["type"]=="newTask")
      {
        navService.pushNamed('/AcceptorTaskPage', args: Project(id: int.parse(valueMap["id"]),title: valueMap["title"]));
      }
    if (payloadStr != null && payloadStr.isNotEmpty) {
      final Map payload = json.decode(payloadStr);

      if (payload != null) {
        if (payload.containsKey('user')) {
          final User contact = User.fromJson(payload['user']);

          /*await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondScreen(payload)),
          );*/
        }
      }
    }

    /*await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen(payload)),
    );*/
  }

  static Future onDidReceiveLocalNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    print('onDidReceiveLocalNotification');
  }

  static void showNotification(Map<String, dynamic>  message,int id, String title, String body,
      {Map<String, dynamic> payload}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );

    final String payloadStr = payload == null ? '{}' : json.encode(payload);
    String paloadTest="";

    if(message.containsKey("data") && message["data"]["task"]==null)
      {

        if(message["data"]["type"]=="private_chat")
          {
            String username=json.decode(message["data"]["sender"])["username"];
            paloadTest="{\"type\" : \"chatUser\", \"first_name\" : \"fname\",\"last_name\" : \"lname\",\"username\" : \"$username\" }";
          }
        else
          {
            String username=json.decode(message["data"]["group"])["username"];
            String name=json.decode(message["data"]["group"])["name"];
            paloadTest="{\"type\" : \"chatGroup\", \"username\" : \"$username\" , \"name\" : \"$name\"}";

          }
       }else
         {
           String id=json.decode(message["data"]["task"])["project"]["id"].toString();
           String title=json.decode(message["data"]["task"])["project"]["title"].toString();

           paloadTest="{\"type\" : \"newTask\", \"id\" : \"$id\" , \"title\" : \"$title\" }";
         }
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: paloadTest,
    );
  }
}
