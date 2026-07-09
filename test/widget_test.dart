import 'package:flutter_test/flutter_test.dart';
import 'package:travel_organizer/main.dart';
import 'package:provider/provider.dart';
import 'package:travel_organizer/providers/trip_provider.dart';
import 'package:travel_organizer/providers/stage_provider.dart';
import 'package:travel_organizer/providers/activity_provider.dart';
import 'package:travel_organizer/providers/checklist_provider.dart';
import 'package:travel_organizer/providers/expense_provider.dart';

void main() {
  testWidgets('App avvia correttamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TripProvider()),
          ChangeNotifierProvider(create: (_) => StageProvider()),
          ChangeNotifierProvider(create: (_) => ActivityProvider()),
          ChangeNotifierProvider(create: (_) => ChecklistProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ],
        child: const TravelOrganizerApp(),
      ),
    );
    expect(find.text('I Miei Viaggi'), findsOneWidget);
  });
}
