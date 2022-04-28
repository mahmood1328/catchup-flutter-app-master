import 'dart:developer';

import 'package:catchup/api/urls.dart';
import 'package:catchup/models/user.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../global.dart';

class AuthException implements Exception {
  String cause;

  AuthException(this.cause);
}

class Auth {

  static Future updateFirebaseToken(String token) async {
    if (token == null || token.isEmpty || Global.user == null ||
        Global.user.token == null) {
      return;
    }else{

    }
  }

  static Future forgetPassword({String email}) async {
    final Map<String, dynamic> data = {
      "search_by": "email",
      "email" : email
    };

    final response = await http.post(
      Urls.FORGET_PASSWORD,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (!body.containsKey('data')) {
      throw AuthException("Unexpected error happend!");
    }

    if (!body[data]) {
      throw AuthException('server error');
    }
  }

  static Future<User> signup(User user) async {
    final Map<String, dynamic> data = {
      "user_info": user.toJson(),
    };

    final response = await http.post(
      Urls.SIGN_UP,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (!body.containsKey('user_added')) {
      throw AuthException("Unexpected error happend!");
    }

    final bool added = body['user_added'];

    if (!added) {
      throw AuthException(body['error']['text']);
    }

    return user;
  }

  static Future<User> login(User user) async {
    final Map<String, dynamic> data = {
      "search_by": "email",
      "email": user.email,
      "password": user.password,
    };

    final response = await http.post(
      Urls.LOGIN,
      body: json.encode(data),
    );

    log('error: $response');
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

    return User.fromJson(body['data']['user_details']);
  }

  static Future<User> google(String token) async {
    final Map<String, dynamic> data = {
      "token": token,
    };

    final response = await http.post(
      Urls.LOGIN_GOOGLE,
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

    return User.fromJson(body['data']['user_details']);
  }

  static Future<void> logOut() async{
    final Map<String, dynamic> data = {
      "token": Global.user.token,
    };

    final response = await http.post(
      Urls.LOG_OUT,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }
  }

  static Future<Map<String, dynamic>> profile({String username}) async {
    final Map<String, dynamic> data = username == null
        ? {
            "search_by": "email",
            "email": Global.user.email,
            "token": Global.user.token,
          }
        : {
            "search_by": "username",
            "username": username,
            "token": Global.user.token,
          };

    final response = await http.post(
      Urls.PROFILE,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('user_details')) {
      throw AuthException("Unexpected error happend!");
    }

  //  if (!body['user_details'].containsKey('token')) {
  //    throw AuthException("token unavailable");
  //  }

    return body['user_details'];
  }

  static Future<List<User>> search(String username) async {
    final Map<String, dynamic> data = {
      "username": username,
      "token": Global.user.token,
    };

    final response = await http.post(
      Urls.SEARCH_USERS,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('user_list')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<dynamic> result =
        body['user_list'] != null ? body['user_list'] : List();

    final List<User> users = result.map((x) {
      return User.fromJson(x);
    }).toList();

    return users;
  }

  static Future<bool> add(String username) async {
    final Map<String, dynamic> data = {
      "user_list": [username],
      "token": Global.user.token,
    };

    final response = await http.post(
      Urls.ADD_USER,
      body: json.encode(data),
    );


    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('contacts_added')) {
      throw AuthException("Unexpected error happend!");
    }

    return body['contacts_added'];
  }

  static Future<List<User>> users() async {
    final Map<String, dynamic> data = {
      "token": Global.user.token,
    };

    final response = await http.post(
      Urls.USERS,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (!body.containsKey('contacts')) {
      throw AuthException("Unexpected error happend!");
    }

    final List<User> users = List();
    final List<dynamic> result =
        body['contacts'] != null ? body['contacts'] : List();

    for (final user in result) {
      users.add(User.fromJson(user));
    }

    return users;
  }

  static Future<void> updateGoogle(String token) async{

    final Map<String, dynamic> data = {
      "token": Global.user.token,
      "firebase_token" : token
    };

    final response = await http.post(
      Urls.FIREBASE_UPDATE,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }

    final Map body = json.decode(response.body);

    if (body.containsKey('error')) {
      throw AuthException(body['error']['text']);
    }

    if (body['status_code'] == 200) {
    }

  }

  static Future<String> redirectBuy(String token , String type) async {
    final Map<String, dynamic> data = {
      "token": token,
       "type" : type 
    };

    http.Response res = await http.post(Urls.PAYMENT , body: json.encode(data));

    if (res.statusCode != 200) {
      throw AuthException("Unexpected error happend!");
    }
    final Map body = json.decode(res.body);

    if (body.containsKey('message')) {
      throw AuthException(body['message']);
    }

    if (body['status_code'] == 200) {
      return body['url'];
    }
    }
}
