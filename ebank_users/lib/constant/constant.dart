import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebank_users/urls/Urls.dart';

class Constant {
  static Future<String?> getCookie(String name) async {
    try {
      final response = await Dio().get(Urls.userService);
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
}
