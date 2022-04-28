import 'dart:io';

import 'package:catchup/global.dart';

class Chat {
  final int id;
  final String sender;
  final String receiver;
  final String message;
  final bool sent;
  final bool seen;
  final DateTime dateTime;
  final String file;
  final File localFile;

  final String profile;

  Chat(
    this.id,
    this.sender,
    this.receiver,
    this.message, {
    this.sent = false,
    this.seen = false,
    this.dateTime,
    this.file,
    this.localFile,
        this.profile
  });

  bool get isMe {
    return Global.user.username == this.sender;
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    final Map chatInfo = json['chat_info'];

    bool sent = false;
    bool seen = false;
    String dateTimeString = DateTime.now().toString();

    if (chatInfo['sent'] == 1 || chatInfo['sent'] == '1' || chatInfo['sent'] == true) {
      sent = true;
    } else if (chatInfo['sent'] == 0 || chatInfo['sent'] == '0' || chatInfo['sent'] == false) {
      sent = false;
    }

    if (chatInfo['seen'] == 1 || chatInfo['seen'] == '1' || chatInfo['seen'] == true) {
      seen = true;
    } else if (chatInfo['seen'] == 0 || chatInfo['seen'] == '0' || chatInfo['seen'] == false) {
      seen = false;
    }

    if (chatInfo['date_time'] != null) {
      dateTimeString = chatInfo['date_time'];
    }

    return Chat(
      json['chat_id'],
      chatInfo['sender'],
      chatInfo['receiver'],
      chatInfo['message'],
      sent: sent,
      seen: seen,
      dateTime: DateTime.tryParse(dateTimeString),
      file: json['file'],
    //  profile: chatInfo['profile_image']
    );
  }

  Map<String, dynamic> toJson() => {
    'chat_id': id,
    'sender': sender,
    'receiver': receiver,
    'message': message,
    'sent': sent == null ? false : (sent ? 1 : 0),
    'seen': seen == null ? false : (seen ? 1 : 0),
    'date_time': dateTime == null ? DateTime.now().toString() : dateTime.toString(),
    'file': file == null ? '' : file,
  };

  @override
  String toString() {
    return 'Chat{id: $id, sender: $sender, receiver: $receiver, message: $message, sent: $sent, seen: $seen, dateTime: $dateTime, file: $file, localFile: $localFile, profile: $profile}';
  }
}
