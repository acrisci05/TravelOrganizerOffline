import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/trip_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'expense_form_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final String tripId;
  const ExpensesScreen({super.key, required this.tripId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpenseStatus? _filterStatus;
  ExpenseCategory? _filterCategory;
  double? _minAmount;
  double? _maxAmount;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        var expenses = provider.getByTrip(widget.tripId);
        if (_filterStatus != null) {
          expenses =
              expenses.where((e) => e.status == _filterStatus).toList();
        }
        if (_filterCategory != null) {
          expenses = expenses
              .where((e) => e.category == _filterCategory)
              .toList();
        }
        if (_minAmount != null) {
          expenses =
              expenses.where((e) => e.amount >= _minAmount!).toList();
        }
        if (_maxAmount != null) {
          expenses =
              expenses.where((e) => e.amount <= _maxAmount!).toList();
        }

        final totalActual = provider.totalActual(widget.tripId);
        final totalPlanned = provider.totalPlanned(widget.tripId);
        final trip =
            context.read<TripProvider>().getById(widget.tripId);
        final budget = trip?.budget;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _SummaryBar(
                totalActual: totalActual,
                totalPlanned: totalPlanned,
                budget: budget,
              ),
              _FilterBar(
                selectedStatus: _filterStatus,
                selectedCategory: _filterCategory,
                minAmount: _minAmount,
                maxAmount: _maxAmount,
                onStatusChanged: (s) =>
                    setState(() => _filterStatus = s),
                onCategoryChanged: (c) =>
                    setState(() => _filterCategory = c),
                onAmountFilter: () => _showAmountDialog(context),
                onClearAmount: () => setState(() {
                  _minAmount = null;
                  _maxAmount = null;
                }),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Nessuna spesa',
                        subtitle:
                            _filterStatus != null ||
                                    _filterCategory != null ||
                                    _minAmount != null ||
                                    _maxAmount != null
                                ? 'Nessuna spesa corrisponde ai filtri'
                                : 'Traccia le spese del viaggio',
                        actionLabel: _filterStatus == null &&
                                _filterCategory == null &&
                                _minAmount == null &&
                                _maxAmount == null
                            ? 'Aggiungi spesa'
                            : null,
                        onAction: _filterStatus == null &&
                                _filterCategory == null &&
                                _minAmount == null &&
                                _maxAmount == null
                            ? () => _openForm(context)
                            : null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: expenses.length,
                        itemBuilder: (ctx, i) => _ExpenseTile(
                          expense: expenses[i],
                          tripId: widget.tripId,
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi spesa'),
          ),
        );
      },
    );
  }

  Future<void> _showAmountDialog(BuildContext context) async {
    final minCtrl = TextEditingController(
        text: _minAmount?.toStringAsFixed(0) ?? '');
    final maxCtrl = TextEditingController(
        text: _maxAmount?.toStringAsFixed(0) ?? '');

    final result = await showDialog<(double?, double?)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filtra per importo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minCtrl,
              decoration: const InputDecoration(
                labelText: 'Importo minimo (€)',
                prefixText: '€ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxCtrl,
              decoration: const InputDecoration(
                labelText: 'Importo massimo (€)',
                prefixText: '€ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop((null, null) as (double?, double?)),
            child: const Text('Azzera'),
          ),
          ElevatedButton(
            onPressed: () {
              final min =
                  double.tryParse(minCtrl.text.replaceAll(',', '.'));
              final max =
                  double.tryParse(maxCtrl.text.replaceAll(',', '.'));
              Navigator.of(ctx).pop((min, max));
            },
            child: const Text('Applica'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _minAmount = result.$1;
        _maxAmount = result.$2;
      });
    }
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) =>
              ExpenseFormScreen(tripId: widget.tripId)),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final double totalActual;
  final double totalPlanned;
  final double? budget;

  const _SummaryBar({
    required this.totalActual,
    required this.totalPlanned,
    this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final overBudget = budget != null && totalActual > budget!;
    return Container(
      color: AppColors.primary,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
                label: 'Spese effettive',
                value: DateFormatter.currency(totalActual),
                color: overBudget ? AppColors.error : Colors.white),
          ),
          Container(width: 1, height: 36, color: Colors.white30),
          Expanded(
            child: _Stat(
                label: 'Spese previste',
                value: DateFormatter.currency(totalPlanned),
                color: Colors.white),
          ),
          if (budget != null) ...[
            Container(width: 1, height: 36, color: Colors.white30),
            Expanded(
              child: _Stat(
                  label: 'Budget',
                  value: DateFormatter.currency(budget!),
                  color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat(
      {required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final ExpenseStatus? selectedStatus;
  final ExpenseCategory? selectedCategory;
  final double? minAmount;
  final double? maxAmount;
  final ValueChanged<ExpenseStatus?> onStatusChanged;
  final ValueChanged<ExpenseCategory?> onCategoryChanged;
  final VoidCallback onAmountFilter;
  final VoidCallback onClearAmount;

  const _FilterBar({
    required this.selectedStatus,
    required this.selectedCategory,
    required this.minAmount,
    required this.maxAmount,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onAmountFilter,
    required this.onClearAmount,
  });

  String get _amountLabel {
    if (minAmount != null && maxAmount != null) {
      return '≥${minAmount!.toStringAsFixed(0)}€ · ≤${maxAmount!.toStringAsFixed(0)}€';
    } else if (minAmount != null) {
      return '≥${minAmount!.toStringAsFixed(0)}€';
    } else if (maxAmount != null) {
      return '≤${maxAmount!.toStringAsFixed(0)}€';
    }
    return 'Importo';
  }

  @override
  Widget build(BuildContext context) {
    final hasAmountFilter = minAmount != null || maxAmount != null;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            FilterChip(
              label: const Text('Tutte'),
              selected: selectedStatus == null &&
                  selectedCategory == null &&
                  !hasAmountFilter,
              onSelected: (_) {
                onStatusChanged(null);
                onCategoryChanged(null);
                onClearAmount();
              },
            ),
            const SizedBox(width: 6),
            ...ExpenseStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(s.label),
                    selected: selectedStatus == s,
                    onSelected: (_) => onStatusChanged(
                        selectedStatus == s ? null : s),
                  ),
                )),
            const VerticalDivider(width: 16),
            ...ExpenseCategory.values.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text('${c.icon} ${c.label}'),
                    selected: selectedCategory == c,
                    onSelected: (_) => onCategoryChanged(
                        selectedCategory == c ? null : c),
                  ),
                )),
            const VerticalDivider(width: 16),
            FilterChip(
              avatar: hasAmountFilter
                  ? null
                  : const Icon(Icons.euro, size: 14),
              label: Text(_amountLabel),
              selected: hasAmountFilter,
              onSelected: (_) => onAmountFilter(),
              showCheckmark: false,
              deleteIcon: hasAmountFilter
                  ? const Icon(Icons.close, size: 14)
                  : null,
              onDeleted: hasAmountFilter ? onClearAmount : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final String tripId;
  const _ExpenseTile(
      {required this.expense, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ExpenseFormScreen(
              tripId: tripId, existingExpense: expense),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(expense.category.icon,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${expense.category.label} • ${DateFormatter.date(expense.date)}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                    Text(
                      expense.paymentMethod.label,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormatter.currency(expense.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusChip.expense(expense.status),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _delete(context),
                    child: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Elimina spesa',
      message: 'Vuoi eliminare "${expense.title}"?',
    );
    if (confirmed && context.mounted) {
      await context
          .read<ExpenseProvider>()
          .deleteExpense(tripId, expense.id);
    }
  }
}
