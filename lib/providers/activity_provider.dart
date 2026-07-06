import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/activity.dart';
import '../data/repositories/activity_repository.dart';

// Provider che gestisce lo stato delle attività, indicizzate per viaggio.
// Offre viste filtrate (per tappa, per categoria, non assegnate) e i conteggi
// usati nelle statistiche.
class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repo = ActivityRepository();
  final _uuid = const Uuid();

  // Cache in memoria: idViaggio -> elenco attività del viaggio.
  final Map<String, List<Activity>> _activitiesByTrip = {};

  List<Activity> getByTrip(String tripId) => _activitiesByTrip[tripId] ?? [];

  List<Activity> getByStage(String tripId, String stageId) =>
      (_activitiesByTrip[tripId] ?? [])
          .where((a) => a.stageId == stageId)
          .toList()
        ..sort((a, b) {
          if (a.dateTime == null && b.dateTime == null) return 0;
          if (a.dateTime == null) return 1;
          if (b.dateTime == null) return -1;
          return a.dateTime!.compareTo(b.dateTime!);
        });

  List<Activity> getUnassigned(String tripId) =>
      (_activitiesByTrip[tripId] ?? [])
          .where((a) => a.stageId == null)
          .toList();

  List<Activity> getByCategory(String tripId, ActivityCategory category) =>
      (_activitiesByTrip[tripId] ?? [])
          .where((a) => a.category == category)
          .toList();

  Future<void> loadForTrip(String tripId) async {
    _activitiesByTrip[tripId] = await _repo.getByTrip(tripId);
    notifyListeners();
  }

  Future<void> addActivity({
    required String tripId,
    String? stageId,
    required String title,
    String? description,
    DateTime? dateTime,
    String? location,
    ActivityCategory category = ActivityCategory.other,
    double? estimatedCost,
    String? notes,
  }) async {
    final activity = Activity(
      id: _uuid.v4(),
      tripId: tripId,
      stageId: stageId,
      title: title,
      description: description,
      dateTime: dateTime,
      location: location,
      category: category,
      estimatedCost: estimatedCost,
      notes: notes,
    );
    await _repo.insert(activity);
    final list = _activitiesByTrip[tripId] ?? [];
    list.add(activity);
    _activitiesByTrip[tripId] = list;
    notifyListeners();
  }

  Future<void> updateActivity(Activity activity) async {
    await _repo.update(activity);
    final list = _activitiesByTrip[activity.tripId] ?? [];
    final idx = list.indexWhere((a) => a.id == activity.id);
    if (idx != -1) {
      list[idx] = activity;
      _activitiesByTrip[activity.tripId] = list;
      notifyListeners();
    }
  }

  Future<void> toggleStatus(Activity activity) async {
    final next = activity.status == ActivityStatus.done
        ? ActivityStatus.todo
        : ActivityStatus.done;
    await updateActivity(activity.copyWith(status: next));
  }

  Future<void> deleteActivity(String tripId, String activityId) async {
    await _repo.delete(activityId);
    _activitiesByTrip[tripId]?.removeWhere((a) => a.id == activityId);
    notifyListeners();
  }

  // Duplica tutte le attività di un viaggio verso un nuovo viaggio.
  // La mappa [stageIdMap] (idTappaOriginale -> idTappaCopiata) permette di
  // ricollegare ogni attività alla corrispondente tappa duplicata; se
  // l'attività non era associata ad alcuna tappa resta senza tappa.
  // Lo stato viene riportato a "da fare" perché il viaggio copiato è una
  // nuova pianificazione ancora tutta da svolgere.
  Future<void> duplicateActivitiesForTrip(
    String sourceTripId,
    String newTripId,
    Map<String, String> stageIdMap,
  ) async {
    final activities = await _repo.getByTrip(sourceTripId);
    for (final a in activities) {
      final copy = Activity(
        id: _uuid.v4(),
        tripId: newTripId,
        stageId: a.stageId == null ? null : stageIdMap[a.stageId],
        title: a.title,
        description: a.description,
        dateTime: a.dateTime,
        location: a.location,
        category: a.category,
        estimatedCost: a.estimatedCost,
        status: ActivityStatus.todo,
        notes: a.notes,
      );
      await _repo.insert(copy);
    }
    await loadForTrip(newTripId);
  }

  int completedCount(String tripId) =>
      (_activitiesByTrip[tripId] ?? [])
          .where((a) => a.status == ActivityStatus.done)
          .length;

  int totalCount(String tripId) =>
      (_activitiesByTrip[tripId] ?? []).length;
}
