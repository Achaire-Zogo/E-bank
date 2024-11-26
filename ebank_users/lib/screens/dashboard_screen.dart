import 'package:ebank_users/screens/withdrawal_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'deposit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<FlSpot> depositSpots = [
    const FlSpot(0, 3),
    const FlSpot(1, 1),
    const FlSpot(2, 4),
    const FlSpot(3, 2),
    const FlSpot(4, 5),
    const FlSpot(5, 3),
  ];

  final List<FlSpot> transferSpots = [
    const FlSpot(0, 2),
    const FlSpot(1, 3),
    const FlSpot(2, 2),
    const FlSpot(3, 4),
    const FlSpot(4, 1),
    const FlSpot(5, 3),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solde actuel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: SharedPreferences.getInstance().then(
                        (prefs) => prefs.getString('balance') ?? '0',
                      ),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data ?? "0"} FCFA',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
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
                        MaterialPageRoute(builder: (context) => const DepositScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Dépôt'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Transfert'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        Icon(Icons.circle, color: Colors.blue, size: 12),
                        SizedBox(width: 4),
                        Text('Dépôts'),
                        SizedBox(width: 16),
                        Icon(Icons.circle, color: Colors.green, size: 12),
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
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
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
            const Text(
              'Transactions récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index % 2 == 0 ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        index % 2 == 0 ? Icons.add : Icons.remove,
                        color: index % 2 == 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      index % 2 == 0 ? 'Dépôt' : 'Transfert',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Il y a ${index + 1} ${index == 0 ? 'heure' : 'heures'}',
                    ),
                    trailing: Text(
                      '${index % 2 == 0 ? '+' : '-'}${(index + 1) * 10000} FCFA',
                      style: TextStyle(
                        color: index % 2 == 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
