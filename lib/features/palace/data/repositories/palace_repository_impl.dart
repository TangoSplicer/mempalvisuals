import '../../../core/logging/logger.dart';
import '../../../../adapters/mempalace/i_mempalace_adapter.dart';
import '../../domain/entities/palace.dart';
import '../../domain/repositories/i_palace_repository.dart';

class PalaceRepositoryImpl implements IPalaceRepository {
  final IMemPalaceAdapter _adapter;

  PalaceRepositoryImpl(this._adapter);

  @override
  Future<List<Palace>> getPalaces() async {
    try {
      final rawPalaces = await _adapter.fetchPalaces();
      return rawPalaces.map((json) => Palace.fromJson(json)).toList();
    } catch (e, stackTrace) {
      Log.e('Failed to fetch memory palaces', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> savePalace(Palace palace) async {
    try {
      await _adapter.savePalace(palace.toJson());
      Log.i('Successfully saved Palace: ${palace.name}');
    } catch (e, stackTrace) {
      Log.e('Failed to save memory palace', e, stackTrace);
      rethrow;
    }
  }
}
