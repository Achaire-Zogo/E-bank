import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constant/constant.dart';
import '../urls/Urls.dart';
import 'home.dart';
import 'login.dart';
import 'opt_screen.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _cniNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _cniNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      Dio dio = Dio();
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        Response response = await dio.post(
          Urls.signup,
          data: {
            "username": _usernameController.text,
            "cni_number": _cniNumberController.text,
            "email": _emailController.text,
            "password": _passwordController.text
          },
          options: Options(
            contentType: "application/json; charset=utf-8",
            responseType: ResponseType.json,
            headers: {
              "X-Requested-With": "XMLHttpRequest",
              "X-CSRFToken": Constant.getCookie("csrftoken"),
            },
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          
          // Extraire les données de la réponse
          final status = responseData['status'];
          final message = responseData['message'];
          final userData = responseData['user'];
          
          // Sauvegarder les données dans SharedPreferences
          await prefs.setString("token", userData['token']);
          await prefs.setInt("userId", userData['data']['id']);
          await prefs.setString("email", userData['data']['email']);
          await prefs.setString("username", userData['data']['username']);
          await prefs.setString("role", userData['data']['role']);
          await prefs.setString("status", userData['data']['status']);
          await prefs.setString("cni_number", userData['data']['cni_number']);

          if (kDebugMode) {
            print('Status: $status');
            print('Message: $message');
            print('Token: ${userData['token']}');
            print('User ID: ${userData['data']['id']}');
            print('Username: ${userData['data']['username']}');
            print('CNI Number: ${userData['data']['cni_number']}');
            print('Email: ${userData['data']['email']}');
            print('Verification Code: ${userData['data']['verification_code']}');
            print('Role: ${userData['data']['role']}');
            print('Status: ${userData['data']['status']}');
          }

          // Naviguer vers l'écran OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                email: userData['data']['email'],
                otp: userData['data']['verification_code'],
              ),
            ),
          );
        } else {
          setState(() {
            _loading = false;
          });
          EasyLoading.showError("An error occurred 200");
        }
      } on DioError catch (e) {
        setState(() {
          _loading = false;
        });
        if (e.response != null) {
          // Gérer les erreurs de réponse du serveur
          final errorMessage = e.response?.data['message'] ?? "An error occurred";
          EasyLoading.showError(errorMessage);
        } else {
          // Gérer les erreurs de connexion
          EasyLoading.showError("Connection error. Please check your internet connection.");
        }
      } catch (e) {
        setState(() {
          _loading = false;
        });
        EasyLoading.showError("An unexpected error occurred");
        if (kDebugMode) {
          print("Error: $e");
        }
      }
    } else {
      setState(() {
        _loading = false;
      });
      EasyLoading.showError("Please fill all fields correctly");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text("Register Now",
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _cniNumberController,
                    decoration: InputDecoration(
                      labelText: 'CNI Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a CNI number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      :MaterialButton(
                    shape: const StadiumBorder(),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading = !_loading;
                        });
                        register();
                      } else {
                        EasyLoading.showError("Remplissez tous les champs");
                      }
                    },
                    textColor: Colors.white,
                    color: Colors.blue,
                    height: 50,
                    minWidth: 600,
                    child: const SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Register Now",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                      );
                    },
                    child: const Text('Already have an account?'),
        
                  ),
                  const SizedBox(height: 20.0),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("OR"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          minimumSize: const Size(150, 50),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        icon: const Icon(Icons.account_balance),
                        label: const Text('Google'),
                        onPressed: () {
                          // Implémenter la connexion Google
                        },
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(150, 50),
                        ),
                        icon: const Icon(Icons.apple),
                        label: const Text('Apple'),
                        onPressed: () {
                          // Implémenter la connexion Apple
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
