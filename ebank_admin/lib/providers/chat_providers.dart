import 'package:chatty/models/chat.dart';
import 'package:chatty/services/chat_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: non_constant_identifier_names
final chatListProvider = FutureProvider<List<Chat>>((ref) async {
  return ref.read(chatApiProvider).fetchChats();
});


