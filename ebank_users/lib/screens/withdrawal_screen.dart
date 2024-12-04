import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../urls/Urls.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  bool isLoading = false;
  String? error;

  // Pour l'utilisateur connecté
  List<Map<String, dynamic>> myBanks = [];
  Map<String, dynamic>? selectedMyBank;

  // Pour le destinataire
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? selectedUser;

  List<Map<String, dynamic>> recipientBanks = [];
  Map<String, dynamic>? selectedRecipientBank;

  final TextEditingController amountController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id_user');
    if (userId != null) {
      fetchMyBanks();
      fetchUsers();
    }
  }

  Future<void> fetchMyBanks() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final dio = Dio();
      final response = await dio.get(
        "${Urls.serviceBank}/api/bank/banks/banks-user/?user=$userId",
      );

      if (response.data is List) {
        setState(() {
          myBanks = List<Map<String, dynamic>>.from(response.data)
              .where((bank) => bank['status'] == 'VERIFIED')
              .toList();
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement de vos banques';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final dio = Dio();
      // Remplacer par l'URL appropriée pour récupérer la liste des utilisateurs
      final response = await dio.get("${Urls.serviceDtw}/api/users");

      if (response.data is List) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response.data)
              .where((user) =>
                  user['id'].toString() !=
                  userId) // Exclure l'utilisateur actuel
              .toList();
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des utilisateurs';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRecipientBanks() async {
    if (selectedUser == null) return;

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final dio = Dio();
      final response = await dio.get(
        "${Urls.serviceBank}/api/bank/banks/banks-user/?user=${selectedUser!['id']}",
      );

      print(selectedUser);
      print("#################");
      print(response.data);

      if (response.data is List) {
        setState(() {
          recipientBanks = List<Map<String, dynamic>>.from(response.data)
              .where((bank) => bank['status'] == 'VERIFIED')
              .toList();
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des banques du destinataire';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> makeTransfer() async {
    if (selectedMyBank == null ||
        selectedUser == null ||
        selectedRecipientBank == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      print(selectedMyBank);
      print('@@@@@@@@@@@@@@@@@@@@');
      print("User" + selectedUser!['id'].toString());
      print("BankMY" + selectedMyBank!['id'].toString());
      print("BankRecever" + selectedRecipientBank!['id'].toString());
      print("Amount" + amountController.text);

      final dio = Dio();
      final response = await dio.post(
        "${Urls.serviceDtw}/api/operations/transfert",
        queryParameters: {
          'fromUserId': userId,
          'toUserId': selectedUser!['id'].toString(),
          'fromBankId': selectedMyBank!['id'].toString(),
          'toBankId': selectedRecipientBank!['id'].toString(),
          'montant': amountController.text,
        },
        options: Options(
          headers: {
            'accept': 'application/hal+json',
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['status'] == 'success') {
        // Réinitialiser le formulaire
        setState(() {
          selectedMyBank = null;
          selectedUser = null;
          selectedRecipientBank = null;
          amountController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                responseData['message'] ?? 'Transfert effectué avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(responseData['message'] ?? 'Erreur lors du transfert'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is DioError && e.response?.data != null
              ? (e.response!.data['message'] ?? 'Erreur lors du transfert')
              : 'Erreur lors du transfert'),
          backgroundColor: Colors.red,
        ),
      );
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert d\'argent'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sélectionnez votre banque',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Map<String, dynamic>>(
                            value: selectedMyBank,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Choisir une banque'),
                            items: myBanks.map((bank) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: bank,
                                child: Text(bank['bank_name'] ?? ''),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMyBank = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sélectionnez le destinataire',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Map<String, dynamic>>(
                            value: selectedUser,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Choisir un utilisateur'),
                            items: users.map((user) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: user,
                                child: Text('${user['email']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUser = value;
                                selectedRecipientBank = null;
                                recipientBanks.clear();
                              });
                              if (value != null) {
                                fetchRecipientBanks();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedUser != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sélectionnez la banque du destinataire',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Map<String, dynamic>>(
                              value: selectedRecipientBank,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              hint: const Text('Choisir une banque'),
                              items: recipientBanks.map((bank) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: bank,
                                  child: Text(bank['bank_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRecipientBank = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Montant du transfert',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Entrez le montant',
                              prefixText: 'FCFA ',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : makeTransfer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      isLoading
                          ? 'Traitement en cours...'
                          : 'Effectuer le transfert',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
