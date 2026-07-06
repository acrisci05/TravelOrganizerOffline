import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/checklist.dart';
import '../../providers/checklist_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/confirm_dialog.dart';
enum _ChecklistFilter { all, incomplete, complete }

class ChecklistsScreen extends StatefulWidget {
  final String tripId;
  const ChecklistsScreen({super.key, required this.tripId});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  _ChecklistFilter _filter = _ChecklistFilter.all;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, _) {
        var checklists = provider.getByTrip(widget.tripId);

        if (_filter == _ChecklistFilter.incomplete) {
          checklists = checklists.where((c) => !c.isCompleted).toList();
        } else if (_filter == _ChecklistFilter.complete) {
          checklists = checklists.where((c) => c.isCompleted).toList();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _FilterBar(
                selected: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
              Expanded(
                child: checklists.isEmpty
                    ? EmptyState(
                        icon: Icons.checklist_outlined,
                        title: _filter != _ChecklistFilter.all
                            ? 'Nessun risultato'
                            : 'Nessuna checklist',
                        subtitle: _filter != _ChecklistFilter.all
                            ? 'Nessuna checklist corrisponde al filtro'
                            : 'Crea una checklist per organizzarti',
                        actionLabel: _filter == _ChecklistFilter.all
                            ? 'Nuova checklist'
                            : null,
                        onAction: _filter == _ChecklistFilter.all
                            ? () => _addChecklist(context)
                            : null,
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.only(bottom: 80, top: 8),
                        itemCount: checklists.length,
                        itemBuilder: (ctx, i) => _ChecklistCard(
                          checklist: checklists[i],
                          tripId: widget.tripId,
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addChecklist(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuova checklist'),
          ),
        );
      },
    );
  }

  Future<void> _addChecklist(BuildContext context) async {
    final ctrl = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuova checklist'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(labelText: 'Titolo checklist'),
          autofocus: true,
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Crea'),
          ),
        ],
      ),
    );
    if (title != null && title.isNotEmpty && context.mounted) {
      await context
          .read<ChecklistProvider>()
          .addChecklist(tripId: widget.tripId, title: title);
    }
  }
}

class _FilterBar extends StatelessWidget {
  final _ChecklistFilter selected;
  final ValueChanged<_ChecklistFilter> onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(_ChecklistFilter.all, 'Tutte', Icons.list),
            const SizedBox(width: 8),
            _chip(_ChecklistFilter.incomplete, 'Da completare',
                Icons.radio_button_unchecked),
            const SizedBox(width: 8),
            _chip(_ChecklistFilter.complete, 'Completate',
                Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }

  Widget _chip(_ChecklistFilter value, String label, IconData icon) {
    final isSelected = selected == value;
    return FilterChip(
      avatar: Icon(icon,
          size: 14,
          color: isSelected ? Color.fromARGB(0, 0, 0, 0) : AppColors.textSecondary),
          // AppColors.textSecondary
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(value),
    );
  }
}

class _ChecklistCard extends StatefulWidget {
  final Checklist checklist;
  final String tripId;
  const _ChecklistCard(
      {required this.checklist, required this.tripId});

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  bool _expanded = false;
  final _addCtrl = TextEditingController();

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cl = widget.checklist;
    return Card(
      child: Column(
        children: [
          InkWell(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cl.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: cl.progress,
                          backgroundColor:
                              AppColors.textHint.withAlpha(50),
                          color: cl.isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cl.completedItems}/${cl.totalItems} completati',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined,
                        size: 20, color: AppColors.textSecondary),
                    onPressed: () => _duplicate(context),
                    tooltip: 'Duplica',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.error),
                    onPressed: () => _delete(context),
                    tooltip: 'Elimina',
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            ...cl.items.map((item) => CheckboxListTile(
                  value: item.isCompleted,
                  onChanged: (_) => context
                      .read<ChecklistProvider>()
                      .toggleItem(widget.tripId, cl.id, item.id),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.isCompleted
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                    onPressed: () => context
                        .read<ChecklistProvider>()
                        .deleteItem(widget.tripId, cl.id, item.id),
                  ),
                  activeColor: AppColors.success,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Aggiungi elemento…',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (v) => _addItem(context, v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.primary),
                    onPressed: () => _addItem(context, _addCtrl.text),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addItem(BuildContext context, String text) async {
    if (text.trim().isEmpty) return;
    await context.read<ChecklistProvider>().addItem(
          widget.tripId,
          widget.checklist.id,
          text.trim(),
        );
    _addCtrl.clear();
  }

  Future<void> _duplicate(BuildContext context) async {
    await context.read<ChecklistProvider>().duplicateChecklist(
        widget.tripId, widget.checklist.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist duplicata')),
      );
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Elimina checklist',
      message:
          'Vuoi eliminare la checklist "${widget.checklist.title}"?',
    );
    if (confirmed && context.mounted) {
      await context
          .read<ChecklistProvider>()
          .deleteChecklist(widget.tripId, widget.checklist.id);
    }
  }
}
