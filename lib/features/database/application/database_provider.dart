import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';

// Provides a global, singleton instance of the database
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Ensure the database connection is closed if the provider is destroyed
  ref.onDispose(() => db.close());
  return db;
});
