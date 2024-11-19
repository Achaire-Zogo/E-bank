import 'package:chatty/models/chatmessage.dart';
import 'package:chatty/models/user.dart';
import 'package:flutter/foundation.dart';

class Chat {
  int id;
  User user1;
  User user2;
  List<ChatMessage>? chatMessages;
  ChatMessage? lastMessage;

  Chat({
    required this.id,
    required this.user1,
    required this.user2,
  });

  factory Chat.fromJson(dynamic json) {
    if (kDebugMode) {
      print("chat : ${json['id']}");
    }
    Chat g = Chat(
        id: json['id'] as int,
        user1: User.fromJson(json['user1']),
        user2: User.fromJson(json['user2']));

    if (json["lastMessage"] != null) {
      g.lastMessage = ChatMessage.fromJson(json["lastMessage"]);
    }

    g.chatMessages = (json['ChatMessages'] as List<dynamic>)
        .map<ChatMessage>((json) => ChatMessage.fromJson(json))
        .toList();

    return g;
  }
}
