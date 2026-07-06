import 'checklist_item.dart';

class Checklist {
  final String id;
  final String tripId;
  final String? stageId;
  final String title;
  final String? description;
  final List<ChecklistItem> items;

  Checklist({
    required this.id,
    required this.tripId,
    this.stageId,
    required this.title,
    this.description,
    this.items = const [],
  });

  int get totalItems => items.length;
  int get completedItems => items.where((i) => i.isCompleted).length;
  bool get isCompleted => totalItems > 0 && completedItems == totalItems;
  double get progress => totalItems == 0 ? 0 : completedItems / totalItems;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'stageId': stageId,
      'title': title,
      'description': description,
    };
  }

  factory Checklist.fromMap(Map<String, dynamic> map,
      {List<ChecklistItem>? items}) {
    return Checklist(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      stageId: map['stageId'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      items: items ?? [],
    );
  }

  Checklist copyWith({
    String? id,
    String? tripId,
    String? stageId,
    String? title,
    String? description,
    List<ChecklistItem>? items,
  }) {
    return Checklist(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      stageId: stageId ?? this.stageId,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }
}
