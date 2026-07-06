import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/stage.dart';

class StageRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Stage>> getByTrip(String tripId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'stages',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: '"order" ASC, date ASC',
    );
    return maps.map(Stage.fromMap).toList();
  }

  Future<Stage?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('stages', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Stage.fromMap(maps.first);
  }

  Future<void> insert(Stage stage) async {
    final db = await _dbHelper.database;
    await db.insert('stages', stage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Stage stage) async {
    final db = await _dbHelper.database;
    await db.update('stages', stage.toMap(),
        where: 'id = ?', whereArgs: [stage.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('stages', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByTrip(String tripId) async {
    final db = await _dbHelper.database;
    await db.delete('stages', where: 'tripId = ?', whereArgs: [tripId]);
  }
}
