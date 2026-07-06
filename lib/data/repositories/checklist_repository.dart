import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';

class ChecklistRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Checklist>> getByTrip(String tripId) async {
    final db = await _dbHelper.database;
    final listMaps = await db.query(
      'checklists',
      where: 'tripId = ?',
      whereArgs: [tripId],
    );
    final checklists = <Checklist>[];
    for (final map in listMaps) {
      final items = await _getItems(db, map['id'] as String);
      checklists.add(Checklist.fromMap(map, items: items));
    }
    return checklists;
  }

  Future<Checklist?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('checklists', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final items = await _getItems(db, id);
    return Checklist.fromMap(maps.first, items: items);
  }

  Future<List<ChecklistItem>> _getItems(Database db, String checklistId) async {
    final maps = await db.query(
      'checklist_items',
      where: 'checklistId = ?',
      whereArgs: [checklistId],
      orderBy: '"order" ASC',
    );
    return maps.map(ChecklistItem.fromMap).toList();
  }

  Future<void> insertChecklist(Checklist checklist) async {
    final db = await _dbHelper.database;
    await db.insert('checklists', checklist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (final item in checklist.items) {
      await db.insert('checklist_items', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> updateChecklist(Checklist checklist) async {
    final db = await _dbHelper.database;
    await db.update('checklists', checklist.toMap(),
        where: 'id = ?', whereArgs: [checklist.id]);
  }

  Future<void> deleteChecklist(String id) async {
    final db = await _dbHelper.database;
    await db.delete('checklists', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertItem(ChecklistItem item) async {
    final db = await _dbHelper.database;
    await db.insert('checklist_items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(ChecklistItem item) async {
    final db = await _dbHelper.database;
    await db.update('checklist_items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('checklist_items', where: 'id = ?', whereArgs: [id]);
  }
}
