class ChecklistItem {
  final String id;
  final String checklistId;
  final String title;
  final bool isCompleted;
  final int order;

  ChecklistItem({
    required this.id,
    required this.checklistId,
    required this.title,
    this.isCompleted = false,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checklistId': checklistId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'order': order,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      checklistId: map['checklistId'] as String,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      order: map['order'] as int,
    );
  }

  ChecklistItem copyWith({
    String? id,
    String? checklistId,
    String? title,
    bool? isCompleted,
    int? order,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      checklistId: checklistId ?? this.checklistId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }
}
