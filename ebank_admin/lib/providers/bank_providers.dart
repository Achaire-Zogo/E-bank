import 'package:chatty/models/bank.dart';
import 'package:chatty/services/bank_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bankListProvider = FutureProvider<List<Bank>>((ref) async {
  return ref.read(bankApiProvider).fetchBanks();
});
