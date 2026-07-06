import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/stage.dart';
import '../data/repositories/stage_repository.dart';

// Provider che gestisce lo stato delle tappe. Le tappe sono tenute in una
// mappa indicizzata per viaggio, così da poter caricare e aggiornare in modo
// indipendente le tappe di ciascun viaggio.
class StageProvider extends ChangeNotifier {
  final StageRepository _repo = StageRepository();
  final _uuid = const Uuid();

  // Cache in memoria: idViaggio -> elenco tappe del viaggio.
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

  // Duplica tutte le tappe di un viaggio verso un nuovo viaggio.
  // Restituisce una mappa (idTappaOriginale -> idTappaCopiata) che serve
  // ai provider di attività e checklist per ricollegare correttamente gli
  // elementi alle nuove tappe durante la duplicazione completa del viaggio.
  Future<Map<String, String>> duplicateStagesForTrip(
      String sourceTripId, String newTripId) async {
    final stages = await _repo.getByTrip(sourceTripId);
    final idMap = <String, String>{};
    for (final s in stages) {
      final newId = _uuid.v4();
      idMap[s.id] = newId;
      final copy = Stage(
        id: newId,
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
    return idMap;
  }

  void clearForTrip(String tripId) {
    _stagesByTrip.remove(tripId);
    notifyListeners();
  }
}
