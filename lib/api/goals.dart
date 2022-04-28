
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:catchup/api/urls.dart';
import 'package:catchup/models/comment.dart';
import 'package:catchup/models/goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:path/path.dart';

import '../global.dart';
import 'auth.dart';

class Goals {
  static Future<List<Goal>> all(int taskId) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "task_id": taskId,
    };

    final response = await http.post(
      Urls.GOALS,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('goals')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Goal> goals = List();
    final List<dynamic> goalsData =
        body['goals'] != null ? body['goals'] : List();

    for (final goal in goalsData) {
      goals.add(Goal.fromJson(goal));
    }

    return goals;
  }

  static Future<Goal> add(
    int taskId,
    double percentage,
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final String sMonth = startDate.month.toString().padLeft(2, '0');
    final String sDay = startDate.day.toString().padLeft(2, '0');

    final String eMonth = endDate.month.toString().padLeft(2, '0');
    final String eDay = endDate.day.toString().padLeft(2, '0');

    final Map<String, dynamic> goalInfo = {
      "title": title,
      "description": description,
      "start_date": '${startDate.year}-$sMonth-$sDay',
      "end_date": '${endDate.year}-$eMonth-$eDay',
    };

    if (percentage != null) {
      goalInfo['ratio'] = percentage;
    }

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "task_id": taskId,
      "goal_info": goalInfo,
    };

    final response = await http.post(
      Urls.ADD_GOAL,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (!body.containsKey('goal_info')) {
      throw AuthException("Unexpected error happend!");
    }

    return Goal.fromJson(body['goal_info']);
  }

  static Future<Goal> update(
      int goal,
      double percentage,
      String title,
      String description,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final String sMonth = startDate.month.toString().padLeft(2, '0');
    final String sDay = startDate.day.toString().padLeft(2, '0');

    final String eMonth = endDate.month.toString().padLeft(2, '0');
    final String eDay = endDate.day.toString().padLeft(2, '0');

    final Map<String, dynamic> goalInfo = {
      "title": title,
      "description": description,
      "start_date": '${startDate.year}-$sMonth-$sDay',
      "end_date": '${endDate.year}-$eMonth-$eDay',
    };

    if (percentage != null) {
      goalInfo['ratio'] = percentage;
    }

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "goal_id": goal.toString(),
      "goal_info": goalInfo,
    };

    print(data);

    final response = await http.post(
      Urls.UPDATE_GOAL,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (!body.containsKey('goal_info')) {
      throw AuthException("Unexpected error happend!");
    }

    return Goal.fromJson(body['goal_info']);
  }

  static Future<String> addCommentWithFile(File file , String id , String message) async{
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "goal_id": id,
      "message" : message,
      "file" : base64Encode(file.readAsBytesSync()),
      'file_name' : basename(file.path)
    };

    final response = await http.post(
      Urls.ADD_FILE_GOAL,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    return body['goal_file'];
  }

  static Future<Comment> addCommentWithoutFile(String id , String message) async{

    Comment comment;

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "goal_id": id,
      "message" : message,
    };


    final formData = {
      'data' : jsonEncode(data),
    };

    final response = await http.post(
      Urls.ADD_COMMENT_GOAL,
      body: formData,
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);
    comment = Comment.fromJson(body);

    return comment;
  }

  static Future<List<Comment>> getComments(String id) async{
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "goal_id": id,
    };

    final response = await http.post(
      Urls.COMMENT_GOAL,
      body: json.encode(data),
    );


    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    final List<Comment> comments = List();

    final List<dynamic> commentData =
    body['comments'] != null ? body['comments'] : List();

    for (final goal in commentData) {
      comments.add(Comment.fromJson(goal));
    }

    return comments;
  }

  static Future<bool> likeComment(String id) async{

    bool like = false;

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "comment_id": id,
    };

    final response = await http.post(
      Urls.LIKE_COMMENT_GOAL,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);
    if (body['status_code'] == 200) {
      like = true;
    }

    return like;
  }

  static Future<bool> unlikeComment(String id) async{

    bool like = false;

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "comment_id": id,
    };

    final response = await http.post(
      Urls.UNLIKE_COMMENT_GOAL,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);
    if (body['status_code'] == 200) {
      like = true;
    }

    return like;
  }

  static Future<bool> delete(int id) async{
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "goal_id": id,
    };

    final response = await http.post(
      Urls.DELETE_GOAL,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    print(response.body);
    final Map body = json.decode(response.body);
    if (body['status_code'] == 200) {
      return body['done'];
    }else{
      throw AuthException(body['error']);
    }
  }



  static Future<FlutterUploader> uploadFile({File file ,Map<String , dynamic> json}) async {

    final uploader = FlutterUploader();

    final taskId = await uploader.enqueue(
        url:    Urls.ADD_COMMENT_GOAL, //required: url to upload to
        files: [FileItem(filename: basename(file.path)
            , savedDir: dirname(file.path), fieldname:'files')], // required: list of files that you want to upload
        method: UploadMethod.POST, // HTTP method  (POST or PUT or PATCH)
        data: {"data": jsonEncode(json)}, // any data you want to send in upload request
        showNotification: true, // send local notification (android only) for upload status
      ); // unique tag for upload task

//or return taskID
return uploader;
  }
}
