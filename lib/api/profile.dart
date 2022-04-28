
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:catchup/api/auth.dart';
import 'package:catchup/api/urls.dart';
import 'package:catchup/global.dart';
import 'package:catchup/models/json/score.dart';
import 'package:catchup/models/user.dart';
import 'package:http/http.dart' as http;

class Profile {
  static Future<List<dynamic>> getProjectSoccer(String username) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      'username' : username
    };

    final response = await http.post(
      Urls.VIEW_SOCCER_PROFILE,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);
    if (body['status_code'] != 200) {
      throw AuthException(body['error']);
    }
    final List<dynamic> result =
        body['result'] != null ? body['result'] : List();
    return result;
  }

  static Future<List<dynamic>> getDataSoccer(String id , String username) async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      'project_id': id,
      'username' : username
    };

    List<Score> scores;

    final response = await http.post(
      Urls.VIEW_SOCCER_PROFILE_DATA,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);
    try {
      final List<dynamic> result =
      body['result'] != null || body['result'] is List
          ? body['result']
          : List<Score>();

      for (var d in result) {
        if (d['scores']['time_management'] != null) {
          if (scores == null) {
            scores = <Score>[];
          }
          scores.add(Score.fromJson(d['scores']));
        }
      }
      return scores;
    }catch(_){
      return null;
    }
  }

  static Future<User> getUser() async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "search_by": "email",
      "email": Global.user.email,
    };

    final response = await http.post(
      Urls.PROFILE,
      body: json.encode(data),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);
    User user = User.fromJson(body['user_details']);

    return user;
  }

  static Future<void> setImageProfile(File file) async{

    Map<String , dynamic> data = {
       'token': Global.user.token
    };

    Map<String , dynamic> dataAll = {
      'data' : json.encode(data),
      'image' : base64Encode(file.readAsBytesSync())
    };

    final response = await http.post(
      Urls.SET_PROFILE_IMAGE,
      body: dataAll,
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

  }

  static Future<void> setProfile({String name , String email , String pass}) async{

    Map<String , dynamic> data = {
      'token': Global.user.token
    };

    if (name != null) {
      data['first_name'] = name;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (pass != null) {
      data['password'] = pass;
    }
    
    print(data);

    final response = await http.post(
      Urls.SET_PROFILE,
      body: json.encode(data),
    );


    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

  }
}
