enum TripStatus { future, ongoing, completed, archived }

extension TripStatusExtension on TripStatus {
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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get durationDays => endDate.difference(startDate).inDays + 1;

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
      'createdAt': createdAt.toIso8601String(),
    };
  }

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
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

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
      createdAt: createdAt,
    );
  }
}
