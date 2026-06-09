import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap/providers.dart';
import 'core/logging/logger.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  final adapter = container.read(memPalaceAdapterProvider);
  await adapter.initialize();
  Log.i('Core Adapter Initialized successfully.');

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MemPalaceApp(),
  ));
}

class MemPalaceApp extends StatelessWidget {
  const MemPalaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MemPalace',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      routerConfig: appRouter,
    );
  }
}
