import 'package:flutter/material.dart';
import '../../palace/presentation/palace_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart'; // FIXED PATH
import '../../vault/presentation/vault_screen.dart';
import '../../graph/presentation/screens/graph_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MemPalace Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildCard(
                context,
                Icons.add,
                'New Room',
                Colors.teal,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PalaceScreen()))),
            _buildCard(
                context,
                Icons.account_balance,
                'Memory Vault',
                Colors.indigo,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VaultScreen()))),
            _buildCard(
                context,
                Icons.hub,
                'Visual Graph',
                Colors.purple,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GraphScreen()))),
            _buildCard(
                context,
                Icons.build,
                'Kill-Switch Editor',
                Colors.redAccent,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()))),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
