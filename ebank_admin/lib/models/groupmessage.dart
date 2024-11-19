

import 'package:chatty/models/user.dart';

class GroupMessage {
  int id;
  User user;
  String message;
  DateTime sendAt;

  GroupMessage({
    required this.id,
    required this.user,
    required this.message,
    required this.sendAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
        id: json['id'] as int,
        user: User.fromJson(json['user']),
        message: json['message'] as String,
        sendAt: DateTime.parse(json['send_at']));
  }
}
