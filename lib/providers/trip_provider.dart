import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/trip.dart';
import '../data/repositories/trip_repository.dart';

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

  // Metodo per filtrare i trips
  List<Trip> _filteredTrips() {
    var result = List<Trip>.from(_trips);
    if (_filterStatus != null) {
      result = result
          .where((trip) => trip.computedStatus == _filterStatus)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where(
            (trip) =>
                trip.title.toLowerCase().contains(query) ||
                trip.destination.toLowerCase().contains(query),
          )
          .toList();
    }
    return result;
  }

  // Lista ordinata
  List<Trip> get tripsSortedByStatus {
    final list = _filteredTrips(); //Trips filtrati per search e status
    list.sort((a, b) {
      int priority(TripStatus s) {
        switch (s) {
          case TripStatus.ongoing:
            return 0;
          case TripStatus.future:
            return 1;
          case TripStatus.completed:
            return 3;
          case TripStatus.archived:
            return 4;
        }
      }
      int priorityA = priority(a.computedStatus);
      int priorityB = priority(b.computedStatus);
      
      int cmp = priorityA.compareTo(priorityB);

      if(cmp != 0){
        return priorityA.compareTo(priorityB);
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return list;
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

  // Aggiungere un trip
  //  Requisiti: titolo, destinazione, data di inizio, data di fine
  Future<Trip> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    double? budget,
    String? participants,
    String? notes,
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
    );
    await _repo.insert(trip);
    _trips.add(trip);
    notifyListeners();
    return trip;
  }

  // Update del trip
  Future<void> updateTrip(Trip trip) async {
    await _repo.update(trip);
    final idx = _trips.indexWhere((t) => t.id == trip.id);
    if (idx != -1) {
      _trips[idx] = trip;
      notifyListeners();
    }
  }

  // Cancellazione del trip
  Future<void> deleteTrip(String id) async {
    await _repo.delete(id);
    _trips.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Duplicare il trip
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
    );
    await _repo.insert(copy);
    _trips.add(copy);
    notifyListeners();
    return copy;
  }

  // Setter della stringa di ricerca
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Setter dei filtri di stato del trip
  void setFilter(TripStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Metodo che azzera i filtri
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    notifyListeners();
  }

  // Metodo che restituisce una mappa con numero di viaggi per stato
  Map<TripStatus, int> get statusCounts {
    final counts = <TripStatus, int>{};
    for (final t in _trips) {
      final s = t.computedStatus;
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }
}
