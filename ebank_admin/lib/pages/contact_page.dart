import 'package:chatty/models/user.dart';
import 'package:chatty/pages/bank_list_page.dart';
// ignore: unused_import
import 'package:chatty/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat.dart';
import '../providers/user_providers.dart';
import '../services/chat_api_service.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation
    switch (index) {
      case 0:
        // Navigate to Chats page (current page)
        context.go('/home');
        break;

      case 1:
        // Navigate to Groups page
        context.go('/users');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    var _data = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Users',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1.0,
      ),
      body: _data.when(
        data: (data) {
          return UserList(users: data);
        },
        error: (err, s) => Center(child: Text(s.toString())),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankListPage(),
                  ),
                );
              },
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

// ignore: must_be_immutable
class UserList extends ConsumerWidget {
  UserList({super.key, required this.users});
  final List<User> users;
  SharedPreferences? prefs;

  void initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context, ref) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.account_circle),
          title: Text(
            users[index].username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            users[index].email,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        );
      },
    );
  }
}
