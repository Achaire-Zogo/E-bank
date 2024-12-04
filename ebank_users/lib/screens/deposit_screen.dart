import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../urls/Urls.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({Key? key}) : super(key: key);

  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  List<Map<String, dynamic>> banks = [];
  Map<String, dynamic>? selectedBank;
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBanks();
  }

  Future<void> fetchBanks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id_user');
      if (userId == null) return;

      setState(() {
        isLoading = true;
        error = null;
      });

      final dio = Dio();
      Response response = await dio.get(
        "${Urls.serviceBank}/api/bank/banks/banks-user/?user=$userId",
      );

      if (response.data is List) {
        final allBanks = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          banks =
              allBanks.where((bank) => bank['status'] == 'VERIFIED').toList();
          error = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des banques';
        isLoading = false;
        banks = [];
      });
      print('Failed to fetch banks: $e');
    }
  }

  Future<void> makeDeposit() async {
    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une banque')),
      );
      return;
    }

    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id_user');
      if (userId == null) return;

      final dio = Dio();
      final response = await dio.post(
        "${Urls.serviceDtw}/api/operations/depot",
        queryParameters: {
          'userId': userId,
          'fromBankId': selectedBank!['id'],
          'montant': int.parse(amountController.text),
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Dépôt effectué avec succès. Référence: ${response.data['reference']}'),
            backgroundColor: Colors.green,
          ),
        );
        // Vider le formulaire
        setState(() {
          selectedBank = null;
          amountController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du dépôt'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Effectuer un dépôt'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sélectionnez une banque',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Map<String, dynamic>>(
                              value: selectedBank,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              hint: const Text('Choisir une banque'),
                              items: banks.map((bank) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: bank,
                                  child: Text(bank['bank_name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedBank = value;
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Montant du dépôt',
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
                      onPressed: isLoading ? null : makeDeposit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        isLoading
                            ? 'Traitement en cours...'
                            : 'Effectuer le dépôt',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
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
