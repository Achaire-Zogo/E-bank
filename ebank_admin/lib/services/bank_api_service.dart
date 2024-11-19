import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio2/dio2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatty/models/user.dart';
import 'package:chatty/models/bank.dart';

var url = 'http://${User.ipAdress}:8086/api';

class BankApiService {
  Future<List<Bank>> fetchBanks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Dio dio = Dio();
    if (kDebugMode) {
      print('$url/bank/banks/');
    }
    final response = await dio.get(
      '$url/bank/banks/',
      options: Options(
        contentType: "application/json; charset=utf-8",
        responseType: ResponseType.json,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRFToken": getCookie("csrftoken"),
        },
      ),
    );

    return compute(parseBanks, response.data);
  }

  List<Bank> parseBanks(dynamic responseBody) {
    final parsed = responseBody["results"] as List<dynamic>;

    List<Bank> banks = parsed.map<Bank>((json) => Bank.fromJson(json)).toList();

    return banks;
  }

  List<Bank> parseUserBanks(dynamic responseBody) {
    final parsed = responseBody as List<dynamic>;

    List<Bank> banks = parsed.map<Bank>((json) => Bank.fromJson(json)).toList();

    return banks;
  }

  static Future<String?> getCookie(String name) async {
    try {
      final response = await Dio().get('$url/api');
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

  Future<void> changeStatusBank(int id, String status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final uri = Uri.parse('$url/bank/banks/$id/');
    if (kDebugMode) {
      print("changing status $uri");
    }
    var request = http.MultipartRequest("PATCH", uri);
    request.fields['status'] = status;
    request.headers.addAll({
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRFToken": "${getCookie("csrftoken")}",
    });
    var response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      if (kDebugMode) {
        print("success");
      }
    } else {
      if (kDebugMode) {
        print('Failed to validate bank: ${response.statusCode}');
      }
    }
  }

  Future<List<Bank>> UserBanks(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Dio dio = Dio();
    if (kDebugMode) {
      print('$url/bank/banks/user-banks/?user_id=$id');
    }
    final response = await dio.get(
      '$url/bank/banks/user-banks/?user_id=$id',
      options: Options(
        contentType: "application/json; charset=utf-8",
        responseType: ResponseType.json,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRFToken": getCookie("csrftoken"),
        },
      ),
    );

    return compute(parseUserBanks, response.data);
  }

  Future<Bank?> createBank(dynamic json, File document) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final uri = Uri.parse('$url/bank/banks/');
    var request = http.MultipartRequest("POST", uri);
    request.fields['bank_name'] = json['bank_name'];
    request.fields['address'] = json['address'];
    // Adding the document file
    request.files.add(
      await http.MultipartFile.fromPath(
        'documents', // This should match the field name expected by the backend
        document.path,
      ),
    );
    request.fields['user'] = json['user'];
    request.fields['status'] = 'VERIFIED';

    request.headers.addAll({
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Token ${prefs.getString("token")}",
      "X-CSRFToken": "${BankApiService.getCookie("csrftoken")}",
    });
    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseData);

      return Bank.fromJson(responseJson);
    } else {
      if (kDebugMode) {
        print('Failed to validate bank: ${response.statusCode}');
      }
      return null;
    }
  }

  Future<void> bankAccounts() async {}
  Future<void> activateAccount(Bank b, int id) async {}
}

final bankApiProvider = Provider<BankApiService>((ref) => BankApiService());
