import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebank_users/screens/login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool biometricEnabled = false;
  bool pushNotificationsEnabled = true;
  bool emailNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paramètres',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Informations du profil
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations du profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Nom d\'utilisateur'),
                      subtitle: FutureBuilder<String>(
                        future: SharedPreferences.getInstance().then(
                          (prefs) =>
                              prefs.getString('username') ?? 'Non défini',
                        ),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? 'Chargement...');
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: FutureBuilder<String>(
                        future: SharedPreferences.getInstance().then(
                          (prefs) => prefs.getString('email') ?? 'Non défini',
                        ),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? 'Chargement...');
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text('CNI'),
                      subtitle: FutureBuilder<String>(
                        future: SharedPreferences.getInstance().then(
                          (prefs) =>
                              prefs.getString('cni_number') ?? 'Non défini',
                        ),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? 'Chargement...');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Paramètres de sécurité
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Changer le mot de passe'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigation vers le changement de mot de passe
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('Authentification biométrique'),
                    trailing: Switch(
                      value: biometricEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          biometricEnabled = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Paramètres de notification
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications push'),
                    trailing: Switch(
                      value: pushNotificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          pushNotificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Notifications par email'),
                    trailing: Switch(
                      value: emailNotificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          emailNotificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Effacer les données de session
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  // Rediriger vers la page de connexion
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
