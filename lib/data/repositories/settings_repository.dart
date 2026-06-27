import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

// Repository delle impostazioni: semplice archivio chiave-valore su SQLite,
// usato per dati che non appartengono a un viaggio (es. dati di emergenza ICE).
class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Legge il valore associato a una chiave (null se assente).
  Future<String?> get(String key) async {
    final db = await _dbHelper.database;
    final rows =
        await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  // Salva (o aggiorna) il valore di una chiave.
  Future<void> set(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
