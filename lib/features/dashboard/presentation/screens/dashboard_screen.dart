import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../graph/presentation/providers/graph_provider.dart';
import '../../../palace/presentation/providers/palace_provider.dart';
import '../../../timeline/presentation/providers/timeline_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphState = ref.watch(graphStateProvider);
    final palaceState = ref.watch(palaceStateProvider);
    final timelineState = ref.watch(timelineStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MemPalace Visuals'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings module pending.')),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  title: 'Nodes',
                  value: graphState.maybeWhen(
                    data: (data) => data.nodes.length.toString(),
                    orElse: () => '...',
                  ),
                  icon: Icons.hub,
                  color: Colors.blueAccent,
                  onTap: () => context.go('/graph'),
                ),
                _buildStatCard(
                  context,
                  title: 'Palaces',
                  value: palaceState.maybeWhen(
                    data: (palaces) => palaces.length.toString(),
                    orElse: () => '...',
                  ),
                  icon: Icons.account_balance,
                  color: Colors.deepPurpleAccent,
                  onTap: () => context.go('/palace'),
                ),
                _buildStatCard(
                  context,
                  title: 'Events',
                  value: timelineState.maybeWhen(
                    data: (events) => events.length.toString(),
                    orElse: () => '...',
                  ),
                  icon: Icons.timeline,
                  color: Colors.orangeAccent,
                  onTap: () => context.go('/timeline'),
                ),
                _buildStatCard(
                  context,
                  title: 'Search',
                  value: 'Ready',
                  icon: Icons.search,
                  color: Colors.greenAccent,
                  onTap: () => context.go('/search'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/graph'),
                  icon: const Icon(Icons.explore),
                  label: const Text('Explore Graph'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/palace'),
                  icon: const Icon(Icons.add),
                  label: const Text('New Memory Room'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
