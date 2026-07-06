import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../providers/stage_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/checklist_provider.dart';
import '../../providers/expense_provider.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../stages/stages_tab.dart';
import '../activities/activities_tab.dart';
import '../checklists/checklists_screen.dart';
import '../expenses/expenses_screen.dart';
import '../timeline/timeline_screen.dart';
import '../packing/packing_list_screen.dart';
import 'trip_form_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final tripId = widget.tripId;
    context.read<StageProvider>().loadForTrip(tripId);
    context.read<ActivityProvider>().loadForTrip(tripId);
    context.read<ChecklistProvider>().loadForTrip(tripId);
    context.read<ExpenseProvider>().loadForTrip(tripId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        final trip = provider.getById(widget.tripId);
        if (trip == null) {
          return const Scaffold(
            body: Center(child: Text('Viaggio non trovato')),
          );
        }
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              _TripSliverAppBar(
                trip: trip,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          TripFormScreen(existingTrip: trip)),
                ),
                onDelete: () => _delete(context, trip),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Tappe'),
                      Tab(text: 'Attività'),
                      Tab(text: 'Checklist'),
                      Tab(text: 'Spese'),
                      Tab(text: 'Timeline'),
                      Tab(text: 'Valigia'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                StagesTab(tripId: widget.tripId),
                ActivitiesTab(tripId: widget.tripId),
                ChecklistsScreen(tripId: widget.tripId),
                ExpensesScreen(tripId: widget.tripId),
                TimelineScreen(tripId: widget.tripId),
                PackingListScreen(tripId: widget.tripId),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, Trip trip) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Elimina viaggio',
      message:
          'Vuoi eliminare "${trip.title}"? Tutti i dati associati verranno eliminati.',
    );
    if (confirmed && context.mounted) {
      await context.read<TripProvider>().deleteTrip(trip.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _TripSliverAppBar extends StatelessWidget {
  final Trip trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TripSliverAppBar({
    required this.trip,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 210,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        IconButton(
            icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusChip.trip(trip.computedStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(trip.destination,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.dateRange(
                            trip.startDate, trip.endDate),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  if (trip.budget != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Budget: ${DateFormatter.currency(trip.budget!)}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
