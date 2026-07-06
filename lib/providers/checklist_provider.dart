import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/checklist.dart';
import '../data/models/checklist_item.dart';
import '../data/repositories/checklist_repository.dart';

class ChecklistProvider extends ChangeNotifier {
  final ChecklistRepository _repo = ChecklistRepository();
  final _uuid = const Uuid();

  final Map<String, List<Checklist>> _checklistsByTrip = {};

  List<Checklist> getByTrip(String tripId) =>
      _checklistsByTrip[tripId] ?? [];

  Future<void> loadForTrip(String tripId) async {
    _checklistsByTrip[tripId] = await _repo.getByTrip(tripId);
    notifyListeners();
  }

  Future<Checklist> addChecklist({
    required String tripId,
    String? stageId,
    required String title,
    String? description,
  }) async {
    final checklist = Checklist(
      id: _uuid.v4(),
      tripId: tripId,
      stageId: stageId,
      title: title,
      description: description,
    );
    await _repo.insertChecklist(checklist);
    final list = _checklistsByTrip[tripId] ?? [];
    list.add(checklist);
    _checklistsByTrip[tripId] = list;
    notifyListeners();
    return checklist;
  }

  Future<void> updateChecklist(Checklist checklist) async {
    await _repo.updateChecklist(checklist);
    final list = _checklistsByTrip[checklist.tripId] ?? [];
    final idx = list.indexWhere((c) => c.id == checklist.id);
    if (idx != -1) {
      list[idx] = checklist;
      _checklistsByTrip[checklist.tripId] = list;
      notifyListeners();
    }
  }

  Future<void> deleteChecklist(String tripId, String checklistId) async {
    await _repo.deleteChecklist(checklistId);
    _checklistsByTrip[tripId]?.removeWhere((c) => c.id == checklistId);
    notifyListeners();
  }

  Future<void> addItem(
      String tripId, String checklistId, String title) async {
    final list = _checklistsByTrip[tripId] ?? [];
    final idx = list.indexWhere((c) => c.id == checklistId);
    if (idx == -1) return;
    final checklist = list[idx];
    final item = ChecklistItem(
      id: _uuid.v4(),
      checklistId: checklistId,
      title: title,
      order: checklist.items.length,
    );
    await _repo.insertItem(item);
    final updatedItems = [...checklist.items, item];
    final updated = checklist.copyWith(items: updatedItems);
    list[idx] = updated;
    _checklistsByTrip[tripId] = list;
    notifyListeners();
  }

  Future<void> toggleItem(
      String tripId, String checklistId, String itemId) async {
    final list = _checklistsByTrip[tripId] ?? [];
    final cIdx = list.indexWhere((c) => c.id == checklistId);
    if (cIdx == -1) return;
    final checklist = list[cIdx];
    final itemIdx = checklist.items.indexWhere((i) => i.id == itemId);
    if (itemIdx == -1) return;
    final item = checklist.items[itemIdx];
    final updated = item.copyWith(isCompleted: !item.isCompleted);
    await _repo.updateItem(updated);
    final newItems = List<ChecklistItem>.from(checklist.items);
    newItems[itemIdx] = updated;
    list[cIdx] = checklist.copyWith(items: newItems);
    _checklistsByTrip[tripId] = list;
    notifyListeners();
  }

  Future<void> updateItem(
      String tripId, String checklistId, ChecklistItem item) async {
    await _repo.updateItem(item);
    final list = _checklistsByTrip[tripId] ?? [];
    final cIdx = list.indexWhere((c) => c.id == checklistId);
    if (cIdx == -1) return;
    final checklist = list[cIdx];
    final newItems = List<ChecklistItem>.from(checklist.items);
    final iIdx = newItems.indexWhere((i) => i.id == item.id);
    if (iIdx != -1) newItems[iIdx] = item;
    list[cIdx] = checklist.copyWith(items: newItems);
    _checklistsByTrip[tripId] = list;
    notifyListeners();
  }

  Future<void> deleteItem(
      String tripId, String checklistId, String itemId) async {
    await _repo.deleteItem(itemId);
    final list = _checklistsByTrip[tripId] ?? [];
    final cIdx = list.indexWhere((c) => c.id == checklistId);
    if (cIdx == -1) return;
    final checklist = list[cIdx];
    final newItems =
        checklist.items.where((i) => i.id != itemId).toList();
    list[cIdx] = checklist.copyWith(items: newItems);
    _checklistsByTrip[tripId] = list;
    notifyListeners();
  }

  Future<void> duplicateChecklist(
      String tripId, String checklistId) async {
    final list = _checklistsByTrip[tripId] ?? [];
    final source = list.firstWhere((c) => c.id == checklistId,
        orElse: () => throw StateError('not found'));
    final newChecklistId = _uuid.v4();
    final copy = Checklist(
      id: newChecklistId,
      tripId: tripId,
      stageId: source.stageId,
      title: '${source.title} (copia)',
      description: source.description,
      items: source.items
          .map((i) => ChecklistItem(
                id: _uuid.v4(),
                checklistId: newChecklistId,
                title: i.title,
                order: i.order,
              ))
          .toList(),
    );
    await _repo.insertChecklist(copy);
    list.add(copy);
    _checklistsByTrip[tripId] = list;
    notifyListeners();
  }
}
