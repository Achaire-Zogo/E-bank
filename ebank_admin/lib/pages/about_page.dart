import 'package:chatty/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class AboutPage extends ConsumerStatefulWidget {
  User? user;
  AboutPage({super.key, this.user});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends ConsumerState<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1.0,
      ),
      body: Center(
        child: Text('About Page'),
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
    );
  }
}
