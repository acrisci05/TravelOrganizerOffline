// Test di logica sul TripProvider: controllo di integrità sulle date dei viaggi
// (niente sovrapposizioni), eliminazione e stato calcolato del viaggio.
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:travel_organizer/data/database/database_helper.dart';
import 'package:travel_organizer/data/models/trip.dart';
import 'package:travel_organizer/providers/trip_provider.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Database pulito prima di ogni test per garantire risultati deterministici.
  setUp(() async {
    await DatabaseHelper().close();
    final path = join(await getDatabasesPath(), 'travel_organizer.db');
    await deleteDatabase(path);
  });

  group('Integrità date viaggi (niente sovrapposizioni)', () {
    test('rileva la sovrapposizione tra due viaggi', () async {
      final provider = TripProvider();
      await provider.loadTrips();
      await provider.addTrip(
        title: 'Roma',
        destination: 'Roma',
        startDate: DateTime(2026, 6, 5),
        endDate: DateTime(2026, 6, 9),
      );

      // 7–10 giugno si sovrappone al viaggio 5–9 giugno.
      final overlap = provider.overlappingTrip(
        DateTime(2026, 6, 7),
        DateTime(2026, 6, 10),
      );
      expect(overlap, isNotNull);
      expect(overlap!.title, 'Roma');
    });

    test('date consecutive non si sovrappongono', () async {
      final provider = TripProvider();
      await provider.loadTrips();
      await provider.addTrip(
        title: 'Roma',
        destination: 'Roma',
        startDate: DateTime(2026, 6, 5),
        endDate: DateTime(2026, 6, 9),
      );

      // 10–12 giugno è successivo e non genera conflitto.
      final overlap = provider.overlappingTrip(
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 12),
      );
      expect(overlap, isNull);
    });

    test('un viaggio non va in conflitto con se stesso in modifica', () async {
      final provider = TripProvider();
      await provider.loadTrips();
      final trip = await provider.addTrip(
        title: 'Roma',
        destination: 'Roma',
        startDate: DateTime(2026, 6, 5),
        endDate: DateTime(2026, 6, 9),
      );

      final overlap = provider.overlappingTrip(
        DateTime(2026, 6, 5),
        DateTime(2026, 6, 9),
        excludeId: trip.id,
      );
      expect(overlap, isNull);
    });
  });

  test('eliminando un viaggio viene rimosso dalla lista', () async {
    final provider = TripProvider();
    await provider.loadTrips();
    final trip = await provider.addTrip(
      title: 'Napoli',
      destination: 'Napoli',
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 3),
    );
    expect(provider.trips.length, 1);

    await provider.deleteTrip(trip.id);
    expect(provider.trips, isEmpty);
    expect(provider.getById(trip.id), isNull);
  });

  group('Stato calcolato del viaggio', () {
    test('un viaggio passato risulta completato', () {
      final trip = Trip(
        id: '1',
        title: 'Passato',
        destination: 'X',
        startDate: DateTime(2020, 1, 1),
        endDate: DateTime(2020, 1, 5),
      );
      expect(trip.computedStatus, TripStatus.completed);
      expect(trip.durationDays, 5);
    });

    test('un viaggio futuro risulta futuro', () {
      final start = DateTime.now().add(const Duration(days: 30));
      final trip = Trip(
        id: '2',
        title: 'Futuro',
        destination: 'X',
        startDate: start,
        endDate: start.add(const Duration(days: 4)),
      );
      expect(trip.computedStatus, TripStatus.future);
    });
  });
}
