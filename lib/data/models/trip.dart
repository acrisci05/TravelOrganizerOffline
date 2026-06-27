import 'package:flutter/material.dart';

// Stato di un viaggio: futuro, in corso, completato o archiviato.
enum TripStatus { future, ongoing, completed, archived }

// Modalità principale con cui si svolge il viaggio.
enum TransportMode { car, plane, train, ship, cruise, bicycle, bus, foot }

extension TransportModeExtension on TransportMode {
  // Etichetta leggibile della modalità di viaggio.
  String get label {
    switch (this) {
      case TransportMode.car:
        return 'Auto';
      case TransportMode.plane:
        return 'Aereo';
      case TransportMode.train:
        return 'Treno';
      case TransportMode.ship:
        return 'Nave';
      case TransportMode.cruise:
        return 'Crociera';
      case TransportMode.bicycle:
        return 'Bicicletta';
      case TransportMode.bus:
        return 'Autobus';
      case TransportMode.foot:
        return 'A piedi';
    }
  }

  // Icona Material associata alla modalità di viaggio.
  IconData get icon {
    switch (this) {
      case TransportMode.car:
        return Icons.directions_car_outlined;
      case TransportMode.plane:
        return Icons.flight_outlined;
      case TransportMode.train:
        return Icons.train_outlined;
      case TransportMode.ship:
        return Icons.directions_boat_outlined;
      case TransportMode.cruise:
        return Icons.sailing_outlined;
      case TransportMode.bicycle:
        return Icons.directions_bike_outlined;
      case TransportMode.bus:
        return Icons.directions_bus_outlined;
      case TransportMode.foot:
        return Icons.directions_walk_outlined;
    }
  }
}

extension TripStatusExtension on TripStatus {
  // Etichetta leggibile dello stato, mostrata nella UI.
  String get label {
    switch (this) {
      case TripStatus.future:
        return 'Futuro';
      case TripStatus.ongoing:
        return 'In corso';
      case TripStatus.completed:
        return 'Completato';
      case TripStatus.archived:
        return 'Archiviato';
    }
  }
}

// Modello principale dell'app: rappresenta un viaggio con le sue informazioni
// generali. Tappe, attività, checklist e spese vi sono collegate tramite [id].
class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final TripStatus status;
  final double? budget;
  final String? participants;
  final String? notes;
  // Tag che caratterizzano il viaggio (es. Mare, Estero): guidano i suggerimenti
  // intelligenti della lista valigia.
  final List<String> tags;
  // Modalità principale di viaggio (auto, aereo, treno, ...). Può essere nulla.
  final TransportMode? transportMode;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.description,
    this.status = TripStatus.future,
    this.budget,
    this.participants,
    this.notes,
    this.tags = const [],
    this.transportMode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Durata del viaggio in giorni (estremi inclusi).
  int get durationDays => endDate.difference(startDate).inDays + 1;

  // Stato calcolato automaticamente confrontando le date con la data odierna:
  // un viaggio archiviato resta tale, altrimenti è futuro / in corso / completato.
  TripStatus get computedStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    if (status == TripStatus.archived) return TripStatus.archived;
    if (today.isBefore(start)) return TripStatus.future;
    if (today.isAfter(end)) return TripStatus.completed;
    return TripStatus.ongoing;
  }

  // Converte l'oggetto in una mappa per il salvataggio su database SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'status': status.index,
      'budget': budget,
      'participants': participants,
      'notes': notes,
      // I tag sono salvati come stringa separata da virgole.
      'tags': tags.join(','),
      'transportMode': transportMode?.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Ricostruisce un Trip a partire da una riga del database.
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String,
      destination: map['destination'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      description: map['description'] as String?,
      status: TripStatus.values[map['status'] as int],
      budget: map['budget'] as double?,
      participants: map['participants'] as String?,
      notes: map['notes'] as String?,
      // Ricostruisce la lista di tag dalla stringa salvata (ignora valori vuoti).
      tags: (map['tags'] as String?)
              ?.split(',')
              .where((t) => t.trim().isNotEmpty)
              .toList() ??
          const [],
      transportMode: map['transportMode'] != null
          ? TransportMode.values[map['transportMode'] as int]
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Crea una copia del viaggio modificando solo i campi indicati.
  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    TripStatus? status,
    double? budget,
    String? participants,
    String? notes,
    List<String>? tags,
    TransportMode? transportMode,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      participants: participants ?? this.participants,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      transportMode: transportMode ?? this.transportMode,
      createdAt: createdAt,
    );
  }
}
