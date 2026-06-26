import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/trip.dart';
import '../../data/trip_transfer.dart';
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

// Dettaglio di un viaggio con sei schede: Tappe, Attività, Checklist, Spese,
// Timeline e Valigia. Riceve il [tripId] e carica i dati collegati.
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
                onExport: () => _export(context, trip),
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

  // Esporta il viaggio in JSON e apre il menu di condivisione nativo del sistema
  // (l'utente può inviarlo via messaggistica, email, ecc.).
  Future<void> _export(BuildContext context, Trip trip) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await TripTransferService().exportTrip(trip.id);
      await Share.share(json, subject: 'Viaggio: ${trip.title}');
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Errore durante l\'esportazione del viaggio')),
      );
    }
  }

  Future<void> _delete(BuildContext context, Trip trip) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Elimina viaggio',
      message:
          'Vuoi eliminare "${trip.title}"? Tutti i dati associati verranno eliminati.',
    );
    if (confirmed && context.mounted) {
      final tripId = trip.id;
      // Elimina il viaggio: il database rimuove a cascata tappe, attività,
      // checklist e spese collegate (ON DELETE CASCADE).
      await context.read<TripProvider>().deleteTrip(tripId);
      if (context.mounted) {
        // Allinea le cache in memoria così le statistiche restano coerenti.
        context.read<StageProvider>().clearForTrip(tripId);
        context.read<ActivityProvider>().clearForTrip(tripId);
        context.read<ChecklistProvider>().clearForTrip(tripId);
        context.read<ExpenseProvider>().clearForTrip(tripId);
        Navigator.of(context).pop();
      }
    }
  }
}

class _TripSliverAppBar extends StatelessWidget {
  final Trip trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _TripSliverAppBar({
    required this.trip,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
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
        IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: onExport,
            tooltip: 'Esporta / Condividi'),
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
