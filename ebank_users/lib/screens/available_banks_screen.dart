import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../constant/constant.dart';
import '../models/bank.dart';
import '../urls/Urls.dart';

class AvailableBanksScreen extends StatefulWidget {
  const AvailableBanksScreen({Key? key}) : super(key: key);

  @override
  State<AvailableBanksScreen> createState() => _AvailableBanksScreenState();
}

class _AvailableBanksScreenState extends State<AvailableBanksScreen> {
  List<Bank> banks = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBanks();
  }

  Future<void> fetchBanks() async {
    try {
      Dio dio = Dio();
      Response response = await dio.get(
        Urls.getBanks,
        options: Options(
          contentType: "application/json; charset=utf-8",
          responseType: ResponseType.json,
          headers: {
            "X-Requested-With": "XMLHttpRequest",
            "X-CSRFToken": Constant.getCookie("csrftoken"),
          },
        ),
      );
      print(response);
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> results = data['results'];
        setState(() {
          banks = results.map((json) => Bank.fromJson(json)).toList();
          error = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        error = 'Erreur lors de la récupération des banques';
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchBanks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Banques disponibles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading && banks.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (error != null && banks.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 30,
                          child: Icon(
                            Icons.account_balance_outlined,
                            color: Colors.grey[800],
                            size: 30,
                          ),
                        ),
                        title: Text(
                          bank.bankName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(bank.address),
                            Text(
                              'Status: ${bank.status}',
                              style: TextStyle(
                                color: bank.status == 'VERIFIED'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: bank.status == 'VERIFIED'
                              ? () {
                                  // Action pour lier la banque
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bank.status == 'VERIFIED'
                                ? Colors.blue
                                : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Lier'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
