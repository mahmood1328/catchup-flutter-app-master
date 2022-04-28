
import 'package:catchup/api/auth.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/chat.dart';
import 'package:catchup/models/group_chat.dart';
import 'package:catchup/models/user.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:path/path.dart';

class ChatsApi {
  static Future<List> chats() async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
    };

    final response = await http.post(
      Urls.CHATS,
      body: json.encode(data),
    );


    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('private_chat_users_info') ||
        !body.containsKey('group_chat_username_list')) {
      throw AuthException("Unexpected error happend!");
    }

    List<User> privateChats = List();
    for (final user in body['private_chat_users_info'] as List) {
      privateChats.add(User.fromJson(user));
    }
    print("*******");
    print(body['group_chat_username_list']);
    return [
      privateChats,
      body['group_chat_username_list'],
    ];
  }

  static Future<List> privateChats(String username) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "to_username": username,
    };

    final response = await http.post(
      Urls.PRIVATE_CHAT,
      body: json.encode(data),
    );

    print(response.body);
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('chat_data')) {
      throw AuthException("Unexpected error happend!");
    }

    List<Chat> chats = List();
    List chatData = body['chat_data'] == null ? List() : body['chat_data'];

    for (final chat in chatData) {
      chats.add(Chat.fromJson(chat));
    }

    return chats;
  }

  static Future<List> groupChats(String username) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "group_username": username,
    };

    final response = await http.post(
      Urls.GROUP_CHATS,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('group_chat_data')) {
      throw AuthException("Unexpected error happend!");
    }

    List<Chat> chats = List();
    List chatData = body['group_chat_data'] == null ? List() : body['group_chat_data'];

    for (final chat in chatData) {
      final c = Chat(
        chat['chat_id'],
        chat['sender']['username'],
        null,
        chat['message'],
        sent: chat['sent'] == null ? false : chat['sent'],
        seen: chat['seen'] == null ? false : chat['seen'],
        dateTime: DateTime.tryParse(chat['date_time']),
        file: chat['file'],
        profile: chat['sender']['profile_image']
      );

      chats.add(c);
    }
     return chats;
  }

  static Future<Chat> sendPrivateChat(Chat chat) async {
    Map<String , dynamic> msg ={
      "token": Global.user.token,
      "to_username": chat.receiver,
      "message": chat.message,
    };

    Map<String, String> data = {
      "data": json.encode(msg),
    };

    if (chat.localFile != null) {

      FlutterUploader uploader = FlutterUploader();

      final taskId = await uploader.enqueue(
        url:    Urls.SEND_PRIVATE_CHAT, //required: url to upload to
        files: [FileItem(filename: basename(chat.localFile.path)
            , savedDir: dirname(chat.localFile.path), fieldname:'files')], // required: list of files that you want to upload
        method: UploadMethod.POST, // HTTP method  (POST or PUT or PATCH)
        data: {"data": jsonEncode(msg)}, // any data you want to send in upload request
        showNotification: true, // send local notification (android only) for upload status
      );

      UploadTaskResponse response = await uploader.result.first;
      Chat c = Chat.fromJson(json.decode(response.response));
      return c;
    }else{
      final response = await http.post(
        Urls.SEND_PRIVATE_CHAT,
        body: data,
      );

      print(response.body);

      if (response.statusCode != 200) {
        throw AuthException("Unexpected error happend!");
      }

      final Map body = json.decode(response.body);

      if (body.containsKey('error')) {
        throw AuthException(body['error']['text']);
      }

      if (!body.containsKey('chat_info')) {
        throw AuthException("Unexpected error happend!");
      }

      return Chat.fromJson(body);
    }

  }

  static Future<GroupChat> createGroupChat(
      String name, List<User> members) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "group_info": {
        "name": name,
        "username": name,
        "description": "description",
        "user_list": members.map((u) => u.username).toList(),
      }
    };

    final response = await http.post(
      Urls.CREATE_GROUP_CHAT,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('group_info') || !body.containsKey('group_id')) {
      throw AuthException("Unexpected error happend!");
    }

    return GroupChat.fromJson(body);
  }

  static Future<Chat> sendGroupChat(String groupName, Chat chat) async {
    final msg = json.encode({
      "token": Global.user.token,
      "group_username": groupName,
      "message": chat.message,
    });

    Map<String, dynamic> data = {
      "data": msg,
    };

    if (chat.localFile != null) {
      final uploader = FlutterUploader();

      final taskId = await uploader.enqueue(
        url:    Urls.SEND_GROUP_CHAT, //required: url to upload to
        files: [FileItem(filename: basename(chat.localFile.path)
            , savedDir: dirname(chat.localFile.path), fieldname:'files')], // required: list of files that you want to upload
        method: UploadMethod.POST, // HTTP method  (POST or PUT or PATCH)
        data: {"data": msg}, // any data you want to send in upload request
        showNotification: true, // send local notification (android only) for upload status
      );

      UploadTaskResponse response = await uploader.result.first;
      final Map body = json.decode(response.response);
      if (body.containsKey('error')) {
        throw AuthException(body['error']['text']);
      }

      if (!body.containsKey('group_chat_info')) {
        throw AuthException("Unexpected error happend!");
      }

      final Map info = body['group_chat_info'];

      return Chat(
        null,
        info['sender'],
        null,
        info['message'],
        sent: info['sent'] == null ? false : info['sent'],
        seen: info['seen'] == null ? false : info['seen'],
        dateTime: DateTime.tryParse(info['date_time']),
        file: body['file'],
        // localFile: body['ff']
      );

    }else{
      final response = await http.post(
        Urls.SEND_GROUP_CHAT,
        body: data,
      );

      if (response.statusCode != 200) {
        throw AuthException("Unexpected error happend!");
      }

      final Map body = json.decode(response.body);

      if (body.containsKey('error')) {
        throw AuthException(body['error']['text']);
      }

      if (!body.containsKey('group_chat_info')) {
        throw AuthException("Unexpected error happend!");
      }

      final Map info = body['group_chat_info'];

      return Chat(
        null,
        info['sender'],
        null,
        info['message'],
        sent: info['sent'] == null ? false : info['sent'],
        seen: info['seen'] == null ? false : info['seen'],
        dateTime: DateTime.tryParse(info['date_time']),
        file: body['file'],
        // localFile: body['ff']
      );
    }
  }
}
