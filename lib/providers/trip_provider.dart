import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/trip.dart';
import '../data/repositories/trip_repository.dart';

// Gestisce lo stato dei viaggi (ChangeNotifier): caricamento, ricerca, filtri,
// creazione/modifica/eliminazione e controllo di integrità sulle date.
class TripProvider extends ChangeNotifier {
  final TripRepository _repo = TripRepository();
  final _uuid = const Uuid();

  List<Trip> _trips = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TripStatus? _filterStatus;

  List<Trip> get trips => _filteredTrips();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TripStatus? get filterStatus => _filterStatus;

  List<Trip> _filteredTrips() {
    var result = List<Trip>.from(_trips);
    if (_filterStatus != null) {
      result = result
          .where((t) => t.computedStatus == _filterStatus)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.destination.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();
    _trips = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Trip? getById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // Integrità dei dati: verifica se l'intervallo [start, end] si sovrappone alle
  // date di un viaggio già esistente. Restituisce il primo viaggio in conflitto
  // (o null se non ci sono sovrapposizioni). [excludeId] esclude dal controllo il
  // viaggio che si sta modificando. Due intervalli si sovrappongono quando
  // start <= altraFine && altraInizio <= end (confronto a livello di giorno).
  Trip? overlappingTrip(DateTime start, DateTime end, {String? excludeId}) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    for (final t in _trips) {
      if (t.id == excludeId) continue;
      final ts = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
      final te = DateTime(t.endDate.year, t.endDate.month, t.endDate.day);
      if (!s.isAfter(te) && !ts.isAfter(e)) return t;
    }
    return null;
  }

  Future<Trip> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    double? budget,
    String? participants,
    String? notes,
    List<String> tags = const [],
    TransportMode? transportMode,
  }) async {
    final trip = Trip(
      id: _uuid.v4(),
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      description: description,
      budget: budget,
      participants: participants,
      notes: notes,
      tags: tags,
      transportMode: transportMode,
    );
    await _repo.insert(trip);
    _trips.add(trip);
    notifyListeners();
    return trip;
  }

  Future<void> updateTrip(Trip trip) async {
    await _repo.update(trip);
    final idx = _trips.indexWhere((t) => t.id == trip.id);
    if (idx != -1) {
      _trips[idx] = trip;
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String id) async {
    await _repo.delete(id);
    _trips.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<Trip> duplicateTrip(Trip source) async {
    final newId = _uuid.v4();
    final copy = Trip(
      id: newId,
      title: '${source.title} (copia)',
      destination: source.destination,
      startDate: source.startDate,
      endDate: source.endDate,
      description: source.description,
      status: TripStatus.future,
      budget: source.budget,
      participants: source.participants,
      notes: source.notes,
      tags: source.tags,
      transportMode: source.transportMode,
    );
    await _repo.insert(copy);
    _trips.add(copy);
    notifyListeners();
    return copy;
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(TripStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    notifyListeners();
  }

  Map<TripStatus, int> get statusCounts {
    final counts = <TripStatus, int>{};
    for (final t in _trips) {
      final s = t.computedStatus;
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }
}
