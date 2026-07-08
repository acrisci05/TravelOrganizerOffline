// Test unitari sulla logica di dominio dell'applicazione.
//
// Vengono verificate parti deterministiche e prive di dipendenze dal database
// (che in ambiente di unit test non è inizializzato): il calcolo dello stato
// del viaggio e la generazione della packing list per tipo di viaggio.

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_organizer/data/models/trip.dart';
import 'package:travel_organizer/data/models/packing_template.dart';

void main() {
  group('Trip.computedStatus', () {
    final oggi = DateTime.now();

    test('è futuro se le date sono successive ad oggi', () {
      final trip = Trip(
        id: '1',
        title: 'Test',
        destination: 'Roma',
        startDate: oggi.add(const Duration(days: 10)),
        endDate: oggi.add(const Duration(days: 15)),
      );
      expect(trip.computedStatus, TripStatus.future);
    });

    test('è in corso se oggi è compreso tra inizio e fine', () {
      final trip = Trip(
        id: '2',
        title: 'Test',
        destination: 'Roma',
        startDate: oggi.subtract(const Duration(days: 1)),
        endDate: oggi.add(const Duration(days: 1)),
      );
      expect(trip.computedStatus, TripStatus.ongoing);
    });

    test('è completato se le date sono nel passato', () {
      final trip = Trip(
        id: '3',
        title: 'Test',
        destination: 'Roma',
        startDate: oggi.subtract(const Duration(days: 15)),
        endDate: oggi.subtract(const Duration(days: 10)),
      );
      expect(trip.computedStatus, TripStatus.completed);
    });

    test('resta archiviato indipendentemente dalle date', () {
      final trip = Trip(
        id: '4',
        title: 'Test',
        destination: 'Roma',
        startDate: oggi.add(const Duration(days: 10)),
        endDate: oggi.add(const Duration(days: 15)),
        status: TripStatus.archived,
      );
      expect(trip.computedStatus, TripStatus.archived);
    });
  });

  group('Archiviazione manuale del viaggio', () {
    final oggi = DateTime.now();

    Trip futureTrip() => Trip(
          id: 'a',
          title: 'Test',
          destination: 'Roma',
          startDate: oggi.add(const Duration(days: 10)),
          endDate: oggi.add(const Duration(days: 15)),
        );

    test('dateStatus ignora lo stato archiviato e usa solo le date', () {
      final trip = futureTrip().copyWith(status: TripStatus.archived);
      // computedStatus resta archiviato, ma dateStatus riflette le date.
      expect(trip.computedStatus, TripStatus.archived);
      expect(trip.dateStatus, TripStatus.future);
    });

    test('archiviare e poi ripristinare riporta allo stato per data', () {
      final trip = futureTrip();
      // Archiviazione: lo stato diventa archiviato.
      final archiviato = trip.copyWith(status: TripStatus.archived);
      expect(archiviato.computedStatus, TripStatus.archived);
      // Ripristino: si riparte dallo stato calcolato dalle date.
      final ripristinato =
          archiviato.copyWith(status: archiviato.dateStatus);
      expect(ripristinato.computedStatus, TripStatus.future);
    });
  });

  test('durationDays include entrambi gli estremi', () {
    final trip = Trip(
      id: '5',
      title: 'Test',
      destination: 'Roma',
      startDate: DateTime(2026, 6, 5),
      endDate: DateTime(2026, 6, 9),
    );
    expect(trip.durationDays, 5);
  });

  group('Packing list per tipo di viaggio', () {
    test('contiene sia gli oggetti base sia quelli specifici del tipo', () {
      final lista = TripType.beach.buildPackingList();
      // Un oggetto della lista base
      expect(lista, contains(PackingTemplate.baseItems.first));
      // Un oggetto specifico del mare
      expect(lista, contains('👙 Costume da bagno'));
    });

    test('tipi diversi producono liste specifiche diverse', () {
      final mare = TripType.beach.buildPackingList();
      final montagna = TripType.mountain.buildPackingList();
      expect(mare, contains('👙 Costume da bagno'));
      expect(mare, isNot(contains('🥾 Scarponi da trekking')));
      expect(montagna, contains('🥾 Scarponi da trekking'));
    });
  });
}
