import '../entities/palace.dart';

abstract interface class IPalaceRepository {
  Future<List<Palace>> getPalaces();
  Future<void> savePalace(Palace palace);
}
