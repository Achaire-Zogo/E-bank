import 'package:chatty/models/groupchat.dart';
import 'package:chatty/models/user.dart';
import 'package:dio2/dio2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:chatty/services/user_api_service.dart';

class GroupChatApiService {
  var url = 'http://${User.ipAdress}/api/chat';

  Future<List<GroupChat>> fetchGroupChats() async {
    Dio dio = Dio();
    final response = await dio.get('$url/groupchats/');

    return compute(parseGroupChats, response.data);
  }

  Future<GroupChat?> update(dynamic json) async {
    GroupChat? groupchat;
    Dio dio = Dio();
    try {
      Response response = await dio.post('$url/groupchats/${json.id}/',
          data: json,
          options: Options(
            contentType: "application/json; charset=utf-8",
            responseType: ResponseType.json,
            headers: {
              "X-Requested-With": "XMLHttpRequest",
              "X-CSRFToken": UserApiService.getCookie(
                  "csrftoken"), // don't forget to include the 'getCookie' function
            },
          ), onSendProgress: (int a, int b) {
        if (kDebugMode) {
          //print("a = $a, b = $b");
        }
      });

      dynamic data = response.data;

      groupchat = GroupChat.fromJson(data);
    } on Error catch (e) {
      //returns the error object if any
      if (kDebugMode) {
        print(e.stackTrace);
      }
    }
    return groupchat;
  }

  List<GroupChat> parseGroupChats(dynamic responseBody) {
    final parsed = responseBody["results"] as List<dynamic>;

    List<GroupChat> groupchats =
        parsed.map<GroupChat>((json) => GroupChat.fromJson(json)).toList();

    return groupchats;
  }
}

final groupChatApiProvider =
    Provider<GroupChatApiService>((ref) => GroupChatApiService());
