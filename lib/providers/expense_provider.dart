import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/expense.dart';
import '../data/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();
  final _uuid = const Uuid();

  final Map<String, List<Expense>> _expensesByTrip = {};

  List<Expense> getByTrip(String tripId) => _expensesByTrip[tripId] ?? [];

  List<Expense> getByStatus(String tripId, ExpenseStatus status) =>
      (_expensesByTrip[tripId] ?? [])
          .where((e) => e.status == status)
          .toList();

  List<Expense> getByCategory(String tripId, ExpenseCategory category) =>
      (_expensesByTrip[tripId] ?? [])
          .where((e) => e.category == category)
          .toList();

  Future<void> loadForTrip(String tripId) async {
    _expensesByTrip[tripId] = await _repo.getByTrip(tripId);
    notifyListeners();
  }

  Future<void> addExpense({
    required String tripId,
    String? stageId,
    String? activityId,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    ExpenseStatus status = ExpenseStatus.actual,
    String? notes,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      tripId: tripId,
      stageId: stageId,
      activityId: activityId,
      title: title,
      amount: amount,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      status: status,
      notes: notes,
    );
    await _repo.insert(expense);
    final list = _expensesByTrip[tripId] ?? [];
    list.insert(0, expense);
    _expensesByTrip[tripId] = list;
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repo.update(expense);
    final list = _expensesByTrip[expense.tripId] ?? [];
    final idx = list.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      list[idx] = expense;
      _expensesByTrip[expense.tripId] = list;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    await _repo.delete(expenseId);
    _expensesByTrip[tripId]?.removeWhere((e) => e.id == expenseId);
    notifyListeners();
  }

  double totalActual(String tripId) =>
      getByStatus(tripId, ExpenseStatus.actual)
          .fold(0.0, (sum, e) => sum + e.amount);

  double totalPlanned(String tripId) =>
      getByStatus(tripId, ExpenseStatus.planned)
          .fold(0.0, (sum, e) => sum + e.amount);

  Map<ExpenseCategory, double> categoryTotals(String tripId) {
    final result = <ExpenseCategory, double>{};
    for (final e in _expensesByTrip[tripId] ?? []) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }
}
