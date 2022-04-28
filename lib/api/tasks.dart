import 'dart:developer';

import 'package:catchup/api/urls.dart';
import 'package:catchup/models/json/TaskWithGoal.dart';
import 'package:catchup/models/task.dart';
import 'package:catchup/models/user.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import '../global.dart';
import 'auth.dart';

class Tasks {
  static Future<List<Task>> all(int projectId) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "project_id": projectId,
    };

    final response = await http.post(
      Urls.PROJECT_TASKS,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('tasks')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Task> tasks = List();
    final List<dynamic> tasksData =
        body['tasks'] != null ? body['tasks'] : List();

    for (final task in tasksData) {
      tasks.add(Task.fromJson(task));
    }

    return tasks;
  }

  static Future<Task> add(
    int projectId,
    String title,
    String description,
    List<String> users,
    int progressType,
  ) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "project_id": projectId,
      "task_info": {
        "title": title,
        "description": description,
        "acceptor_list": users,
        "progress_type": progressType,
        "status": 1,
      },
    };

    final response = await http.post(
      Urls.ADD_TASK,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (!body.containsKey('task_id')) {
      throw AuthException("Unexpected error happend!");
    }

    return Task.fromJson(body);
  }

  static Future<void> delete(int taskId,) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "task_id": taskId,
    };

    final response = await http.post(
      Urls.DELETE_TASK,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);



    return ;
  }

  static Future<List<Datum>> pending(int id) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "filter": "pending",
      "goals" : true,
      "project_id" : id
    };

    final response = await http.post(
      Urls.PENDING_TASK,
      body: json.encode(data),
    );


  /*  if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }*/

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('data')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Datum> tasks = List();
    final List<dynamic> tasksData =
    body['data'] != null ? body['data'] : List();

    for (final task in tasksData) {
      tasks.add(Datum.fromJson(task));
    }

    print("list Task" + tasks.toString());
    for(final i in tasks)
      print(i.title);
    return tasks;
  }

  static Future<List<Datum>> pendingAdmin(int id) async {
    print(id);
    print(Global.user.token);
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "filter": "pending",
      "project_id" : id
    };

    final response = await http.post(
      Urls.PENDING_TASK_ADMIN,
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

    if (!body.containsKey('data')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Datum> tasks = List();
    final List<dynamic> tasksData =
    body['data'] != null ? body['data'] : List();

    for (final task in tasksData) {
      tasks.add(Datum.fromJsonAdmin(task));
    }

    print("list Task" + tasks.toString());
    return tasks;
  }

  static Future<List<Task>> accepted(int id) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      'project_id' : id,
      'filter' : 'accepted'
    };

    final response = await http.post(
      Urls.PROJECT_TASKS_ACCEPTED,
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

    if (!body.containsKey('data')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<Task> tasks = List();
    final List<dynamic> tasksData =
    body['data'] != null ? body['data'] : List();

    for (final task in tasksData) {
      tasks.add(Task.fromJson(task));
    }

    return tasks;
  }

  static Future<List<Task>> acceptedAdmin(int id) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "project_id": id,
      "filter": "accepted"
    };

    final response = await http.post(
        Urls.PENDING_TASK_ADMIN,
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

    final List<Task> tasks = List();
    final List<dynamic> tasksData =
    body['data'] != null ? body['data'] : List();

    for (final task in tasksData) {
      tasks.add(Task.fromJson(task));
    }

    return tasks;
  }

  static Future<List<Task>> archive(int id) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "id": id,
    };

    final response = await http.post(
      Urls.ARCHIVE_PROJECT_TASK,
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

    final List<Task> tasks = List();
    final List<dynamic> tasksData =
    body['data'] != null ? body['data'] : List();

    for (final task in tasksData) {
      tasks.add(Task.fromJson(task));
    }

    return tasks;
  }

  static Future<dynamic> accept(
      int state,
      int taskId,
      String message,
      ) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "task_id": taskId,
      "state": state,
      "message": message
    };

    final response = await http.post(
      Urls.ACCEPT_TASK,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);
  }

  static Future<bool> seenAdmin(int taskId) async{
    bool result = false;

    Map<String , dynamic> data = {
      'task_id' : taskId,
      'token' : Global.user.token
    };

    final response = await http.post(
      Urls.PENDING_TASK_ADMIN_SEEN,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    //todo result from response
    return result;
  }

  static Future<MultiData> checkEnd(int task) async{

    List<User>  users = [];

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "id" : task
    };

    final response = await http.post(
      Urls.END_GOAL,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    Map<String , dynamic> body = json.decode(response.body);
    int status = body['task_info']['status'];
    double task_comp = body['task_info']['completion_percentage'];
    if (status == 0) {
      //user_list
      List<dynamic> usersList = body['task_info']['acceptor'];
      for(var u in usersList){
        users.add(User.fromJsonInfo(u));
      }
      return MultiData(users: users , complete: task_comp);
    } else{
      return  MultiData(complete: task_comp);
    }
  }

  static Future<List<User>> userOfPoll(int task) async{

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "id" : task
    };

    final response = await http.post(
      Urls.GET_USER_POLL,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    Map<String , dynamic> body = json.decode(response.body);
    final List<User> users = List();
    final List<dynamic> userData =
    body['data'] != null ? body['data'] : List();

    for (final u in userData) {
      users.add(User.fromJsonInfo(u));
    }

    return users;
  }


  static Future<void> sendPoll(String username , int task ,
  int valueTimeM  ,
  int valueEfficiency  ,
  int valueTaskDel  ,
  int valueFollow  ,
  int valueReport  ,
  int valueComTask  ,
  int valueQuality  ,
  int valueOverall  ,  
      ) async{

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "username": username,
      "task_id": task,
      "poll_data": {
        "time_management": valueTimeM,
        "efficiency": valueEfficiency,
        "task_delegation": valueTaskDel,
        "follow_up": valueFollow,
        "report_updates": valueReport,
        "task_completion": valueComTask,
        "work_quality": valueQuality,
        "overall_score": valueOverall
      }
    };

    final response = await http.post(
      Urls.SET_SOCCER,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }
  }

  static Future<List<User>> getTaskUsers(int taskId) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "id": taskId,
    };

    final response = await http.post(
      Urls.GET_USER_POLL,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    print(body);
    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('data')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<User> users = List();
    final List<dynamic> usersData =
    body['data'] != null ? body['data'] : List();

    for (final user in usersData) {
      if(user["score"]!=null)
        users.add(User.fromJson(user["user_info"],user["score"]["overall_score"]),);
      else
        users.add(User.fromJson(user["user_info"]),);

    }

    return users;
  }
}


class MultiData{

  List<User> users;
  double complete;

  MultiData({this.users, this.complete});
}
