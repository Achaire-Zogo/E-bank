import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique des transactions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tous'),
                  selected: true,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Dépôts'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Retraits'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Transferts'),
                  selected: false,
                  onSelected: (bool value) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Liste des transactions
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                bool isDeposit = index % 3 == 0;
                bool isTransfer = index % 3 == 1;
                
                IconData transactionIcon;
                Color iconColor;
                String transactionType;
                
                if (isDeposit) {
                  transactionIcon = Icons.arrow_downward;
                  iconColor = Colors.green;
                  transactionType = 'Dépôt';
                } else if (isTransfer) {
                  transactionIcon = Icons.swap_horiz;
                  iconColor = Colors.blue;
                  transactionType = 'Transfert';
                } else {
                  transactionIcon = Icons.arrow_upward;
                  iconColor = Colors.red;
                  transactionType = 'Retrait';
                }

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.1),
                      child: Icon(
                        transactionIcon,
                        color: iconColor,
                      ),
                    ),
                    title: Text(
                      '$transactionType - Banque ${index % 3 + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('12 Jan 2024 - 14:${index.toString().padLeft(2, '0')}'),
                        Text('Réf: TXN${index.toString().padLeft(6, '0')}'),
                      ],
                    ),
                    trailing: Text(
                      '${isDeposit ? '+' : isTransfer ? '~' : '-'}${50000 + index * 1000} FCFA',
                      style: TextStyle(
                        color: iconColor,
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
    );
  }
}
