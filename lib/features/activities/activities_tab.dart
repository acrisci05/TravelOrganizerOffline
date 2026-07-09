import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/activity.dart';
import '../../data/models/expense.dart';
import '../../providers/activity_provider.dart';
import '../../providers/expense_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'activity_form_screen.dart';

class ActivitiesTab extends StatefulWidget {
  final String tripId;
  const ActivitiesTab({super.key, required this.tripId});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  ActivityCategory? _filterCategory;
  ActivityStatus? _filterStatus;
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, provider, _) {
        var activities = provider.getByTrip(widget.tripId);
        if (_filterCategory != null) {
          activities = activities
              .where((a) => a.category == _filterCategory)
              .toList();
        }
        if (_filterStatus != null) {
          activities = activities
              .where((a) => a.status == _filterStatus)
              .toList();
        }
        if (_filterDate != null) {
          activities = activities
              .where(
                (a) =>
                    a.dateTime != null &&
                    a.dateTime!.year == _filterDate!.year &&
                    a.dateTime!.month == _filterDate!.month &&
                    a.dateTime!.day == _filterDate!.day,
              )
              .toList();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _FilterBar(
                selectedCategory: _filterCategory,
                selectedStatus: _filterStatus,
                selectedDate: _filterDate,
                onCategoryChanged: (c) => setState(() => _filterCategory = c),
                onStatusChanged: (s) => setState(() => _filterStatus = s),
                onDatePicker: () => _pickDate(context),
                onDateClear: () => setState(() => _filterDate = null),
              ),
              Expanded(
                child: activities.isEmpty
                    ? EmptyState(
                        icon: Icons.event_note_outlined,
                        title:
                            _filterCategory != null ||
                                _filterStatus != null ||
                                _filterDate != null
                            ? 'Nessun risultato'
                            : 'Nessuna attività',
                        subtitle:
                            _filterCategory != null ||
                                _filterStatus != null ||
                                _filterDate != null
                            ? 'Prova a cambiare i filtri'
                            : 'Aggiungi le attività del viaggio',
                        actionLabel:
                            _filterCategory == null &&
                                _filterStatus == null &&
                                _filterDate == null
                            ? 'Aggiungi'
                            : null,
                        onAction:
                            _filterCategory == null &&
                                _filterStatus == null &&
                                _filterDate == null
                            ? () => _openForm(context)
                            : null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: activities.length,
                        itemBuilder: (ctx, i) => _ActivityCard(
                          activity: activities[i],
                          tripId: widget.tripId,
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openForm(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _filterDate = picked);
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityFormScreen(tripId: widget.tripId),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final ActivityCategory? selectedCategory;
  final ActivityStatus? selectedStatus;
  final DateTime? selectedDate;
  final ValueChanged<ActivityCategory?> onCategoryChanged;
  final ValueChanged<ActivityStatus?> onStatusChanged;
  final VoidCallback onDatePicker;
  final VoidCallback onDateClear;

  const _FilterBar({
    required this.selectedCategory,
    required this.selectedStatus,
    required this.selectedDate,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onDatePicker,
    required this.onDateClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            FilterChip(
              label: const Text('Tutte'),
              selected:
                  selectedCategory == null &&
                  selectedStatus == null &&
                  selectedDate == null,
              onSelected: (_) {
                onCategoryChanged(null);
                onStatusChanged(null);
                onDateClear();
              },
            ),
            const SizedBox(width: 6),
            ...ActivityCategory.values.map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text('${c.icon} ${c.label}'),
                  selected: selectedCategory == c,
                  onSelected: (_) =>
                      onCategoryChanged(selectedCategory == c ? null : c),
                ),
              ),
            ),
            const VerticalDivider(width: 16),
            ...ActivityStatus.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(s.label),
                  selected: selectedStatus == s,
                  onSelected: (_) =>
                      onStatusChanged(selectedStatus == s ? null : s),
                ),
              ),
            ),
            const VerticalDivider(width: 16),
            FilterChip(
              avatar: selectedDate == null
                  ? const Icon(Icons.calendar_today_outlined, size: 14)
                  : null,
              label: Text(
                selectedDate != null
                    ? DateFormatter.date(selectedDate!)
                    : 'Per giorno',
              ),
              selected: selectedDate != null,
              onSelected: (_) => onDatePicker(),
              showCheckmark: false,
              deleteIcon: selectedDate != null
                  ? const Icon(Icons.close, size: 14)
                  : null,
              onDeleted: selectedDate != null ? onDateClear : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final String tripId;
  const _ActivityCard({required this.activity, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().getByTrip(tripId);

    final actualExpenses = expenses
        .where(
          (e) =>
              e.activityId == activity.id && e.status == ExpenseStatus.actual,
        )
        .toList();

    final hasActualExpense = actualExpenses.isNotEmpty;

    final actualExpenseAmount = actualExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ActivityFormScreen(tripId: tripId, existingActivity: activity),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _onStatusTap(context),
                child: Icon(
                  activity.status == ActivityStatus.done
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: activity.status == ActivityStatus.done
                      ? AppColors.success
                      : AppColors.textHint,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                activity.category.icon,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: activity.status == ActivityStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: activity.status == ActivityStatus.done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (activity.dateTime != null)
                      Text(
                        DateFormatter.dateTime(activity.dateTime!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (activity.location != null)
                      Text(
                        activity.location!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // if (activity.estimatedCost != null)
                    //   Text(
                    //     DateFormatter.currency(activity.estimatedCost!),
                    //     style: const TextStyle(
                    //       fontSize: 12,
                    //       color: AppColors.primary,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    if (activity.estimatedCost != null || hasActualExpense)
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            if (activity.estimatedCost != null)
                              TextSpan(
                                text:
                                    'Previsto: ${DateFormatter.currency(activity.estimatedCost!)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            if (activity.estimatedCost != null &&
                                hasActualExpense)
                              const TextSpan(
                                text: '\n',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            if (hasActualExpense)
                              TextSpan(
                                text:
                                    'Effettivo: ${DateFormatter.currency(actualExpenseAmount)}',
                                style: const TextStyle(
                                  color: AppColors.success,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip.activity(activity.status),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _delete(context),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onStatusTap(BuildContext context) async {
    final activityProvider = context.read<ActivityProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text: activity.estimatedCost?.toString() ?? '',
    );

    if (activity.status == ActivityStatus.done) {
      final expenses = expenseProvider.getByTrip(tripId);
      final actualExpense = expenses
          .where(
            (e) =>
                e.activityId == activity.id && e.status == ExpenseStatus.actual,
          )
          .toList();
      for (final exp in actualExpense) {
        await expenseProvider.deleteExpense(activity.tripId, exp.id);
      }

      await activityProvider.toggleStatus(activity);
      return;
    }

    final amount = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // title: const Text('Quanto è costata l\'attività?'),
        // content: TextField(
        //   controller : controller,
        //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
        //   decoration: const InputDecoration(
        //     labelText: 'Importo effettivo (€)',
        //     prefixIcon: Icon(Icons.euro_outlined),
        //     errorText: errorText,
        //   ),
        title: const Text('Quanto è costata l\'attività?'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Importo Effettivo (€)',
              prefixIcon: Icon(Icons.euro_outlined),
              errorMaxLines: 2,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Inserisci un importo';
              }

              if (v.contains('-')) {
                return 'Inserisci un importo maggiore o uguale a 0';
              }

              final sanitized = v.replaceAll(',', '.').replaceAll('-', '');
              final parsed = double.tryParse(sanitized);

              if (parsed == null) {
                return 'Inserisci un numero valido';
              }

              if (parsed < 0) {
                return 'Inserisci un importo maggiore o uguale a 0';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              final text = controller.text.trim();
              final sanitized = text.replaceAll(',', '.').replaceAll('-', '');
              final parsed = double.tryParse(sanitized);

              if (text.isEmpty) {}
              if (parsed == null || parsed < 0) {
                return;
              }

              Navigator.of(ctx).pop(parsed);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (amount == null) return;
    await activityProvider.updateActivity(
      activity.copyWith(status: ActivityStatus.done),
    );

    await expenseProvider.addExpense(
      tripId: activity.tripId,
      stageId: activity.stageId,
      activityId: activity.id,
      title: activity.title,
      amount: amount,
      category: ExpenseCategory.activity,
      date: activity.dateTime ?? DateTime.now(),
      paymentMethod: PaymentMethod.cash,
      status: ExpenseStatus.actual,
      notes: null,
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Elimina attività',
      message:
          'Vuoi eliminare "${activity.title}"? Verranno eliminate anche eventuali spese previste ed effettive eventualmente collegate',
    );
    if (!confirmed && !context.mounted) {
      return;
    }

    final activityProvider = context.read<ActivityProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    final expense = expenseProvider.getByTrip(tripId);
    final relatedExpenses = expense
        .where((e) => e.activityId == activity.id)
        .toList();

    for (final e in relatedExpenses) {
      await expenseProvider.deleteExpense(tripId, e.id);
    }

    await activityProvider.deleteActivity(tripId, activity.id);
  }
}
