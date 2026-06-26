import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/activity.dart';
import '../../providers/stage_provider.dart';
import '../../providers/activity_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/status_chip.dart';

// Scheda "Timeline": linea del tempo dell'itinerario. Raggruppa le attività per
// tappa, le ordina per orario e segnala i tempi liberi tra un'attività e l'altra.
class TimelineScreen extends StatefulWidget {
  final String tripId;
  const TimelineScreen({super.key, required this.tripId});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    final stages =
        context.watch<StageProvider>().getByTrip(widget.tripId);
    final allActivities =
        context.watch<ActivityProvider>().getByTrip(widget.tripId);

    if (stages.isEmpty && allActivities.isEmpty) {
      return const EmptyState(
        icon: Icons.timeline,
        title: 'Nessuna tappa o attività',
        subtitle: 'Aggiungi tappe e attività per visualizzare la timeline',
      );
    }

    final entries = <_TimelineEntry>[];

    for (final stage in stages) {
      final stageActivities =
          allActivities.where((a) => a.stageId == stage.id).toList()
            ..sort((a, b) {
              if (a.dateTime == null) return 1;
              if (b.dateTime == null) return -1;
              return a.dateTime!.compareTo(b.dateTime!);
            });
      entries.add(_TimelineEntry.stage(stage.title, stage.date,
          stage.location, stageActivities));
    }

    final unassigned =
        allActivities.where((a) => a.stageId == null).toList()
          ..sort((a, b) {
            if (a.dateTime == null) return 1;
            if (b.dateTime == null) return -1;
            return a.dateTime!.compareTo(b.dateTime!);
          });
    if (unassigned.isNotEmpty) {
      entries.add(
          _TimelineEntry.unassigned(unassigned));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: entries.length,
      itemBuilder: (ctx, i) => _TimelineEntryWidget(
        entry: entries[i],
        isLast: i == entries.length - 1,
      ),
    );
  }
}

class _TimelineEntry {
  final String title;
  final DateTime? date;
  final String? location;
  final List<Activity> activities;
  final bool isUnassigned;

  _TimelineEntry.stage(
      this.title, this.date, this.location, this.activities)
      : isUnassigned = false;

  _TimelineEntry.unassigned(this.activities)
      : title = 'Attività senza tappa',
        date = null,
        location = null,
        isUnassigned = true;
}

class _TimelineEntryWidget extends StatefulWidget {
  final _TimelineEntry entry;
  final bool isLast;
  const _TimelineEntryWidget(
      {required this.entry, required this.isLast});

  @override
  State<_TimelineEntryWidget> createState() =>
      _TimelineEntryWidgetState();
}

class _TimelineEntryWidgetState
    extends State<_TimelineEntryWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: e.isUnassigned
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color:
                              AppColors.primary.withAlpha(60),
                          blurRadius: 4)
                    ],
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.primaryLight
                          .withAlpha(80),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(
                        () => _expanded = !_expanded),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: e.isUnassigned
                            ? AppColors.background
                            : AppColors.primary
                                .withAlpha(15),
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                            color: e.isUnassigned
                                ? AppColors.textHint
                                    .withAlpha(80)
                                : AppColors.primary
                                    .withAlpha(60)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                    color: e.isUnassigned
                                        ? AppColors
                                            .textSecondary
                                        : AppColors.primary,
                                  ),
                                ),
                                if (e.date != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormatter.date(e.date!),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors
                                            .textSecondary),
                                  ),
                                ],
                                if (e.location != null)
                                  Text(
                                    e.location!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors
                                            .textSecondary),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${e.activities.length} attività',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_expanded && e.activities.isNotEmpty)
                    ..._buildActivityList(e.activities),
                  if (_expanded && e.activities.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 8, left: 8),
                      child: Text(
                        'Nessuna attività in questa tappa',
                        style: TextStyle(
                            color: AppColors.textHint,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Costruisce l'elenco delle attività inserendo, tra una e l'altra, un badge
  // che evidenzia i periodi di tempo libero.
  List<Widget> _buildActivityList(List<Activity> activities) {
    final widgets = <Widget>[];
    for (int i = 0; i < activities.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 6, left: 8),
        child: _ActivityTimeline(activity: activities[i]),
      ));
      if (i < activities.length - 1) {
        final gap = _freeGap(
            activities[i].dateTime, activities[i + 1].dateTime);
        if (gap != null) widgets.add(_FreeTimeBadge(label: gap));
      }
    }
    return widgets;
  }

  // Restituisce la durata del tempo libero tra due attività dello stesso giorno
  // formattata (es. "2h 30min"), oppure null se inferiore a 2 ore o su giorni diversi.
  String? _freeGap(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (start.year != end.year ||
        start.month != end.month ||
        start.day != end.day) {
      return null;
    }
    final diff = end.difference(start);
    if (diff.inMinutes < 120) return null;
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }
}

// Badge discreto che segnala il tempo libero disponibile nell'itinerario.
class _FreeTimeBadge extends StatelessWidget {
  final String label;
  const _FreeTimeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 16),
      child: Row(
        children: [
          const Icon(Icons.free_breakfast_outlined,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'Hai $label di tempo libero',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  final Activity activity;
  const _ActivityTimeline({required this.activity});

  @override
  Widget build(BuildContext context) {
    // Ogni attività è un "blocco" con una banda colorata in base alla categoria.
    final catColor = activity.category.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: catColor, width: 4),
          top: BorderSide(color: AppColors.textHint.withAlpha(60)),
          right: BorderSide(color: AppColors.textHint.withAlpha(60)),
          bottom: BorderSide(color: AppColors.textHint.withAlpha(60)),
        ),
      ),
      child: Row(
        children: [
          Icon(activity.category.icon, size: 20, color: catColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration:
                        activity.status == ActivityStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                    color:
                        activity.status == ActivityStatus.done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                  ),
                ),
                if (activity.dateTime != null)
                  Text(
                    DateFormatter.time(activity.dateTime!),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
                if (activity.estimatedCost != null)
                  Text(
                    DateFormatter.currency(
                        activity.estimatedCost!),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary),
                  ),
              ],
            ),
          ),
          StatusChip.activity(activity.status),
        ],
      ),
    );
  }
}
