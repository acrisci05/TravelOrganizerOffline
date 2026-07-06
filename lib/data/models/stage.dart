class Stage {
  final String id;
  final String tripId;
  final String title;
  final DateTime date;
  final String? location;
  final String? description;
  final int order;
  final String? notes;

  Stage({
    required this.id,
    required this.tripId,
    required this.title,
    required this.date,
    this.location,
    this.description,
    required this.order,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'order': order,
      'notes': notes,
    };
  }

  factory Stage.fromMap(Map<String, dynamic> map) {
    return Stage(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String?,
      description: map['description'] as String?,
      order: map['order'] as int,
      notes: map['notes'] as String?,
    );
  }

  Stage copyWith({
    String? id,
    String? tripId,
    String? title,
    DateTime? date,
    String? location,
    String? description,
    int? order,
    String? notes,
  }) {
    return Stage(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }
}
