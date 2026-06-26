import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'models/trip.dart';
import 'models/stage.dart';
import 'models/activity.dart';
import 'models/checklist.dart';
import 'models/checklist_item.dart';
import 'models/expense.dart';
import 'repositories/trip_repository.dart';
import 'repositories/stage_repository.dart';
import 'repositories/activity_repository.dart';
import 'repositories/checklist_repository.dart';
import 'repositories/expense_repository.dart';

// Servizio di esportazione/importazione di un viaggio completo in formato JSON.
// Permette di condividere un intero viaggio (con tappe, attività, checklist e
// spese) e di reimportarlo su un altro dispositivo, tutto in locale e offline.
class TripTransferService {
  static const _format = 'travel_organizer_trip';

  final TripRepository _tripRepo = TripRepository();
  final StageRepository _stageRepo = StageRepository();
  final ActivityRepository _activityRepo = ActivityRepository();
  final ChecklistRepository _checklistRepo = ChecklistRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final _uuid = const Uuid();

  // Serializza un viaggio e tutti i dati collegati in una stringa JSON leggibile.
  Future<String> exportTrip(String tripId) async {
    final trip = await _tripRepo.getById(tripId);
    if (trip == null) throw StateError('Viaggio non trovato');

    final stages = await _stageRepo.getByTrip(tripId);
    final activities = await _activityRepo.getByTrip(tripId);
    final checklists = await _checklistRepo.getByTrip(tripId);
    final expenses = await _expenseRepo.getByTrip(tripId);

    final data = {
      'format': _format,
      'version': 1,
      'trip': trip.toMap(),
      'stages': stages.map((s) => s.toMap()).toList(),
      'activities': activities.map((a) => a.toMap()).toList(),
      // Ogni checklist include i propri elementi.
      'checklists': checklists
          .map((c) => {
                ...c.toMap(),
                'items': c.items.map((i) => i.toMap()).toList(),
              })
          .toList(),
      'expenses': expenses.map((e) => e.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // Importa un viaggio dal JSON, rigenerando tutti gli ID e ricollegando le
  // relazioni (tappe, attività, checklist, spese) per evitare conflitti con i
  // dati già presenti. Restituisce il nuovo viaggio creato.
  Future<Trip> importTrip(String jsonStr) async {
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is! Map || decoded['format'] != _format) {
      throw const FormatException('Formato del file non valido');
    }
    final data = Map<String, dynamic>.from(decoded);

    // Nuovo id del viaggio e mappe per tradurre i vecchi id nei nuovi.
    final newTripId = _uuid.v4();
    final stageIdMap = <String, String>{};
    final activityIdMap = <String, String>{};

    // --- Viaggio ---
    final original = Trip.fromMap(Map<String, dynamic>.from(data['trip'] as Map));
    final newTrip = original.copyWith(
      id: newTripId,
      title: '${original.title} (importato)',
    );
    await _tripRepo.insert(newTrip);

    // --- Tappe ---
    for (final raw in (data['stages'] as List? ?? const [])) {
      final m = Map<String, dynamic>.from(raw as Map);
      final newId = _uuid.v4();
      stageIdMap[m['id'] as String] = newId;
      final stage = Stage.fromMap(m).copyWith(id: newId, tripId: newTripId);
      await _stageRepo.insert(stage);
    }

    // --- Attività ---
    for (final raw in (data['activities'] as List? ?? const [])) {
      final m = Map<String, dynamic>.from(raw as Map);
      final newId = _uuid.v4();
      activityIdMap[m['id'] as String] = newId;
      final oldStageId = m['stageId'] as String?;
      final activity = Activity.fromMap(m).copyWith(
        id: newId,
        tripId: newTripId,
        stageId: oldStageId == null ? null : stageIdMap[oldStageId],
      );
      await _activityRepo.insert(activity);
    }

    // --- Checklist (con i relativi elementi) ---
    for (final raw in (data['checklists'] as List? ?? const [])) {
      final m = Map<String, dynamic>.from(raw as Map);
      final newClId = _uuid.v4();
      final items = ((m['items'] as List?) ?? const [])
          .map((ir) => ChecklistItem.fromMap(Map<String, dynamic>.from(ir as Map))
              .copyWith(id: _uuid.v4(), checklistId: newClId))
          .toList();
      final oldStageId = m['stageId'] as String?;
      final checklist = Checklist.fromMap(m, items: items).copyWith(
        id: newClId,
        tripId: newTripId,
        stageId: oldStageId == null ? null : stageIdMap[oldStageId],
      );
      await _checklistRepo.insertChecklist(checklist);
    }

    // --- Spese ---
    for (final raw in (data['expenses'] as List? ?? const [])) {
      final m = Map<String, dynamic>.from(raw as Map);
      final oldStageId = m['stageId'] as String?;
      final oldActivityId = m['activityId'] as String?;
      final expense = Expense.fromMap(m).copyWith(
        id: _uuid.v4(),
        tripId: newTripId,
        stageId: oldStageId == null ? null : stageIdMap[oldStageId],
        activityId: oldActivityId == null ? null : activityIdMap[oldActivityId],
      );
      await _expenseRepo.insert(expense);
    }

    return newTrip;
  }
}
