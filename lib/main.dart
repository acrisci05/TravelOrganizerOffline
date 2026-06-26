import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'core/theme/app_theme.dart';
import 'providers/trip_provider.dart';
import 'providers/stage_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/expense_provider.dart';
import 'features/trips/trips_list_screen.dart';
import 'features/stats/stats_screen.dart';

void main() async {
  // Inizializza il binding Flutter prima di eseguire operazioni asincrone.
  WidgetsFlutterBinding.ensureInitialized();
  // Su Web SQLite viene eseguito tramite WebAssembly: imposta la factory dedicata.
  if (kIsWeb) databaseFactory = databaseFactoryFfiWeb;
  // Carica i dati di localizzazione italiana (formati di date e valuta).
  await initializeDateFormatting('it_IT', null);
  // L'app parte sempre con un archivio vuoto: tutti i dati sono inseriti dall'utente.
  runApp(const TravelOrganizerApp());
}

// Widget radice dell'app: registra i provider globali (gestione dello stato)
// e configura MaterialApp con tema e schermata iniziale.
class TravelOrganizerApp extends StatelessWidget {
  const TravelOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => StageProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Travel Organizer',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const _AppShell(),
      ),
    );
  }
}

// Contenitore principale con la barra di navigazione a due sezioni
// (Viaggi e Statistiche). Usa un IndexedStack per conservare lo stato dei tab.
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    TripsListScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) =>
            setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage),
            label: 'Viaggi',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }
}
