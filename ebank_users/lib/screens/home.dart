import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'linked_banks_screen.dart';
import 'available_banks_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LinkedBanksScreen(),
    const AvailableBanksScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _currentIndex == 0 ? const Icon(Icons.dashboard) :
            _currentIndex == 1 ? const Icon(Icons.account_balance) :
            _currentIndex == 2 ? const Icon(Icons.business) :
            _currentIndex == 3 ? const Icon(Icons.history) : const Icon(Icons.settings),
            const SizedBox(width: 8),
            Text(
              _currentIndex == 0 ? 'Tableau de bord' :
              _currentIndex == 1 ? 'Mes banques' :
              _currentIndex == 2 ? 'Banques disponibles' :
              _currentIndex == 3 ? 'Historique' : 'Paramètres',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Mes banques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Ajouter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
