import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio2/dio2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatty/models/user.dart';

var url = 'http://${User.ipAdress}:8085/api';

class UserApiService {
  Future<List<User>> fetchUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Dio dio = Dio();
    dio.options.followRedirects = false;
    if (kDebugMode) {
      print('$url/accounts/users');
    }
    final response = await dio.get(
      '$url/accounts/users/',
      options: Options(
        contentType: "application/json; charset=utf-8",
        responseType: ResponseType.json,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "Authorization": "Token ${prefs.getString("token")}",
          "X-CSRFToken": UserApiService.getCookie("csrftoken"),
        },
      ),
    );

    return compute(parseUsers, response.data);
  }

  List<User> parseUsers(dynamic responseBody) {
    final parsed = responseBody["results"] as List<dynamic>;

    List<User> users = parsed.map<User>((json) => User.fromJson(json)).toList();

    return users;
  }

  static Future<String?> getCookie(String name) async {
    try {
      final response = await Dio().get('$url/api');
      List<Cookie> cookies = response.headers['set-cookie']!
          .toList()
          .map((string) => Cookie.fromSetCookieValue(string))
          .toList();

      for (Cookie cookie in cookies) {
        if (cookie.name == name) {
          return cookie.value;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(dynamic json) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user;
    Dio dio = Dio();

    try {
      if (kDebugMode) {
        print('data: $json');
      }

      var data = json as Map;
      Response response = await dio.post(
        '$url/accounts/login/',
        data: {"username": data["username"], "password": data["password"]},
        options: Options(
          contentType: "application/json; charset=utf-8",
          responseType: ResponseType.json,
          headers: {
            "X-Requested-With": "XMLHttpRequest",
            "X-CSRFToken": getCookie("csrftoken"),
          },
        ),
      );

      if (response.statusCode == 200) {
        prefs.clear();
        if (kDebugMode) {
          print(response.data);
        }
        prefs.setString("token", response.data["user"]["token"] ?? "");
        prefs.setInt("userId", response.data["user"]["data"]["id"]);
        prefs.setString("email", response.data["user"]["data"]["email"]);
        prefs.setString("username", response.data["user"]["data"]["username"]);
        prefs.setString(
            "cni_number", response.data["user"]["data"]["cni_number"]);
        prefs.setString("role", response.data["user"]["data"]["role"]);
        prefs.setString("status", response.data["user"]["data"]["status"]);

        dynamic data = response.data;
        if (kDebugMode) {
          print(data["user"]["data"]["email"]);
        }

        user = User.fromJson(data["user"]["data"]);
      } else {
        if (kDebugMode) {
          print('Failed to login: ${response.statusCode}');
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
        }
      } else {
        if (kDebugMode) {
          print('DioError: ${e.message}');
        }
      }
      user = null;
    } on Error catch (e) {
      if (kDebugMode) {
        print('Error: $e,${e.stackTrace} error 99');
      }
      user = null;
    }
    User.user = user;
    return user;
  }

  Future<User?> signUp(dynamic json) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Dio dio = Dio();
    User? user;

    try {
      Response response = await dio.post('$url/accounts/signup/',
          data: {
            'username': json["username"],
            'cni_number': json["cni_number"],
            'email': json["email"],
            'password': json["password"],
            'role': json["role"]
          },
          options: Options(
            contentType: "application/json; charset=utf-8",
            responseType: ResponseType.json,
            headers: {
              "X-Requested-With": "XMLHttpRequest",
              "X-CSRFToken": getCookie(
                  "csrftoken"), // don't forget to include the 'getCookie' function
            },
          ), onSendProgress: (int a, int b) {
        if (kDebugMode) {}
      });

      if (response.statusCode == 200) {
        prefs.clear();
        prefs.setString("token", response.data["user"]["token"] ?? "");
        prefs.setInt("userId", response.data["user"]["data"]["id"]);
        prefs.setString("email", response.data["user"]["data"]["email"]);
        prefs.setString("username", response.data["user"]["data"]["username"]);
        prefs.setString("role", response.data["user"]["data"]["role"]);

        dynamic data = response.data;
        if (kDebugMode) {
          print(data["user"]);
        }

        user = User.fromJson(data["user"]["data"]);
      } else {
        if (kDebugMode) {
          print('Failed to signup: ${response.statusCode}');
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
        }
      } else {
        if (kDebugMode) {
          print('DioError: ${e.message}');
        }
      }
      user = null;
    } on Error catch (e) {
      if (kDebugMode) {
        print('Error: $e,${e.stackTrace} error 99');
      }
      user = null;
    }
    User.user = user;
    return user;
  }

  Future<User?> fetchUser(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user;
    Dio dio = Dio();

    try {
      Response response = await dio.get(
        '$url/accounts/users/$id',
        options: Options(
          contentType: "application/json; charset=utf-8",
          responseType: ResponseType.json,
          headers: {
            "X-Requested-With": "XMLHttpRequest",
            "Authorization": "Token ${prefs.getString("token")}",
            "X-CSRFToken": UserApiService.getCookie("csrftoken"),
          },
        ),
      );

      if (response.statusCode == 200) {
        prefs.setInt("userId", response.data["user"]["data"]["id"]);
        prefs.setString("email", response.data["user"]["data"]["email"]);
        prefs.setString("username", response.data["user"]["data"]["username"]);
        prefs.setString("role", response.data["user"]["data"]["role"]);
        prefs.setString("status", response.data["user"]["data"]["status"]);

        dynamic data = response.data;
        if (kDebugMode) {
          print(data["user"]["data"]["email"]);
        }

        user = User.fromJson(data["user"]["data"]);
      } else {
        if (kDebugMode) {
          print('Failed to get user: ${response.statusCode}');
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
        }
      } else {
        if (kDebugMode) {
          print('DioError: ${e.message}');
        }
      }
      user = null;
    } on Error catch (e) {
      if (kDebugMode) {
        print('Error: $e,${e.stackTrace} error 99');
      }
      user = null;
    }
    User.user = user;
    return user;
  }
}

Future<void> changeStatusUser(int id, String status) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final uri = Uri.parse('$url/accounts/users/$id/');
  var request = http.MultipartRequest("PATCH", uri);
  request.fields['status'] = status;
  request.headers.addAll({
    "X-Requested-With": "XMLHttpRequest",
    "Authorization": "Token ${prefs.getString("token")}",
    "X-CSRFToken": "${UserApiService.getCookie("csrftoken")}",
  });
  var response = await request.send();

  if (response.statusCode == 200) {
    await response.stream.bytesToString();
  } else {
    if (kDebugMode) {
      print('Failed to change user status: ${response.statusCode}');
    }
  }
}

final userApiProvider = Provider<UserApiService>((ref) => UserApiService());
