enum ActivityStatus { todo, done, cancelled }
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

  String get icon {
    switch (this) {
      case ActivityCategory.visit:
        return '🏛️';
      case ActivityCategory.excursion:
        return '🥾';
      case ActivityCategory.meal:
        return '🍽️';
      case ActivityCategory.transport:
        return '🚌';
      case ActivityCategory.booking:
        return '🎫';
      case ActivityCategory.event:
        return '🎉';
      case ActivityCategory.free:
        return '☀️';
      case ActivityCategory.other:
        return '📌';
    }
  }
}

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
    );
  }

  Activity copyWith({
    String? id,
    String? tripId,
    String? stageId,
    bool clearStageId = false,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    ActivityCategory? category,
    double? estimatedCost,
    ActivityStatus? status,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      stageId: clearStageId ? null : (stageId ?? this.stageId),
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
