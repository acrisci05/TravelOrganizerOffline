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

  Future<void> duplicateStagesForTrip(
      String sourceTripId, String newTripId) async {
    final stages = await _repo.getByTrip(sourceTripId);
    for (final s in stages) {
      final copy = Stage(
        id: _uuid.v4(),
        tripId: newTripId,
        title: s.title,
        date: s.date,
        location: s.location,
        description: s.description,
        order: s.order,
        notes: s.notes,
      );
      await _repo.insert(copy);
    }
    await loadForTrip(newTripId);
  }

  void clearForTrip(String tripId) {
    _stagesByTrip.remove(tripId);
    notifyListeners();
  }
}
