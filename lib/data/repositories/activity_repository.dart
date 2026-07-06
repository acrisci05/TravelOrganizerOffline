import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/activity.dart';

class ActivityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Activity>> getByTrip(String tripId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'activities',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: 'dateTime ASC',
    );
    return maps.map(Activity.fromMap).toList();
  }

  Future<List<Activity>> getByStage(String stageId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'activities',
      where: 'stageId = ?',
      whereArgs: [stageId],
      orderBy: 'dateTime ASC',
    );
    return maps.map(Activity.fromMap).toList();
  }

  Future<List<Activity>> getByCategory(
      String tripId, ActivityCategory category) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'activities',
      where: 'tripId = ? AND category = ?',
      whereArgs: [tripId, category.index],
      orderBy: 'dateTime ASC',
    );
    return maps.map(Activity.fromMap).toList();
  }

  Future<void> insert(Activity activity) async {
    final db = await _dbHelper.database;
    await db.insert('activities', activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Activity activity) async {
    final db = await _dbHelper.database;
    await db.update('activities', activity.toMap(),
        where: 'id = ?', whereArgs: [activity.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByTrip(String tripId) async {
    final db = await _dbHelper.database;
    await db.delete('activities', where: 'tripId = ?', whereArgs: [tripId]);
  }
}
