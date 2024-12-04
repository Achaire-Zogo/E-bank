import 'package:ebank_users/screens/withdrawal_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../urls/Urls.dart';
import 'deposit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double solde = 0.0;
  List<Map<String, dynamic>> dernieresTransactions = [];
  List<FlSpot> depositSpots = [];
  List<FlSpot> transferSpots = [];

  bool isLoading = true;

  List<FlSpot> _generateFlSpots(String type) {
    List<FlSpot> spots = [];
    for (int i = 0; i < dernieresTransactions.length; i++) {
      final transaction = dernieresTransactions[i];
      if (transaction['type'] == type) {
        double x = i.toDouble(); // Using index as x value
        double y =
            transaction['montant'].toDouble(); // Using montant as y value
        spots.add(FlSpot(x, y));
      }
    }
    return spots;
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString('id_user', '1');
    //print(prefs.getString('id_user'));
    String? userId = prefs.getString('id_user');
    if (userId == null) return;
    print(prefs.getString('id_user'));
    try {
      var response = await Dio()
          .get('${Urls.serviceDtw}/api/operations/user/$userId/dashboard');
      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          solde = response.data['solde'];
          dernieresTransactions = List<Map<String, dynamic>>.from(
              response.data['dernieresTransactions']);
          depositSpots = _generateFlSpots('DEPOT'); // Update spots for deposits
          transferSpots =
              _generateFlSpots('RETRAIT'); // Update spots for withdrawals
        });
      }
    } catch (e) {
      print('Failed to fetch dashboard data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: _fetchDashboardData,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Solde actuel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, size: 20),
                                    onPressed: () {
                                      _fetchDashboardData();
                                    },
                                    tooltip: 'Rafraîchir le solde',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$solde FCFA',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Action pour le dépôt
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DepositScreen()),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Dépôt'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WithdrawalScreen()),
                                );
                              },
                              icon: const Icon(Icons.send),
                              label: const Text('Transfert'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Activité du compte',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Icon(Icons.circle,
                                      color: Colors.blue, size: 12),
                                  SizedBox(width: 4),
                                  Text('Dépôts'),
                                  SizedBox(width: 16),
                                  Icon(Icons.circle,
                                      color: Colors.green, size: 12),
                                  SizedBox(width: 4),
                                  Text('Transferts'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 0:
                                                return const Text('Lun');
                                              case 1:
                                                return const Text('Mar');
                                              case 2:
                                                return const Text('Mer');
                                              case 3:
                                                return const Text('Jeu');
                                              case 4:
                                                return const Text('Ven');
                                              case 5:
                                                return const Text('Sam');
                                              default:
                                                return const Text('');
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: depositSpots,
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: false),
                                      ),
                                      LineChartBarData(
                                        spots: transferSpots,
                                        isCurved: true,
                                        color: Colors.green,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Transactions récentes:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dernieresTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = dernieresTransactions[index];
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.1),
                                  child: Icon(
                                    icon,
                                    color: color,
                                  ),
                                ),
                                title: Text(
                                  '${transaction['type']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(transaction['dateOperation']),
                                    Text('Réf: ${transaction['reference']}'),
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
                                  // Afficher les détails de la transaction
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
