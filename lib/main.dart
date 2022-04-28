import 'dart:io';
import 'dart:math';

import 'package:catchup/db_controller.dart';
import 'package:catchup/global.dart';
import 'package:catchup/notification_handler.dart';
import 'package:catchup/pages/ChatsPage.dart';
import 'package:catchup/pages/SplashPage.dart';
import 'package:catchup/pages/acceptor_tasks_page.dart';
import 'package:catchup/provider/NewChatProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

import 'colors.dart';
import 'navigation_service.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
 await FlutterDownloader.initialize(debug: true);
  await DBController.initialize();
  await NotificationHandler.initialize();

  Global.firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print(message);


      if (message.containsKey('notification')&& message["notification"]["body"]!=null) {


        final dynamic notification = message['notification'];
        NotificationHandler.showNotification(message,Random().nextInt(1000), notification['title'], notification['body']);

      }
      Global.chatStreamController.add(message);

      Global.updateProcessController.add('event');
    },
    onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
    onLaunch: (Map<String, dynamic> message) async {
      print(message);
      if (message.containsKey('notification') && message["notification"]["body"]!=null) {
        final dynamic notification = message['notification'];
        NotificationHandler.showNotification(message,Random().nextInt(1000), notification['title'], notification['body']);
      }
    },
    onResume: (Map<String, dynamic> message) async {
      if (message.containsKey('notification') && message["notification"]["body"]!=null) {
        final dynamic notification = message['notification'];
        NotificationHandler.showNotification(message,Random().nextInt(1000), notification['title'], notification['body']);
      }
    },
  );

  HttpOverrides.global = new MyHttpOverrides();
  runApp(CatchupApp());
}

class CatchupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    CatchupColors.initialColosrs();

    return ChangeNotifierProvider<ChatModel>(
      create: (_) => ChatModel(),
      child: MaterialApp(
        title: 'Catchup',
        navigatorKey: NavigationService.navigationKey,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => SplashPage());
            case '/ChatPageUser':
              return MaterialPageRoute(builder: (_) => ChatsPage(user: settings.arguments,isPrevPageChatsTabsPage:false));
            case '/ChatPageGroup':
              return MaterialPageRoute(builder: (_) => ChatsPage(group: settings.arguments,isPrevPageChatsTabsPage:false));
            case '/AcceptorTaskPage':
              return MaterialPageRoute(builder: (_) => AcceptorTaskPage(project: settings.arguments,admin: false,));

            default:
              return null;
          }
        },
        theme: ThemeData(
          textTheme: TextTheme(
            headline6: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white),
            headline4: TextStyle(color: Colors.white),
          ),
          primarySwatch: Colors.orange,
        ),
        home: SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
