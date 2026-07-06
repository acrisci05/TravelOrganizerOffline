import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/trip.dart';
import '../../data/models/expense.dart';
import '../../providers/trip_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/checklist_provider.dart';
import '../../providers/stage_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      backgroundColor: AppColors.background,
      body: const _StatsBody(),
    );
  }
}

class _StatsBody extends StatefulWidget {
  const _StatsBody();

  @override
  State<_StatsBody> createState() => _StatsBodyState();
}

class _StatsBodyState extends State<_StatsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  void _loadAll() {
    if (!mounted) return;
    final trips = context.read<TripProvider>().trips;
    final stageProvider = context.read<StageProvider>();
    final actProvider = context.read<ActivityProvider>();
    final clProvider = context.read<ChecklistProvider>();
    final expProvider = context.read<ExpenseProvider>();
    for (final trip in trips) {
      stageProvider.loadForTrip(trip.id);
      actProvider.loadForTrip(trip.id);
      clProvider.loadForTrip(trip.id);
      expProvider.loadForTrip(trip.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trips = tripProvider.trips;

    if (trips.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 72, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Nessun dato disponibile',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final statusCounts = tripProvider.statusCounts;
    final actProvider = context.watch<ActivityProvider>();
    final expProvider = context.watch<ExpenseProvider>();
    final clProvider = context.watch<ChecklistProvider>();
    final stageProvider = context.watch<StageProvider>();

    // Global totals
    final totalActivities =
        trips.fold(0, (sum, t) => sum + actProvider.totalCount(t.id));
    final completedActivities =
        trips.fold(0, (sum, t) => sum + actProvider.completedCount(t.id));
    final totalActualExp = trips.fold(
        0.0, (sum, t) => sum + expProvider.totalActual(t.id));
    final totalPlannedExp = trips.fold(
        0.0, (sum, t) => sum + expProvider.totalPlanned(t.id));

    final allChecklists =
        trips.expand((t) => clProvider.getByTrip(t.id)).toList();
    final totalCheckItems =
        allChecklists.fold(0, (sum, c) => sum + c.totalItems);
    final completedCheckItems =
        allChecklists.fold(0, (sum, c) => sum + c.completedItems);

    // Stages with most activities (top 5)
    final allStages =
        trips.expand((t) => stageProvider.getByTrip(t.id)).toList();
    final stagesRanked = allStages
        .map((s) {
          final count = actProvider.getByStage(s.tripId, s.id).length;
          final tripTitle = trips
                  .where((t) => t.id == s.tripId)
                  .firstOrNull
                  ?.title ??
              '';
          return (stage: s, count: count, tripTitle: tripTitle);
        })
        .where((r) => r.count > 0)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final top5 = stagesRanked.take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitle('Riepilogo viaggi'),
        _StatsGrid(children: [
          _StatCard(
              label: 'Totale',
              value: '${trips.length}',
              icon: Icons.luggage,
              color: AppColors.primary),
          _StatCard(
              label: 'Futuri',
              value: '${statusCounts[TripStatus.future] ?? 0}',
              icon: Icons.upcoming,
              color: AppColors.statusFuture),
          _StatCard(
              label: 'In corso',
              value: '${statusCounts[TripStatus.ongoing] ?? 0}',
              icon: Icons.flight_takeoff,
              color: AppColors.statusOngoing),
          _StatCard(
              label: 'Completati',
              value: '${statusCounts[TripStatus.completed] ?? 0}',
              icon: Icons.check_circle_outline,
              color: AppColors.statusCompleted),
        ]),
        const SizedBox(height: 20),
        _SectionTitle('Totali globali'),
        _StatsGrid(children: [
          _StatCard(
              label: 'Attività',
              value: '$totalActivities',
              icon: Icons.event_note,
              color: AppColors.accent),
          _StatCard(
              label: 'Completate',
              value: '$completedActivities',
              icon: Icons.task_alt,
              color: AppColors.success),
          _StatCard(
              label: 'Spese totali',
              value: DateFormatter.currency(totalActualExp),
              icon: Icons.euro,
              color: AppColors.statusOngoing),
          _StatCard(
              label: 'Checklist',
              value: '$completedCheckItems/$totalCheckItems',
              icon: Icons.checklist,
              color: AppColors.info),
        ]),
        if (totalPlannedExp > 0) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spese previste totali',
                      style:
                          TextStyle(color: AppColors.textSecondary)),
                  Text(DateFormatter.currency(totalPlannedExp),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
        if (top5.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle('Tappe con più attività'),
          ...top5.asMap().entries.map((e) => _StageLeaderboardTile(
                rank: e.key + 1,
                stageName: e.value.stage.title,
                tripName: e.value.tripTitle,
                count: e.value.count,
              )),
        ],
        const SizedBox(height: 20),
        _SectionTitle('Statistiche per viaggio'),
        ...trips.map((t) => _TripStatCard(trip: t)),
      ],
    );
  }
}

