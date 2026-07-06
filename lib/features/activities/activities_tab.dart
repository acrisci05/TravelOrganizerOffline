import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/activity.dart';
import '../../providers/activity_provider.dart';
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
          activities =
              activities.where((a) => a.status == _filterStatus).toList();
        }
        if (_filterDate != null) {
          activities = activities
              .where((a) =>
                  a.dateTime != null &&
                  a.dateTime!.year == _filterDate!.year &&
                  a.dateTime!.month == _filterDate!.month &&
                  a.dateTime!.day == _filterDate!.day)
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
                onCategoryChanged: (c) =>
                    setState(() => _filterCategory = c),
                onStatusChanged: (s) => setState(() => _filterStatus = s),
                onDatePicker: () => _pickDate(context),
                onDateClear: () => setState(() => _filterDate = null),
              ),
              Expanded(
                child: activities.isEmpty
                    ? EmptyState(
                        icon: Icons.event_note_outlined,
                        title: _filterCategory != null ||
                                _filterStatus != null ||
                                _filterDate != null
                            ? 'Nessun risultato'
                            : 'Nessuna attività',
                        subtitle: _filterCategory != null ||
                                _filterStatus != null ||
                                _filterDate != null
                            ? 'Prova a cambiare i filtri'
                            : 'Aggiungi le attività del viaggio',
                        actionLabel: _filterCategory == null &&
                                _filterStatus == null &&
                                _filterDate == null
                            ? 'Aggiungi'
                            : null,
                        onAction: _filterCategory == null &&
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
          builder: (_) => ActivityFormScreen(tripId: widget.tripId)),
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
              selected: selectedCategory == null &&
                  selectedStatus == null &&
                  selectedDate == null,
              onSelected: (_) {
                onCategoryChanged(null);
                onStatusChanged(null);
                onDateClear();
              },
            ),
            const SizedBox(width: 6),
            ...ActivityCategory.values.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text('${c.icon} ${c.label}'),
                    selected: selectedCategory == c,
                    onSelected: (_) => onCategoryChanged(
                        selectedCategory == c ? null : c),
                  ),
                )),
            const VerticalDivider(width: 16),
            ...ActivityStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(s.label),
                    selected: selectedStatus == s,
                    onSelected: (_) => onStatusChanged(
                        selectedStatus == s ? null : s),
                  ),
                )),
            const VerticalDivider(width: 16),
            FilterChip(
              avatar: selectedDate == null
                  ? const Icon(Icons.calendar_today_outlined, size: 14)
                  : null,
              label: Text(selectedDate != null
                  ? DateFormatter.date(selectedDate!)
                  : 'Per giorno'),
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
  const _ActivityCard(
      {required this.activity, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ActivityFormScreen(
              tripId: tripId, existingActivity: activity),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    context.read<ActivityProvider>().toggleStatus(activity),
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
              Text(activity.category.icon,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration:
                            activity.status == ActivityStatus.done
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
                            color: AppColors.textSecondary),
                      ),
                    if (activity.location != null)
                      Text(
                        activity.location!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (activity.estimatedCost != null)
                      Text(
                        DateFormatter.currency(activity.estimatedCost!),
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500),
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
      title: 'Elimina attività',
      message: 'Vuoi eliminare "${activity.title}"?',
    );
    if (confirmed && context.mounted) {
      await context
          .read<ActivityProvider>()
          .deleteActivity(tripId, activity.id);
    }
  }
}
