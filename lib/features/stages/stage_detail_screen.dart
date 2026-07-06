import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/stage_provider.dart';
import '../../providers/activity_provider.dart';
import '../../data/models/activity.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/status_chip.dart';
import '../activities/activity_form_screen.dart';
import 'stage_form_screen.dart';

class StageDetailScreen extends StatelessWidget {
  final String tripId;
  final String stageId;
  const StageDetailScreen(
      {super.key, required this.tripId, required this.stageId});

  @override
  Widget build(BuildContext context) {
    final stage = context
        .watch<StageProvider>()
        .getByTrip(tripId)
        .where((s) => s.id == stageId)
        .firstOrNull;
    if (stage == null) {
      return const Scaffold(
        body: Center(child: Text('Tappa non trovata')),
      );
    }
    final activities =
        context.watch<ActivityProvider>().getByStage(tripId, stageId);

    return Scaffold(
      appBar: AppBar(
        title: Text(stage.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StageFormScreen(
                  tripId: tripId, existingStage: stage),
            )),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _InfoCard(
              date: stage.date,
              location: stage.location,
              description: stage.description,
              notes: stage.notes,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text('Attività (${activities.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi'),
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ActivityFormScreen(
                          tripId: tripId, stageId: stageId),
                    )),
                  ),
                ],
              ),
            ),
          ),
          activities.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'Nessuna attività',
                    subtitle: 'Aggiungi attività a questa tappa',
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ActivityTile(
                      activity: activities[i],
                      tripId: tripId,
                      stageId: stageId,
                    ),
                    childCount: activities.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              ActivityFormScreen(tripId: tripId, stageId: stageId),
        )),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final DateTime date;
  final String? location;
  final String? description;
  final String? notes;

  const _InfoCard({
    required this.date,
    this.location,
    this.description,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(Icons.calendar_today_outlined,
                DateFormatter.date(date)),
            if (location != null) ...[
              const SizedBox(height: 8),
              _row(Icons.place_outlined, location!),
            ],
            if (description != null) ...[
              const Divider(height: 20),
              Text(description!,
                  style: const TextStyle(
                      color: AppColors.textSecondary)),
            ],
            if (notes != null) ...[
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(notes!,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final String tripId;
  final String stageId;

  const _ActivityTile({
    required this.activity,
    required this.tripId,
    required this.stageId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(activity.category.icon,
            style: const TextStyle(fontSize: 22)),
        title: Text(
          activity.title,
          style: TextStyle(
            decoration: activity.status == ActivityStatus.done
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: activity.dateTime != null
            ? Text(DateFormatter.time(activity.dateTime!))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusChip.activity(activity.status),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                activity.status == ActivityStatus.done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: activity.status == ActivityStatus.done
                    ? AppColors.success
                    : AppColors.textHint,
              ),
              onPressed: () => context
                  .read<ActivityProvider>()
                  .toggleStatus(activity),
            ),
          ],
        ),
        onLongPress: () => _delete(context),
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
