// Test di "smoke": verifica che l'app si avvii correttamente e mostri la lista
// dei viaggi vuota (l'app parte sempre senza dati di esempio).
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travel_organizer/main.dart';
import 'package:travel_organizer/data/database/database_helper.dart';
import 'package:travel_organizer/providers/trip_provider.dart';
import 'package:travel_organizer/providers/stage_provider.dart';
import 'package:travel_organizer/providers/activity_provider.dart';
import 'package:travel_organizer/providers/checklist_provider.dart';
import 'package:travel_organizer/providers/expense_provider.dart';

void main() {
  // Inizializza SQLite tramite FFI e i dati di localizzazione (necessari al
  // calendario) per eseguire i test su desktop/CI.
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await initializeDateFormatting('it_IT', null);
  });

  // Ogni test parte da un database pulito.
  setUp(() async {
    await DatabaseHelper().close();
    final path = join(await getDatabasesPath(), 'travel_organizer.db');
    await deleteDatabase(path);
  });

  testWidgets('L\'app si avvia e mostra la lista viaggi vuota',
      (WidgetTester tester) async {
    final app = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => StageProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const TravelOrganizerApp(),
    );

    // runAsync permette di completare il caricamento reale dal database SQLite,
    // che gira sull'event loop reale e non sul tempo simulato dei test.
    await tester.runAsync(() async {
      await tester.pumpWidget(app);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pump();
    });

    expect(find.text('I Miei Viaggi'), findsOneWidget);
    expect(find.text('Nessun viaggio trovato'), findsOneWidget);
  });
}
