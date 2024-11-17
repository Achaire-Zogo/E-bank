import 'package:flutter/material.dart';

class AvailableBanksScreen extends StatelessWidget {
  const AvailableBanksScreen({Key? key}) : super(key: key);

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
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
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
                      'Banque ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text('Cliquez pour lier votre compte'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Action pour lier la banque
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Lier'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
