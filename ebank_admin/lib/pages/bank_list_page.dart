import 'package:chatty/models/bank.dart';
import 'package:chatty/models/user.dart';
import 'package:chatty/providers/bank_providers.dart';
import 'package:chatty/services/bank_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BankList extends ConsumerWidget {
  const BankList({super.key, required this.banks});
  final List<Bank> banks;

  @override
  Widget build(BuildContext context, ref) {
    return ListView.builder(
      itemCount: banks.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5.0,
            margin: EdgeInsets.all(10.0),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 160,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        banks[index].bank_name,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        banks[index].address,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        banks[index].status,
                        style: TextStyle(
                          fontSize: 24,
                          color: banks[index].status == 'VERIFIED'
                              ? Colors.green
                              : (banks[index].status == 'PENDING'
                                  ? Colors.yellowAccent
                                  : Colors.redAccent),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Spacer(),
                          TextButton(
                            onPressed: () async {
                              ref.read(bankApiProvider).changeStatusBank(
                                  banks[index].id, "VERIFIED");
                            },
                            child: Text(
                              "VALIDATE",
                              style: TextStyle(color: Colors.greenAccent),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              ref.read(bankApiProvider).changeStatusBank(
                                  banks[index].id, "REJECTED");
                            },
                            child: Text(
                              "REJECT",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => BankDetail(bank: banks[index]),
            //   ),
            // );
          },
        );
      },
    );
  }
}

class BankListPage extends ConsumerStatefulWidget {
  const BankListPage({super.key});

  @override
  ConsumerState<BankListPage> createState() => _BankListPageState();
}

class _BankListPageState extends ConsumerState<BankListPage> {
  int _selectedIndex = 0; // Default to the banks page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation
    switch (index) {
      case 0:
        // Navigate to Banks page
        //context.go('/home');
        break;
      case 1:
        // Navigate to Users page
        context.go('/users');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data_ = ref.watch(bankListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'banks',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1.0,
      ),
      body: data_.when(
        data: (data) => BankList(banks: data),
        error: (err, s) => Center(child: Text(err.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                children: <Widget>[
                  Icon(Icons.account_circle_outlined),
                  SizedBox(height: 10),
                  Text(
                    User.user?.username ?? "admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_rounded),
              title: Text('Banks'),
              onTap: () => context.go('/home'),
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Users'),
              onTap: () => context.go('/users'),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                context.go('/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                context.go('/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              onTap: () {
                context.go('/about');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_rounded),
            label: 'Banks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Users',
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 5.0,
      ),
    );
  }
}
