
import 'package:chatty/models/groupmessage.dart';



class GroupChat {
  int id;
  String name;
  String image;
  String description;
  List<GroupMessage>? groupMessages;

  GroupChat({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    GroupChat g = GroupChat(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
    );

    g.groupMessages = (json['GroupMessages'] as List<dynamic>)
        .map<GroupMessage>((json) => GroupMessage.fromJson(json))
        .toList();

    return g;
  }
}
