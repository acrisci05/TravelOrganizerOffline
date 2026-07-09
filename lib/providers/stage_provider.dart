import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/stage.dart';
import '../data/repositories/stage_repository.dart';

class StageProvider extends ChangeNotifier {
  final StageRepository _repo = StageRepository();
  final _uuid = const Uuid();

  final Map<String, List<Stage>> _stagesByTrip = {};

  List<Stage> getByTrip(String tripId) => _stagesByTrip[tripId] ?? [];

  Future<void> loadForTrip(String tripId) async {
    _stagesByTrip[tripId] = await _repo.getByTrip(tripId);
    notifyListeners();
  }

  Stage? getById(String tripId, String stageId) {
    final list = _stagesByTrip[tripId];
    if (list == null) return null;
    for (final s in list) {
      if (s.id == stageId) return s;
    }
    return null;
  }

  Future<void> addStage({
    required String tripId,
    required String title,
    required DateTime date,
    String? location,
    String? description,
    String? notes,
  }) async {
    final existing = _stagesByTrip[tripId] ?? [];
    final stage = Stage(
      id: _uuid.v4(),
      tripId: tripId,
      title: title,
      date: date,
      location: location,
      description: description,
      order: existing.length,
      notes: notes,
    );
    await _repo.insert(stage);
    existing.add(stage);
    _stagesByTrip[tripId] = existing;
    notifyListeners();
  }

  Future<void> updateStage(Stage stage) async {
    await _repo.update(stage);
    final list = _stagesByTrip[stage.tripId] ?? [];
    final idx = list.indexWhere((s) => s.id == stage.id);
    if (idx != -1) {
      list[idx] = stage;
      _stagesByTrip[stage.tripId] = list;
      notifyListeners();
    }
  }

  Future<void> deleteStage(String tripId, String stageId) async {
    await _repo.delete(stageId);
    _stagesByTrip[tripId]?.removeWhere((s) => s.id == stageId);
    notifyListeners();
  }

  Future<Map<String, String>> duplicateStagesForTrip(
    String sourceTripId,
    String newTripId,
  ) async {
    if (!_stagesByTrip.containsKey(sourceTripId)) {
      await loadForTrip(sourceTripId);
    }

    final sourceStages = List<Stage>.from(_stagesByTrip[sourceTripId] ?? []);
    final newStages = _stagesByTrip[newTripId] ?? <Stage>[];
    final stageIdMap = <String, String>{};

    for (final stage in sourceStages) {
      final newStageId = _uuid.v4();

      final copy = Stage(
        id: newStageId,
        tripId: newTripId,
        title: stage.title,
        date: stage.date,
        location: stage.location,
        description: stage.description,
        order: stage.order,
        notes: stage.notes,
      );

      await _repo.insert(copy);
      newStages.add(copy);
      stageIdMap[stage.id] = newStageId;
    }

    _stagesByTrip[newTripId] = newStages;
    notifyListeners();
    return stageIdMap;
  }

  void clearForTrip(String tripId) {
    _stagesByTrip.remove(tripId);
    notifyListeners();
  }
}
