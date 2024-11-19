import 'package:chatty/models/chat.dart';
import 'package:chatty/models/user.dart';
import 'package:chatty/services/user_api_service.dart';
import 'package:dio2/dio2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatApiService {
  final String url = 'http://${User.ipAdress}/api/chat';
  final Dio dio = Dio();

  Future<List<Chat>> fetchChats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await dio.get(
        '$url/chats',
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
        return parseChats(response.data);
      } else {
        if (kDebugMode) {
          print('Failed to fetch chats: ${response.statusCode}');
        }
        return [];
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
      return [];
    } on Error catch (e) {
      if (kDebugMode) {
        print('Error: ${e.stackTrace}');
      }
      return [];
    }
  }

  Future<Chat?> createChat(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await dio.get(
        '$url/chats/$id',
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
        return Chat.fromJson(response.data);
      } else {
        if (kDebugMode) {
          print('Failed to fetch chats: ${response.statusCode}');
        }
        return null;
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
      return null;
    } on Error catch (e) {
      if (kDebugMode) {
        print('Error: ${e.stackTrace}');
      }
      return null;
    }
  }

  List<Chat> parseChats(dynamic responseBody) {
    final parsed = responseBody as List<dynamic>;
    if (kDebugMode) {
      print(parsed.length);
    }
    List<Chat> chats = parsed.map<Chat>((json) => Chat.fromJson(json)).toList();
    return chats;
  }
}

final chatApiProvider = Provider<ChatApiService>((ref) => ChatApiService());
