import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Expense>> getByTrip(String tripId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: 'date DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getByCategory(
      String tripId, ExpenseCategory category) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'tripId = ? AND category = ?',
      whereArgs: [tripId, category.index],
      orderBy: 'date DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getByStatus(
      String tripId, ExpenseStatus status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'tripId = ? AND status = ?',
      whereArgs: [tripId, status.index],
      orderBy: 'date DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<void> insert(Expense expense) async {
    final db = await _dbHelper.database;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Expense expense) async {
    final db = await _dbHelper.database;
    await db.update('expenses', expense.toMap(),
        where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByTrip(String tripId) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'tripId = ?', whereArgs: [tripId]);
  }
}
