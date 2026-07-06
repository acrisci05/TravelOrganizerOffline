import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      return openDatabase(
        'travel_organizer.db',
        version: 1,
        onCreate: _onCreate,
        onConfigure: (db) async =>
            await db.execute('PRAGMA foreign_keys = ON'),
      );
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'travel_organizer.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        destination TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        description TEXT,
        status INTEGER NOT NULL DEFAULT 0,
        budget REAL,
        participants TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stages (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        "order" INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        stageId TEXT,
        title TEXT NOT NULL,
        description TEXT,
        dateTime TEXT,
        location TEXT,
        category INTEGER NOT NULL DEFAULT 7,
        estimatedCost REAL,
        status INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE,
        FOREIGN KEY (stageId) REFERENCES stages(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE checklists (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        stageId TEXT,
        title TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE,
        FOREIGN KEY (stageId) REFERENCES stages(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE checklist_items (
        id TEXT PRIMARY KEY,
        checklistId TEXT NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        "order" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (checklistId) REFERENCES checklists(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        stageId TEXT,
        activityId TEXT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category INTEGER NOT NULL DEFAULT 6,
        date TEXT NOT NULL,
        paymentMethod INTEGER NOT NULL DEFAULT 0,
        status INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_stages_tripId ON stages(tripId)');
    await db.execute('CREATE INDEX idx_activities_tripId ON activities(tripId)');
    await db.execute('CREATE INDEX idx_activities_stageId ON activities(stageId)');
    await db.execute('CREATE INDEX idx_checklists_tripId ON checklists(tripId)');
    await db.execute('CREATE INDEX idx_checklist_items_checklistId ON checklist_items(checklistId)');
    await db.execute('CREATE INDEX idx_expenses_tripId ON expenses(tripId)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
