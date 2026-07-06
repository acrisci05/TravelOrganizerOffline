enum ExpenseCategory { transport, accommodation, food, activity, shopping, health, other }
enum ExpenseStatus { planned, actual }
enum PaymentMethod { cash, card, transfer, other }

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.transport:
        return 'Trasporto';
      case ExpenseCategory.accommodation:
        return 'Alloggio';
      case ExpenseCategory.food:
        return 'Cibo';
      case ExpenseCategory.activity:
        return 'Attività';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.health:
        return 'Salute';
      case ExpenseCategory.other:
        return 'Altro';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.transport:
        return '✈️';
      case ExpenseCategory.accommodation:
        return '🏨';
      case ExpenseCategory.food:
        return '🍕';
      case ExpenseCategory.activity:
        return '🎯';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.health:
        return '💊';
      case ExpenseCategory.other:
        return '💰';
    }
  }
}

extension ExpenseStatusExtension on ExpenseStatus {
  String get label => this == ExpenseStatus.planned ? 'Prevista' : 'Effettiva';
}

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Contanti';
      case PaymentMethod.card:
        return 'Carta';
      case PaymentMethod.transfer:
        return 'Bonifico';
      case PaymentMethod.other:
        return 'Altro';
    }
  }
}

class Expense {
  final String id;
  final String tripId;
  final String? stageId;
  final String? activityId;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final ExpenseStatus status;
  final String? notes;

  Expense({
    required this.id,
    required this.tripId,
    this.stageId,
    this.activityId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.paymentMethod = PaymentMethod.cash,
    this.status = ExpenseStatus.actual,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'stageId': stageId,
      'activityId': activityId,
      'title': title,
      'amount': amount,
      'category': category.index,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod.index,
      'status': status.index,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      stageId: map['stageId'] as String?,
      activityId: map['activityId'] as String?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.values[map['category'] as int],
      date: DateTime.parse(map['date'] as String),
      paymentMethod: PaymentMethod.values[map['paymentMethod'] as int],
      status: ExpenseStatus.values[map['status'] as int],
      notes: map['notes'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    String? tripId,
    String? stageId,
    String? activityId,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    PaymentMethod? paymentMethod,
    ExpenseStatus? status,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      stageId: stageId ?? this.stageId,
      activityId: activityId ?? this.activityId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
