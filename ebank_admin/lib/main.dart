import 'package:chatty/models/bank.dart';
import 'package:chatty/models/user.dart';
import 'package:chatty/pages/about_page.dart';
import 'package:chatty/pages/contact_page.dart';
import 'package:chatty/pages/bank_list_page.dart';
import 'package:chatty/pages/login_page.dart';
import 'package:chatty/pages/profile_page.dart';
import 'package:chatty/pages/settings_page.dart';
import 'package:chatty/pages/signup_page.dart';
import 'package:chatty/providers/chat_providers.dart';
import 'package:chatty/providers/bank_providers.dart';
import 'package:chatty/providers/user_providers.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/chat.dart';
import 'models/groupchat.dart';

GoRouter router() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return BankListPage();
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => UserListPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => AboutPage(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => UserListPage(),
      ),
    ],
  );
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listen to provider changes at a global level
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Bank>>>(bankListProvider, (previous, next) {
      next.when(data: (chats) {
        if (kDebugMode) {
          print('Banks updated: ${chats.length}');
        }
      }, error: (error, stack) {
        if (kDebugMode) {
          print("Error loading banks: $error");
        }
      }, loading: () {
        if (kDebugMode) {
          print('Loading banks ...');
        }
      });
    });

    ref.listen<AsyncValue<List<User>>>(userListProvider, (previous, next) {
      next.when(data: (users) {
        if (kDebugMode) {
          print('Users updated: ${users.length}');
        }
      }, error: (error, stack) {
        if (kDebugMode) {
          print("Error loading users: $error");
        }
      }, loading: () {
        if (kDebugMode) {
          print('Loading users ...');
        }
      });
    });

    // Using MultiProvider is convenient when providing multiple objects.
    return MaterialApp.router(
      title: 'Provider Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)),
      routerConfig: router(),
    );
  }
}
