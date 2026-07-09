import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/trip.dart';

class TripRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Trip>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('trips', orderBy: 'startDate ASC');
    return maps.map(Trip.fromMap).toList();
  }

  Future<Trip?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('trips', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Trip.fromMap(maps.first);
  }

  Future<List<Trip>> getByStatus(TripStatus status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'trips',
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'startDate ASC',
    );
    return maps.map(Trip.fromMap).toList();
  }

  Future<List<Trip>> search(String query) async {
    final db = await _dbHelper.database;
    final q = '%${query.toLowerCase()}%';
    final maps = await db.query(
      'trips',
      where: 'LOWER(title) LIKE ? OR LOWER(destination) LIKE ?',
      whereArgs: [q, q],
      orderBy: 'startDate ASC',
    );
    return maps.map(Trip.fromMap).toList();
  }

  Future<void> insert(Trip trip) async {
    final db = await _dbHelper.database;
    await db.insert('trips', trip.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Trip trip) async {
    final db = await _dbHelper.database;
    await db.update('trips', trip.toMap(), where: 'id = ?', whereArgs: [trip.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }
}
