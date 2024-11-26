// ignore: file_names

class Urls {

  static const String ipAdress = "http://192.168.1.123";
  static const String userService = "$ipAdress:8085/api";
  // static const String bankService = "http://192.168.191.200:8086/BANK-SERVICE/api";
  static const String bankService = "$ipAdress:8086/api";
  static const String transactionService = "$ipAdress:8088/api";
  static const String transferService = "$ipAdress:8089/api";

  static const String login_ = "$userService/accounts/login/";
  static const String signup = "$userService/accounts/signup/";
  static const String verifyOtp = "$userService/accounts/verify_otp";
  static const String resendOtp = "$userService/accounts/resend_otp";
  //for bank
  static const String getBanks = "$bankService/bank/banks/";
  static const String getBankById = "$bankService/bank/banks/";
}
