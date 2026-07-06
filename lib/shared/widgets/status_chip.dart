import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/trip.dart';
import '../../data/models/activity.dart';
import '../../data/models/expense.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.trip(TripStatus status) {
    final colors = {
      TripStatus.future: AppColors.statusFuture,
      TripStatus.ongoing: AppColors.statusOngoing,
      TripStatus.completed: AppColors.statusCompleted,
      TripStatus.archived: AppColors.statusArchived,
    };
    return StatusChip(
      label: status.label,
      color: colors[status] ?? AppColors.textSecondary,
    );
  }

  factory StatusChip.activity(ActivityStatus status) {
    final colors = {
      ActivityStatus.todo: AppColors.warning,
      ActivityStatus.done: AppColors.success,
      ActivityStatus.cancelled: AppColors.error,
    };
    return StatusChip(
      label: status.label,
      color: colors[status] ?? AppColors.textSecondary,
    );
  }

  factory StatusChip.expense(ExpenseStatus status) {
    return StatusChip(
      label: status.label,
      color: status == ExpenseStatus.planned
          ? AppColors.info
          : AppColors.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
