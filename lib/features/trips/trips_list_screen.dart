import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'trip_form_screen.dart';
import '../../providers/stage_provider.dart';
import 'trip_detail_screen.dart';

class TripsListScreen extends StatefulWidget {
  const TripsListScreen({super.key});

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  final _searchController = TextEditingController();
  bool _showArchivedOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTrips();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Barra che contiene "I miei viaggi"+ Il tasto per filtrare + barra di ricerca
      appBar: AppBar(
        title: const Text('I Miei Viaggi'),
        actions: [
          // Tasto filtri
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () => setState(() => _showArchivedOnly = !_showArchivedOnly),
            tooltip: _showArchivedOnly ? 'Mostra i viaggi non archiviati' : 'Mostra i viaggi archiviati',
            style: IconButton.styleFrom(
              backgroundColor: _showArchivedOnly ? AppColors.primaryLight : Colors.transparent,
            )
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet, // Azione del tasto filtro
            tooltip: 'Filtra',
          ),
        ],
        // Tutto ciò che è sotto I miei viaggi + tasto per filtrare
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Barra di ricerca con controller
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {});
                context.read<TripProvider>().setSearch(query);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cerca per titolo o destinazione…',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TripProvider>().setSearch('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var trips = provider.tripsSortedByStatus;

          if(_showArchivedOnly){
            trips = trips.where((t)=> t.status == TripStatus.archived).toList();
          }
          if (trips.isEmpty) {
            return EmptyState(
              icon: Icons.luggage_outlined,
              title: 'Nessun viaggio trovato',
              subtitle:
                  provider.searchQuery.isNotEmpty ||
                      provider.filterStatus != null
                  ? 'Prova a modificare i filtri di ricerca'
                  : 'Aggiungi il tuo primo viaggio!',
              actionLabel:
                  provider.searchQuery.isEmpty && provider.filterStatus == null
                  ? 'Nuovo viaggio'
                  : null,
              onAction: () => _openForm(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTrips(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: trips.length,
              itemBuilder: (context, i) => _TripCard(trip: trips[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuovo viaggio'),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TripFormScreen()));
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<TripProvider>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtra per stato',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Tutti'),
                selected: provider.filterStatus == null,
                onSelected: (_) {
                  provider.setFilter(null);
                  Navigator.pop(context);
                },
              ),
              ...TripStatus.values.map(
                (s) => FilterChip(
                  label: Text(s.label),
                  selected: provider.filterStatus == s,
                  onSelected: (_) {
                    provider.setFilter(s);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Rimuovi filtri'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
  final status = trip.computedStatus;
  final bg = _backgroundForStatus(status);
    return Card(
      color: bg,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusChip.trip(trip.status),
                  // StatusChip.trip(status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trip.destination,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.dateRange(trip.startDate, trip.endDate),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${trip.durationDays} giorni)',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (trip.budget != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Budget: ${DateFormatter.currency(trip.budget!)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionBtn(
                    context,
                    Icons.copy_outlined,
                    'Duplica',
                    () => _duplicate(context),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    context,
                    Icons.edit_outlined,
                    'Modifica',
                    () => _edit(context),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    context,
                    Icons.delete_outline,
                    'Elimina',
                    () => _delete(context),
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
      ),
    );
  }

  Color _backgroundForStatus(TripStatus status) {
    switch (status) {
      case TripStatus.future:
        return const Color.fromARGB(255, 0, 0, 255).withOpacity(0.2);
      case TripStatus.ongoing:
        return const Color.fromARGB(255, 255, 255, 0).withOpacity(0.2);
      case TripStatus.completed:
        return const Color.fromARGB(255, 0, 255, 0).withOpacity(0.2);
      case TripStatus.archived:
        return AppColors.statusArchived.withOpacity(0.1);
    }
  }

  Future<void> _duplicate(BuildContext context) async {
    final tripProvider = context.read<TripProvider>();
    final stageProvider = context.read<StageProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final newTrip = await tripProvider.duplicateTrip(trip);
    await stageProvider.duplicateStagesForTrip(trip.id, newTrip.id);
    messenger.showSnackBar(const SnackBar(content: Text('Viaggio duplicato')));
  }

  void _edit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TripFormScreen(existingTrip: trip)),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Elimina viaggio',
      message:
          'Vuoi eliminare "${trip.title}"? Verranno eliminati anche tutte le tappe, attività e spese associate.',
    );
    if (confirmed && context.mounted) {
      await context.read<TripProvider>().deleteTrip(trip.id);
    }
  }
}
