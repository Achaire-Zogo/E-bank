class User {
  int id;
  String username;
  String email;
  String role;
  String cni_number;
  String status;

  static String ipAdress = "192.168.1.122";
  static User? user;
  User(
      {required this.id,
      required this.username,
      required this.email,
      required this.cni_number,
      required this.role,
      required this.status});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        cni_number: json['cni_number'] as String,
        role: json['role'] as String,
        status: json['status'] as String);
  }
}