class _StageLeaderboardTile extends StatelessWidget {
  final int rank;
  final String stageName;
  final String tripName;
  final int count;

  const _StageLeaderboardTile({
    required this.rank,
    required this.stageName,
    required this.tripName,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stageName,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  Text(tripName,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                const Text('attività',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStatCard extends StatelessWidget {
  final Trip trip;
  const _TripStatCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final actProvider = context.watch<ActivityProvider>();
    final expProvider = context.watch<ExpenseProvider>();
    final clProvider = context.watch<ChecklistProvider>();

    final totalAct = actProvider.totalCount(trip.id);
    final completedAct = actProvider.completedCount(trip.id);
    final totalActual = expProvider.totalActual(trip.id);
    final totalPlanned = expProvider.totalPlanned(trip.id);
    final checklists = clProvider.getByTrip(trip.id);
    final totalItems =
        checklists.fold(0, (sum, c) => sum + c.totalItems);
    final completedItems =
        checklists.fold(0, (sum, c) => sum + c.completedItems);
    final categoryTotals = expProvider.categoryTotals(trip.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(trip.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(trip.destination,
            style: const TextStyle(
                color: AppColors.textSecondary)),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row('Durata', '${trip.durationDays} giorni'),
                _Row('Attività totali', '$totalAct'),
                _Row('Attività completate',
                    '$completedAct / $totalAct'),
                if (totalAct > 0)
                  LinearProgressIndicator(
                    value: totalAct == 0
                        ? 0
                        : completedAct / totalAct,
                    color: AppColors.success,
                    backgroundColor:
                        AppColors.textHint.withAlpha(50),
                  ),
                const SizedBox(height: 8),
                _Row('Spese effettive',
                    DateFormatter.currency(totalActual)),
                _Row('Spese previste',
                    DateFormatter.currency(totalPlanned)),
                if (trip.budget != null) ...[
                  _Row('Budget',
                      DateFormatter.currency(trip.budget!)),
                  _BudgetBar(
                      spent: totalActual, budget: trip.budget!),
                ],
                if (totalItems > 0) ...[
                  const SizedBox(height: 8),
                  _Row('Checklist',
                      '$completedItems / $totalItems elementi completati'),
                  LinearProgressIndicator(
                    value: totalItems == 0
                        ? 0
                        : completedItems / totalItems,
                    color: AppColors.info,
                    backgroundColor:
                        AppColors.textHint.withAlpha(50),
                  ),
                ],
                if (categoryTotals.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Spese per categoria',
                      style:
                          TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _CategoryPieChart(totals: categoryTotals),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  final double spent;
  final double budget;
  const _BudgetBar({required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final ratio =
        budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final overBudget = spent > budget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            color: overBudget ? AppColors.error : AppColors.success,
            backgroundColor: AppColors.textHint.withAlpha(50),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          overBudget
              ? 'Sforamento: ${DateFormatter.currency(spent - budget)}'
              : 'Disponibile: ${DateFormatter.currency(budget - spent)}',
          style: TextStyle(
              fontSize: 11,
              color:
                  overBudget ? AppColors.error : AppColors.success),
        ),
      ],
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<ExpenseCategory, double> totals;
  const _CategoryPieChart({required this.totals});

  static const _colors = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFFE53935),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFF6D4C41),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);
    if (total == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final pct = (e.value.value / total * 100);
                  return PieChartSectionData(
                    value: e.value.value,
                    color: _colors[e.key % _colors.length],
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 55,
                    titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colors[e.key % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${e.value.key.label}: ${DateFormatter.currency(e.value.value)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<Widget> children;
  const _StatsGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: children,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
