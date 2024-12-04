import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../urls/Urls.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String otp;

  const OTPScreen({
    Key? key,
    required this.email,
    required this.otp,
  }) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int remainingTime = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (remainingTime == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  // Fonction pour vérifier l'OTP
  Future<void> verifyOTP() async {
    if (_otpController.text.length != 8) {
      setState(() {
        EasyLoading.showError("Le code OTP doit contenir 8 chiffres");
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (_otpController.text == widget.otp) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        EasyLoading.showError("Code OTP invalide");
        _otpController.clear(); // Effacer le champ pour une nouvelle tentative
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      EasyLoading.showError("Une erreur s'est produite");
    }
  }

  // Fonction pour renvoyer l'OTP
  Future<void> resendOTP() async {
    try {
      Dio dio = Dio();
      Response response = await dio.post(
        Urls.resendOtp,
        data: {
          "email": widget.email,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          remainingTime = 60;
        });
        startTimer();
        EasyLoading.showSuccess("Code OTP renvoyé");
      } else {
        EasyLoading.showError("Erreur lors du renvoi du code");
      }
    } catch (e) {
      EasyLoading.showError("Une erreur s'est produite");
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification OTP'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              SvgPicture.asset(
                'lib/resources/otp.svg',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 30),
              const Text(
                'Entrez le code de vérification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Nous avons envoyé un code à ${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: formKey,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: 'Code OTP',
                      hintText: 'Entrez le code à 8 chiffres',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "VÉRIFIER",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: remainingTime == 0 ? resendOTP : null,
                child: Text(
                  remainingTime == 0
                      ? "RENVOYER LE CODE OTP"
                      : "RENVOYER LE CODE OTP (${remainingTime}s)",
                  style: TextStyle(
                    color: remainingTime == 0 ? Colors.blue : Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}