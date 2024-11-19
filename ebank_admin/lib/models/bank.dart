class Bank {
  int id;
  int user;
  String bank_name;
  String address;
  String documents;
  String status;

  Bank(
      {required this.id,
      required this.user,
      required this.bank_name,
      required this.address,
      required this.documents,
      required this.status});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
        id: json['id'] as int,
        user: json['user'] as int,
        bank_name: json['bank_name'] as String,
        address: json['address'] as String,
        documents: json['documents'] as String,
        status: json['status'] as String);
  }
}
