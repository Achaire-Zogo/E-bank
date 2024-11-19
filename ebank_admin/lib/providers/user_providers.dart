import 'package:chatty/models/user.dart';
import 'package:chatty/services/user_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userListProvider = FutureProvider<List<User>>((ref) async {
  return ref.read(userApiProvider).fetchUsers();
});
