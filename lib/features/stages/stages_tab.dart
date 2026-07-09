import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/stage.dart';
import '../../providers/stage_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/trip_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'stage_form_screen.dart';
import 'stage_detail_screen.dart';
enum StageSortType {order, date, title}

class StagesTab extends StatefulWidget {
  final String tripId;
  const StagesTab({super.key, required this.tripId});

  @override
  State<StagesTab> createState() => _StagesTabState();
}

class _StagesTabState extends State<StagesTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  DateTime? _filterDate;
  StageSortType _sortType = StageSortType.order;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StageProvider>(
      builder: (context, provider, _) {
        // final allStages = provider.getByTrip(widget.tripId);
        // allStages.sort((a, b) => a.order.compareTo(b.order));
        // var stages = allStages;

        final allStages = provider.getByTrip(widget.tripId).toList();
        switch (_sortType){
          case StageSortType.order:
          allStages.sort((a,b) => a.order.compareTo(b.order));
          break;
          case StageSortType.date:
          allStages.sort((a,b) => a.date.compareTo(b.date));
          break;
          case StageSortType.title:
          allStages.sort((a,b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
        }

        var stages=allStages;

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          stages = stages
              .where(
                (s) =>
                    s.title.toLowerCase().contains(q) ||
                    (s.location?.toLowerCase().contains(q) ?? false),
              )
              .toList();
        }
        if (_filterDate != null) {
          stages = stages
              .where(
                (s) =>
                    s.date.year == _filterDate!.year &&
                    s.date.month == _filterDate!.month &&
                    s.date.day == _filterDate!.day,
              )
              .toList();
        }

        final isFiltered = _searchQuery.isNotEmpty || _filterDate != null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _SearchBar(
                controller: _searchCtrl,
                filterDate: _filterDate,
                onSearchChanged: (q) => setState(() => _searchQuery = q),
                onPickDate: () => _pickDate(context),
                onClearDate: () => setState(() => _filterDate = null),
                onSortChanged: (value) => setState(() => _sortType = value),
                sortType: _sortType,
              ),
              Expanded(
                child: stages.isEmpty
                    ? isFiltered
                          ? EmptyState(
                              icon: Icons.search_off_outlined,
                              title: 'Nessun risultato',
                              subtitle: 'Prova a cambiare i filtri di ricerca',
                            )
                          : EmptyState(
                              icon: Icons.map_outlined,
                              title: 'Nessuna tappa',
                              subtitle: 'Aggiungi le tappe del tuo viaggio',
                              actionLabel: 'Aggiungi tappa',
                              onAction: () => _openForm(context),
                            )
                    : isFiltered
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 8),
                        itemCount: stages.length,
                        itemBuilder: (ctx, i) => _StageCard(
                          key: ValueKey(stages[i].id),
                          stage: stages[i],
                          tripId: widget.tripId,
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 8),
                        itemCount: stages.length,
                        onReorder: (old, newIdx) =>
                            _reorder(context, allStages, old, newIdx),
                        itemBuilder: (ctx, i) => _StageCard(
                          key: ValueKey(stages[i].id),
                          stage: stages[i],
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
    final trip = context.read<TripProvider>().getById(widget.tripId);
    if(trip == null) return;

    final firstDate = DateUtils.dateOnly(trip.startDate);
    final lastDate = DateUtils.dateOnly(trip.endDate);

    final today = DateUtils.dateOnly(DateTime.now());

    final initialDate = _filterDate != null ?
    DateUtils.dateOnly(_filterDate!) : today.isBefore(firstDate) ? firstDate : today.isAfter(lastDate) ? lastDate : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _filterDate = picked);
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StageFormScreen(tripId: widget.tripId)),
    );
  }

  Future<void> _reorder(
    BuildContext context,
    List<Stage> stages,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final provider = context.read<StageProvider>();
    final moved = stages[oldIndex];
    final reordered = List<Stage>.from(stages)
      ..removeAt(oldIndex)
      ..insert(newIndex, moved);
    for (int i = 0; i < reordered.length; i++) {
      await provider.updateStage(reordered[i].copyWith(order: i));
    }
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final DateTime? filterDate;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;
  final StageSortType sortType;
  final ValueChanged<StageSortType> onSortChanged;

  const _SearchBar({
    required this.controller,
    required this.filterDate,
    required this.onSearchChanged,
    required this.onPickDate,
    required this.onClearDate,
    required this.sortType,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child:
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Cerca per nome o località…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              controller.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () =>_showFilterSheet(context), icon: const Icon(Icons.filter_list),),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  void _showFilterSheet (BuildContext context) async {
    final result = await showModalBottomSheet<StageSortType>(context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(selected: sortType, filterDate: filterDate, onPickDate: onPickDate, onClearDate: onClearDate,),);
      if(result!= null){
        onSortChanged(result);
      }
  }
}

class _FilterSheet extends StatelessWidget {
  final StageSortType selected;
  final DateTime? filterDate;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;

  const _FilterSheet({
    required this.selected,
    required this.filterDate,
    required this.onPickDate,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ordina tappe per',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          RadioListTile<StageSortType>(
            value: StageSortType.order,
            groupValue: selected,
            title: const Text('Priorità'),
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
          ),
          RadioListTile<StageSortType>(
            value: StageSortType.date,
            groupValue: selected,
            title: const Text('Data'),
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
          ),
          RadioListTile<StageSortType>(
            value: StageSortType.title,
            groupValue: selected,
            title: const Text('Nome'),
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Filtra per data', style:Theme.of(context).textTheme.titleMedium,),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(onPressed: (){
              Navigator.pop(context);
              onPickDate();
            },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(filterDate != null ? DateFormatter.date(filterDate!)
              : 'Scegli data',)
          ),
          ),
          if(filterDate!= null) ... [
            const SizedBox(height: 8),
            SizedBox(width: double.infinity,
            child: TextButton(onPressed: () {
              Navigator.pop(context);
              onClearDate();
            },
            child: const Text('Rimuovi filtro data'),),)
          ]
        ],
      ),
    );
  }
}


class _StageCard extends StatelessWidget {
  final Stage stage;
  final String tripId;
  const _StageCard({super.key, required this.stage, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final activityCount = context
        .watch<ActivityProvider>()
        .getByStage(tripId, stage.id)
        .length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                StageDetailScreen(tripId: tripId, stageId: stage.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${stage.order + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.date(stage.date),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (stage.location != null) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.place_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              stage.location!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (activityCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$activityCount attività',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StageFormScreen(
                          tripId: tripId,
                          existingStage: stage,
                        ),
                      ),
                    ),
                    tooltip: 'Modifica',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                    onPressed: () => _delete(context),
                    tooltip: 'Elimina',
                  ),
                ],
              ),
              const Icon(Icons.drag_handle, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Elimina tappa',
      message: 'Vuoi eliminare la tappa "${stage.title}"?',
    );
    if (confirmed && context.mounted) {
      await context.read<StageProvider>().deleteStage(tripId, stage.id);
    }
  }
}
