import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/trip.dart';
import '../../data/models/activity.dart';
import '../../data/models/expense.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool whiteStyle;

  const StatusChip({super.key, required this.label, required this.color, this.whiteStyle=false});

  factory StatusChip.trip(TripStatus status, {bool whiteStyle=false}) {
    final colors = {
      TripStatus.future: AppColors.statusFuture,
      TripStatus.ongoing: AppColors.statusOngoing,
      TripStatus.completed: AppColors.statusCompleted,
      TripStatus.archived: AppColors.statusArchived,
    };
    return StatusChip(
      label: status.label,
      color: colors[status] ?? AppColors.textSecondary,
      whiteStyle: whiteStyle,
    );
  }

  factory StatusChip.activity(ActivityStatus status, {bool whiteStyle=false}){
    final colors = {
      ActivityStatus.todo: AppColors.warning,
      ActivityStatus.done: AppColors.success,
      ActivityStatus.cancelled: AppColors.error,
    };
    return StatusChip(
      label: status.label,
      color: colors[status] ?? AppColors.textSecondary,
      whiteStyle: whiteStyle,
    );
  }

  factory StatusChip.expense(ExpenseStatus status, {bool whiteStyle=false }){
    return StatusChip(
      label: status.label,
      color: status == ExpenseStatus.planned
          ? AppColors.info
          : AppColors.success,
          whiteStyle: whiteStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = whiteStyle ? color.withAlpha(100) : color.withAlpha(30);
    final borderColor = whiteStyle ? Colors.white : color.withAlpha(80);
    final textColor = whiteStyle ? Colors.white : color.withAlpha(100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
