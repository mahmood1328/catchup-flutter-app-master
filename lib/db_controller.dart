import 'dart:async';

import 'package:catchup/models/chat.dart';
import 'package:catchup/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBController {
  static Future<Database> database;

  static Future initialize() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'catchup_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE contacts(username TEXT PRIMARY KEY, first_name TEXT, last_name TEXT, profile_image TEXT)",
        );

        return db.execute(
          "CREATE TABLE chats(chat_id INTEGER PRIMARY KEY, sender TEXT, receiver TEXT, message TEXT, sent INTEGER, seen INTEGER, date_time TEXT, file TEXT)",
        );
      },
      version: 1,
    );
  }

  static Future<List<User>> contacts() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('contacts');

    return maps.map((u) => User.fromJson(u)).toList();
  }

  static Future<List<Chat>> privateChats(String username) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'chats',
      where: "sender = ? or receiver = ?",
      whereArgs: [username, username],
      orderBy: 'chat_id DESC',
    );

    return maps.map((c) {
      return Chat.fromJson({
        'chat_info': c,
        'chat_id': c['chat_id'],
        'file': c['file'],
      });
    }).toList();
  }

  static Future insertPrivateChat(Chat chat) async {
    final Database db = await database;

    await db.insert(
      'chats',
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future clearContacts() async {
    final Database db = await database;

    await db.delete('contacts');
  }

  static Future insertContact(User user) async {
    final Database db = await database;

    await db.insert(
      'contacts',
      user.toDBJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
