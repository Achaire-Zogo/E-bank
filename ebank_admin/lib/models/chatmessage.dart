import 'package:chatty/models/user.dart';

class ChatMessage {
  int id;
  User user;
  int user1;
  int user2;
  int chat;
  String message;

  DateTime sendAt;

  ChatMessage({
    required this.id,
    required this.user,
    required this.user1,
    required this.user2,
    required this.chat,
    required this.message,

    required this.sendAt,

  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    ChatMessage msg = ChatMessage(
        id: json['id'] as int,
        user: User.fromJson(json['user']),
        user1: json["user1"] as int,
        user2: json["user2"] as int,
        chat: json['chat'] as int,
        message: json['message'] as String,
        sendAt: DateTime.parse(json['send_at']

        ));
    if(json['attachment']!=null){

    }

    return msg;

  }
}
