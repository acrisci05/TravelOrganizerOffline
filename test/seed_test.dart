// Verifica che i dati di esempio (seed) vengano inseriti correttamente con
// tutte le entità collegate (tappe, attività, checklist, spese).
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travel_organizer/data/database/database_helper.dart';
import 'package:travel_organizer/data/models/trip.dart';
import 'package:travel_organizer/data/repositories/activity_repository.dart';
import 'package:travel_organizer/data/repositories/checklist_repository.dart';
import 'package:travel_organizer/data/repositories/stage_repository.dart';
import 'package:travel_organizer/data/repositories/trip_repository.dart';
import 'package:travel_organizer/data/seed/seed_data.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper().close();
    final path = join(await getDatabasesPath(), 'travel_organizer.db');
    await deleteDatabase(path);
  });

  test('il seed inserisce 4 viaggi di esempio completi', () async {
    await SeedData.populate();

    final trips = await TripRepository().getAll();
    expect(trips.length, 4);

    // Sono presenti i viaggi attesi.
    final titles = trips.map((t) => t.title).toList();
    expect(titles.any((t) => t.contains('Tokyo')), isTrue);
    expect(titles.any((t) => t.contains('Barcellona')), isTrue);
    expect(titles.any((t) => t.contains('Roma')), isTrue);
    expect(titles.any((t) => t.contains('Parigi')), isTrue);

    // Il viaggio a Parigi è in programma e ha un itinerario completo.
    final parigi = trips.firstWhere((t) => t.title.contains('Parigi'));
    expect(parigi.status, TripStatus.future);
    expect(parigi.transportMode, TransportMode.plane);
    expect(parigi.tags, contains('Estero'));

    final stages = await StageRepository().getByTrip(parigi.id);
    expect(stages.length, 5); // cinque giornate
    final activities = await ActivityRepository().getByTrip(parigi.id);
    expect(activities.length, greaterThan(5));
    final checklists = await ChecklistRepository().getByTrip(parigi.id);
    // Lista valigia (con sacchetti) + documenti.
    expect(checklists.length, 2);
    // Gli oggetti della valigia hanno il sacchetto (categoria) assegnato.
    final packing =
        checklists.firstWhere((c) => c.title == 'Lista Valigia');
    expect(packing.items.every((i) => i.category != null), isTrue);
  });
}
