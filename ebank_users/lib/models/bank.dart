class Bank {
  final int id;
  final String bankName;
  final String address;
  final String documents;
  final int user;
  final String status;

  Bank({
    required this.id,
    required this.bankName,
    required this.address,
    required this.documents,
    required this.user,
    required this.status,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      bankName: json['bank_name'],
      address: json['address'],
      documents: json['documents'],
      user: json['user'],
      status: json['status'],
    );
  }
}
