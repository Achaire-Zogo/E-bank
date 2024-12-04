// ignore: file_names

class Urls {
  static const String serviceDtw = "http://192.168.1.122:8001";
  static const String serviceBank =
      "https://5d5e-129-0-174-81.ngrok-free.app/BANK-SERVICE";
  static const String serviceDemand = "http://192.168.1.157:32770";

  static const String userService = "$serviceDtw:8085/api";

  static const String accountService = "$serviceDtw:8001/api/";

  static const String login = "$accountService/login/";
  static const String signup = "$accountService/signup/";
  static const String verifyOtp = "$accountService/verify_otp";
  static const String resendOtp = "$accountService/resend_otp";
  //for bank
  //For dashboard
  static const String getBalanceAndHistoric =
      "$accountService/operations/user/";
}
