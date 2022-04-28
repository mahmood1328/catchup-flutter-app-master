
import 'dart:developer';

import 'package:catchup/api/urls.dart';
import 'package:catchup/models/comment.dart';
import 'package:catchup/models/project.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import '../global.dart';
import 'auth.dart';

class Projects {

  static Future<List<Project>> all({bool isAdmin = false}) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "filter": isAdmin ? "admin" : "user",
    };

    http.Response response = await http.post(
      Urls.PROJECTS,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('result')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Project> projects = List();
    final List<dynamic> projectsData =
        body['result'] != null ? body['result'] : List();

    for (final project in projectsData) {
      projects.add(Project.fromJson(project));
    }

    return projects;
  }

  static Future<List<Project>> archive() async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
    };
    final response = await http.post(
      Urls.ARCHIVE_PROJECT,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('data')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Project> projects = List();
    final List<dynamic> projectsData =
    body['data'] != null ? body['data'] : List();

    for (final project in projectsData) {
      projects.add(Project.fromJson(project));
    }

    return projects;
  }

  static Future<int> add(
    String title,
    String description,
    List<String> users,
  ) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "project_info": {
        "title": title,
        "description": description,
        "user_list": users,
      },
    };

    final response = await http.post(
      Urls.ADD_PROJECT,
      body: json.encode(data),
    );


    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (!body.containsKey('project_id')) {
      throw AuthException("Unexpected error happend!");
    }

    return body['project_id'] as int;
  }

  static Future<void> delete(int projectId,) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "project_id": projectId,
    };

    final response = await http.post(
      Urls.DELETE_PROJECT,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }


    return ;
  }
  static Future<List<Comment>> comments(int projectId) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "project_id": projectId,
    };

    final response = await http.post(
      Urls.PROJECT_COMMENTS,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('comments')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Comment> comments = List();
    final List<dynamic> commentsData =
        body['comments'] != null ? body['comments'] : List();

    for (final comment in commentsData) {
      comments.add(Comment.fromJson(comment));
    }

    return comments;
  }

  static Future createComment(int projectId, String message) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "project_id": projectId,
      "message": message,
    };

    final response = await http.post(
      Urls.NEW_COMMENT,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }
  }
}
