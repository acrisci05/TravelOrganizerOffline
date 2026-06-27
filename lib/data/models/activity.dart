import 'package:flutter/material.dart';

// Stato di un'attività: da fare, completata o annullata.
enum ActivityStatus { todo, done, cancelled }

// Categoria dell'attività (visita, escursione, pasto, ecc.), usata per filtri e icone.
enum ActivityCategory { visit, excursion, meal, transport, booking, event, free, other }

extension ActivityStatusExtension on ActivityStatus {
  String get label {
    switch (this) {
      case ActivityStatus.todo:
        return 'Da fare';
      case ActivityStatus.done:
        return 'Completata';
      case ActivityStatus.cancelled:
        return 'Annullata';
    }
  }
}

extension ActivityCategoryExtension on ActivityCategory {
  String get label {
    switch (this) {
      case ActivityCategory.visit:
        return 'Visita';
      case ActivityCategory.excursion:
        return 'Escursione';
      case ActivityCategory.meal:
        return 'Pasto';
      case ActivityCategory.transport:
        return 'Trasporto';
      case ActivityCategory.booking:
        return 'Prenotazione';
      case ActivityCategory.event:
        return 'Evento';
      case ActivityCategory.free:
        return 'Tempo libero';
      case ActivityCategory.other:
        return 'Altro';
    }
  }

  // Icona Material associata alla categoria, mostrata nelle liste, nei filtri
  // e nella timeline al posto delle vecchie emoji.
  IconData get icon {
    switch (this) {
      case ActivityCategory.visit:
        return Icons.museum_outlined;
      case ActivityCategory.excursion:
        return Icons.hiking_outlined;
      case ActivityCategory.meal:
        return Icons.restaurant_outlined;
      case ActivityCategory.transport:
        return Icons.directions_bus_outlined;
      case ActivityCategory.booking:
        return Icons.confirmation_number_outlined;
      case ActivityCategory.event:
        return Icons.celebration_outlined;
      case ActivityCategory.free:
        return Icons.wb_sunny_outlined;
      case ActivityCategory.other:
        return Icons.push_pin_outlined;
    }
  }

  // Colore associato alla categoria, usato per i "blocchi" colorati della timeline
  // (es. pasti = arancione, spostamenti = blu/indaco).
  Color get color {
    switch (this) {
      case ActivityCategory.visit:
        return const Color(0xFF1E88E5); // blu
      case ActivityCategory.excursion:
        return const Color(0xFF43A047); // verde
      case ActivityCategory.meal:
        return const Color(0xFFFB8C00); // arancione
      case ActivityCategory.transport:
        return const Color(0xFF3949AB); // indaco
      case ActivityCategory.booking:
        return const Color(0xFF8E24AA); // viola
      case ActivityCategory.event:
        return const Color(0xFFE53935); // rosso
      case ActivityCategory.free:
        return const Color(0xFF00ACC1); // azzurro
      case ActivityCategory.other:
        return const Color(0xFF757575); // grigio
    }
  }
}

// Attività dell'itinerario, collegata a un viaggio ([tripId]) e, facoltativamente,
// a una tappa ([stageId]).
class Activity {
  final String id;
  final String tripId;
  final String? stageId;
  final String title;
  final String? description;
  final DateTime? dateTime;
  final String? location;
  final ActivityCategory category;
  final double? estimatedCost;
  final ActivityStatus status;
  final String? notes;
  // Diario di viaggio: pensiero scritto dall'utente sull'attività svolta.
  final String? journalNote;
  // Percorso locale della foto associata all'attività (galleria/fotocamera).
  final String? photoPath;

  Activity({
    required this.id,
    required this.tripId,
    this.stageId,
    required this.title,
    this.description,
    this.dateTime,
    this.location,
    this.category = ActivityCategory.other,
    this.estimatedCost,
    this.status = ActivityStatus.todo,
    this.notes,
    this.journalNote,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'stageId': stageId,
      'title': title,
      'description': description,
      'dateTime': dateTime?.toIso8601String(),
      'location': location,
      'category': category.index,
      'estimatedCost': estimatedCost,
      'status': status.index,
      'notes': notes,
      'journalNote': journalNote,
      'photoPath': photoPath,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      stageId: map['stageId'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'] as String)
          : null,
      location: map['location'] as String?,
      category: ActivityCategory.values[map['category'] as int],
      estimatedCost: map['estimatedCost'] as double?,
      status: ActivityStatus.values[map['status'] as int],
      notes: map['notes'] as String?,
      journalNote: map['journalNote'] as String?,
      photoPath: map['photoPath'] as String?,
    );
  }

  Activity copyWith({
    String? id,
    String? tripId,
    String? stageId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    ActivityCategory? category,
    double? estimatedCost,
    ActivityStatus? status,
    String? notes,
    String? journalNote,
    String? photoPath,
  }) {
    return Activity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      stageId: stageId ?? this.stageId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      journalNote: journalNote ?? this.journalNote,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
