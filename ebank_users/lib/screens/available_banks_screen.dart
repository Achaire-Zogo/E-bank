import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../urls/Urls.dart';
import 'bank_account_creation_screen.dart'; // Assuming this is the correct import path

class AvailableBanksScreen extends StatefulWidget {
  const AvailableBanksScreen({Key? key}) : super(key: key);

  @override
  State<AvailableBanksScreen> createState() => _AvailableBanksScreenState();
}

class _AvailableBanksScreenState extends State<AvailableBanksScreen> {
  List<Map<String, dynamic>> banks = [];
  bool isLoading = true;
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

      Dio dio = Dio();
      Response response = await dio.get(
        "${Urls.serviceBank}/api/bank/banks/excluded-banks/?user=$userId",
      );
      setState(() {
        banks = List<Map<String, dynamic>>.from(response.data);
        error = null;
        isLoading = false;
        if (response.data is List) {
          final allBanks = List<Map<String, dynamic>>.from(response.data);
          setState(() {
            banks =
                allBanks.where((bank) => bank['status'] == 'VERIFIED').toList();
            error = null;
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des banques';
        isLoading = false;
      });
      print('Failed to fetch banks: $e');
    }
  }

  Future<void> navigateToBankDetails(Map<String, dynamic> bank) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id_user');
    if (userId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankAccountCreationScreen(
          bankDetails: bank,
          userId:
              userId, // Replace with actual user ID from your authentication system
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banques Disponibles'),
        elevation: 0,
      ),
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
                        onPressed: fetchBanks,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchBanks,
                  child: banks.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune banque disponible',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: banks.length,
                          itemBuilder: (context, index) {
                            final bank = banks[index];
                            Color statusColor;
                            IconData statusIcon;
                            String statusText;

                            switch (bank['status']) {
                              case 'VERIFIED':
                                statusColor = Colors.green;
                                statusIcon = Icons.check_circle;
                                statusText = 'Vérifié';
                                break;
                              case 'PENDING':
                                statusColor = Colors.orange;
                                statusIcon = Icons.hourglass_empty;
                                statusText = 'En attente';
                                break;
                              case 'INACTIVE':
                                statusColor = Colors.red;
                                statusIcon = Icons.cancel;
                                statusText = 'Inactif';
                                break;
                              default:
                                statusColor = Colors.grey;
                                statusIcon = Icons.help_outline;
                                statusText = 'Inconnu';
                            }

                            return InkWell(
                              onTap: () => navigateToBankDetails(bank),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.account_balance,
                                          size: 50,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              bank['bank_name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              bank['address'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  statusIcon,
                                                  size: 16,
                                                  color: statusColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
