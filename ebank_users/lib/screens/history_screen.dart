import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../urls/Urls.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id_user');
      if (userId == null) {
        setState(() {
          error = 'Utilisateur non connecté';
          isLoading = false;
        });
        return;
      }

      var response = await Dio().get(
        '${Urls.serviceDtw}/api/operations/user/$userId',
      );

      if (response.statusCode == 200) {
        setState(() {
          transactions = List<Map<String, dynamic>>.from(response.data);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des transactions';
        isLoading = false;
      });
      print('Failed to fetch transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: fetchTransactions,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchTransactions,
                  child: transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune transaction trouvée',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            IconData icon;
                            Color color;
                            String sign;

                            switch (transaction['type']) {
                              case 'RETRAIT':
                                icon = Icons.arrow_downward;
                                color = Colors.red;
                                sign = '-';
                                break;
                              case 'DEPOT':
                                icon = Icons.arrow_upward;
                                color = Colors.green;
                                sign = '+';
                                break;
                              case 'TRANSFERT':
                                icon = Icons.swap_horiz;
                                color = Colors.blue;
                                sign = '~';
                                break;
                              default:
                                icon = Icons.error;
                                color = Colors.grey;
                                sign = '';
                            }

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.1),
                                  child: Icon(
                                    icon,
                                    color: color,
                                  ),
                                ),
                                title: Text(
                                  transaction['type'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(transaction['dateOperation']),
                                    Text(
                                      'Réf: ${transaction['reference']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  '${sign}${transaction['montant']} FCFA',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  // TODO: Show transaction details
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
