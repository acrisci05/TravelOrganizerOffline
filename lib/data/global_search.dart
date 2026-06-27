import 'package:flutter/material.dart';
import 'database/database_helper.dart';

// Tipo di elemento trovato dalla ricerca globale.
enum SearchResultType { trip, stage, activity, expense }

extension SearchResultTypeExtension on SearchResultType {
  // Etichetta della categoria di risultato (usata nelle intestazioni).
  String get label {
    switch (this) {
      case SearchResultType.trip:
        return 'Viaggi';
      case SearchResultType.stage:
        return 'Tappe';
      case SearchResultType.activity:
        return 'Attività';
      case SearchResultType.expense:
        return 'Spese';
    }
  }

  // Icona associata al tipo di risultato.
  IconData get icon {
    switch (this) {
      case SearchResultType.trip:
        return Icons.luggage_outlined;
      case SearchResultType.stage:
        return Icons.map_outlined;
      case SearchResultType.activity:
        return Icons.event_note_outlined;
      case SearchResultType.expense:
        return Icons.receipt_long_outlined;
    }
  }
}

// Singolo risultato della ricerca globale. [tripId] permette di aprire il
// viaggio collegato indipendentemente dal tipo di elemento.
class SearchResult {
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String tripId;

  SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.tripId,
  });
}

// Servizio di ricerca globale "Spotlight": cerca contemporaneamente tra viaggi,
// tappe, attività e spese eseguendo query SQL combinate sul database locale.
class GlobalSearchService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<SearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final like = '%${trimmed.toLowerCase()}%';
    final db = await _dbHelper.database;
    final results = <SearchResult>[];

    // Viaggi: per titolo, destinazione o note.
    final trips = await db.query(
      'trips',
      where: 'LOWER(title) LIKE ? OR LOWER(destination) LIKE ? OR LOWER(IFNULL(notes,\'\')) LIKE ?',
      whereArgs: [like, like, like],
    );
    for (final t in trips) {
      results.add(SearchResult(
        type: SearchResultType.trip,
        title: t['title'] as String,
        subtitle: 'Viaggio · ${t['destination']}',
        tripId: t['id'] as String,
      ));
    }

    // Tappe: per titolo o località.
    final stages = await db.query(
      'stages',
      where: 'LOWER(title) LIKE ? OR LOWER(IFNULL(location,\'\')) LIKE ?',
      whereArgs: [like, like],
    );
    for (final s in stages) {
      results.add(SearchResult(
        type: SearchResultType.stage,
        title: s['title'] as String,
        subtitle: 'Tappa${s['location'] != null ? ' · ${s['location']}' : ''}',
        tripId: s['tripId'] as String,
      ));
    }

    // Attività: per titolo, luogo o note.
    final activities = await db.query(
      'activities',
      where: 'LOWER(title) LIKE ? OR LOWER(IFNULL(location,\'\')) LIKE ? OR LOWER(IFNULL(notes,\'\')) LIKE ?',
      whereArgs: [like, like, like],
    );
    for (final a in activities) {
      results.add(SearchResult(
        type: SearchResultType.activity,
        title: a['title'] as String,
        subtitle: 'Attività${a['location'] != null ? ' · ${a['location']}' : ''}',
        tripId: a['tripId'] as String,
      ));
    }

    // Spese: per titolo o note.
    final expenses = await db.query(
      'expenses',
      where: 'LOWER(title) LIKE ? OR LOWER(IFNULL(notes,\'\')) LIKE ?',
      whereArgs: [like, like],
    );
    for (final e in expenses) {
      results.add(SearchResult(
        type: SearchResultType.expense,
        title: e['title'] as String,
        subtitle: 'Spesa · ${(e['amount'] as num).toStringAsFixed(2)} €',
        tripId: e['tripId'] as String,
      ));
    }

    return results;
  }
}
