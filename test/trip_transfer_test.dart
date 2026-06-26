// Verifica l'esportazione e re-importazione di un viaggio: i dati collegati
// (tappe, attività, checklist con elementi, spese) devono essere preservati e
// gli ID rigenerati senza conflitti.
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travel_organizer/data/database/database_helper.dart';
import 'package:travel_organizer/data/models/activity.dart';
import 'package:travel_organizer/data/models/checklist.dart';
import 'package:travel_organizer/data/models/checklist_item.dart';
import 'package:travel_organizer/data/models/expense.dart';
import 'package:travel_organizer/data/models/stage.dart';
import 'package:travel_organizer/data/models/trip.dart';
import 'package:travel_organizer/data/repositories/activity_repository.dart';
import 'package:travel_organizer/data/repositories/checklist_repository.dart';
import 'package:travel_organizer/data/repositories/expense_repository.dart';
import 'package:travel_organizer/data/repositories/stage_repository.dart';
import 'package:travel_organizer/data/repositories/trip_repository.dart';
import 'package:travel_organizer/data/trip_transfer.dart';

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

  test('esporta e importa un viaggio mantenendo i dati collegati', () async {
    final tripRepo = TripRepository();
    final stageRepo = StageRepository();
    final actRepo = ActivityRepository();
    final clRepo = ChecklistRepository();
    final expRepo = ExpenseRepository();

    // Crea un viaggio completo.
    await tripRepo.insert(Trip(
      id: 't1',
      title: 'Roma',
      destination: 'Roma',
      startDate: DateTime(2026, 6, 5),
      endDate: DateTime(2026, 6, 9),
      tags: const ['Città', 'Estero'],
    ));
    await stageRepo.insert(Stage(
      id: 's1', tripId: 't1', title: 'Centro', date: DateTime(2026, 6, 5),
      order: 0,
    ));
    await actRepo.insert(Activity(
      id: 'a1', tripId: 't1', stageId: 's1', title: 'Colosseo',
      category: ActivityCategory.visit,
    ));
    await clRepo.insertChecklist(Checklist(
      id: 'c1', tripId: 't1', title: 'Documenti',
      items: [
        ChecklistItem(id: 'i1', checklistId: 'c1', title: 'Passaporto', order: 0),
        ChecklistItem(id: 'i2', checklistId: 'c1', title: 'Biglietti', order: 1),
      ],
    ));
    await expRepo.insert(Expense(
      id: 'e1', tripId: 't1', title: 'Hotel', amount: 100,
      category: ExpenseCategory.accommodation, date: DateTime(2026, 6, 5),
    ));

    // Esporta e re-importa.
    final service = TripTransferService();
    final json = await service.exportTrip('t1');
    final imported = await service.importTrip(json);

    // Il viaggio importato ha un nuovo id e conserva i tag.
    expect(imported.id, isNot('t1'));
    expect(imported.title, contains('importato'));
    expect(imported.tags, ['Città', 'Estero']);

    // I dati collegati sono presenti e ricollegati correttamente.
    final stages = await stageRepo.getByTrip(imported.id);
    final activities = await actRepo.getByTrip(imported.id);
    final checklists = await clRepo.getByTrip(imported.id);
    final expenses = await expRepo.getByTrip(imported.id);

    expect(stages.length, 1);
    expect(activities.length, 1);
    expect(activities.first.stageId, stages.first.id); // relazione ricollegata
    expect(checklists.length, 1);
    expect(checklists.first.items.length, 2);
    expect(expenses.length, 1);
  });
}
