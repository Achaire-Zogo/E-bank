import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../urls/Urls.dart';

class LinkedBanksScreen extends StatefulWidget {
  const LinkedBanksScreen({Key? key}) : super(key: key);

  @override
  _LinkedBanksScreenState createState() => _LinkedBanksScreenState();
}

class _LinkedBanksScreenState extends State<LinkedBanksScreen> {
  List<Map<String, dynamic>> banks = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : banks.isEmpty
                  ? const Center(child: Text('Aucune banque liée'))
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
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.account_balance,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bank['bank_name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bank['address'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
