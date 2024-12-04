// ignore: file_names

class Urls {
  static const String baseUrl = "http://192.168.1.157:8079";
  static const String serviceDtw = "$baseUrl/SERVICE-DTW";
  static const String serviceBank = "$baseUrl/BANK-SERVICE";
  static const String serviceDemand = "$baseUrl/SERVICE-DEMAND";
  static const String serviceUserBankAccount =
      "$baseUrl/SERVICE-USER-BANK-ACCOUNT";
  static const String serviceUser = "$baseUrl/USER-SERVICE";
  static const String serviceNotification = "$baseUrl/SERVICE-NOTIFICATION";

  //Specifique Link For User
  static const String login = "$serviceUser/api/login/";
  static const String signup = "$serviceUser/api/signup/";
  static const String verifyOtp = "$serviceUser/api/verify_otp";
  static const String resendOtp = "$serviceUser/api/resend_otp";
  static const String userServiceCookie = "$serviceUser/api/users";
  //End Specifique

  //for bank
  //For dashboard
  static const String getBalanceAndHistoric = "$serviceUser/operations/user/";
}
