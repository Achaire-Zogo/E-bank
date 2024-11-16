import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../urls/Urls.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  bool _loading = false;

  void test() {
    if (_formKey.currentState!.validate()) {
      login(_email, _password);
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  //fonction de login avec la BD
  void login(String email, String pass) async {
    // EasyLoading.show(status: AppLocalizations.of(context)!.load);
    var url = Uri.parse(Urls.login_);
    Dio dio = Dio();

    try {

      Response response = await dio.post(
        Urls.login_,
        data: {"username": email, "password": pass},
        options: Options(
          contentType: "application/json; charset=utf-8",
          responseType: ResponseType.json,
          headers: {
            "X-Requested-With": "XMLHttpRequest",
            // "X-CSRFToken": getCookie("csrftoken"),
          },
        ),
      );


      print(response.data);
      var data = jsonDecode(response.data);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {


      } else {
        setState(() {
          _loading = false;
        });
        EasyLoading.showError("An error occurred");
      }
    } on SocketException {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Verified Internet")));
    } catch (e) {
      setState(() {
        _loading = false;
      });
      EasyLoading.showError("An error occurred");
      // Gérer les erreurs
      if (e is DioError) {
        print("Erreur Dio : ${e.response?.data ?? e.message}");
      } else {
        print("Erreur inconnue : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset(
                  'lib/resources/logo.jpg',
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a username';
                    }
                  },
                  onSaved: (value) => _email = value!,
                  decoration: InputDecoration(hintText: 'Username'),
                ),
                TextFormField(
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    }
                  },
                  onSaved: (value) => _password = value!,
                  decoration: InputDecoration(hintText: 'Password'),
                ),
                const SizedBox(height: 30.0),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : MaterialButton(
                  shape: const StadiumBorder(),
                  onPressed: () {
                    setState(() {
                      _loading = !_loading;
                    });
                    test();
                  },
                  textColor: Colors.white,
                  color: Colors.blue,
                  height: 50,
                  minWidth: 600,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Login Now",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
