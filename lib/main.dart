import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'bootstrap/providers.dart';
import 'core/logging/logger.dart';
import 'features/graph/presentation/screens/graph_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  
  // Initialize the authoritative adapter before UI rendering
  final adapter = container.read(memPalaceAdapterProvider);
  await adapter.initialize();
  Log.i('Core Adapter Initialized successfully.');

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MemPalaceApp(),
  ));
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const GraphScreen(),
    ),
  ],
);

class MemPalaceApp extends StatelessWidget {
  const MemPalaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MemPalace',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      routerConfig: _router,
    );
  }
}
