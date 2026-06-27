import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/packing_catalog.dart';
import '../../data/models/checklist.dart';
import '../../data/models/checklist_item.dart';
import '../../providers/checklist_provider.dart';
import '../../providers/trip_provider.dart';

// Scheda "Valigia": checklist speciale degli oggetti da portare. Permette di
// generare una lista di base più suggerimenti intelligenti basati sui tag del viaggio.
class PackingListScreen extends StatefulWidget {
  final String tripId;
  const PackingListScreen({super.key, required this.tripId});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  // Titolo della checklist usata come "lista valigia": serve anche come
  // identificatore per ritrovarla tra le checklist del viaggio.
  static const _packingTitle = 'Lista Valigia';

  // Etichetta usata per gli oggetti senza sacchetto assegnato.
  static const _altriBag = 'Altri';

  // Ordine di visualizzazione dei sacchetti nella lista.
  static const _bagOrder = [
    PackingCatalog.bagAbbigliamento,
    PackingCatalog.bagDocumenti,
    PackingCatalog.bagElettronica,
    PackingCatalog.bagIgiene,
    PackingCatalog.bagMedicinali,
    PackingCatalog.bagVarie,
    _altriBag,
  ];

  String? _checklistId;
  final _addCtrl = TextEditingController();
  // Sacchetto selezionato per l'aggiunta manuale di un oggetto.
  String _addBag = PackingCatalog.bagVarie;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureChecklist());
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureChecklist() async {
    if (!mounted) return;
    final provider = context.read<ChecklistProvider>();
    await provider.loadForTrip(widget.tripId);
    if (!mounted) return;
    final checklists = provider.getByTrip(widget.tripId);
    final existing =
        checklists.where((c) => c.title == _packingTitle).firstOrNull;
    if (existing != null) {
      setState(() => _checklistId = existing.id);
    } else {
      final cl = await provider.addChecklist(
        tripId: widget.tripId,
        title: _packingTitle,
        description: 'Lista oggetti da portare in viaggio',
      );
      if (mounted) setState(() => _checklistId = cl.id);
    }
  }

  Checklist? _getChecklist(ChecklistProvider provider) {
    if (_checklistId == null) return null;
    return provider
        .getByTrip(widget.tripId)
        .where((c) => c.id == _checklistId)
        .firstOrNull;
  }

  // Genera la lista valigia combinando gli oggetti di base con i suggerimenti
  // intelligenti ricavati dai tag del viaggio (es. Mare -> Costume, Crema solare).
  // Ogni oggetto viene inserito nel proprio "sacchetto" (categoria).
  Future<void> _generateDefault() async {
    if (!mounted) return;
    final provider = context.read<ChecklistProvider>();
    final cl = _getChecklist(provider);
    if (cl == null) return;

    // Recupera i tag del viaggio per i suggerimenti specifici.
    final trip = context.read<TripProvider>().getById(widget.tripId);
    final tagSuggestions = PackingCatalog.suggestionsFor(trip?.tags ?? const []);

    // Unisce oggetti di base e suggerimenti dai tag, evitando i duplicati di nome.
    final toAdd = <PackingItem>[
      ...PackingCatalog.baseItems,
      ...tagSuggestions.where(
          (s) => !PackingCatalog.baseItems.any((b) => b.name == s.name)),
    ];

    final existing = cl.items.map((i) => i.title).toSet();
    int added = 0;
    for (final item in toAdd) {
      if (!existing.contains(item.name)) {
        await provider.addItem(widget.tripId, cl.id, item.name,
            category: item.bag);
        added++;
      }
    }
    if (mounted) {
      final tagInfo = (trip != null && trip.tags.isNotEmpty)
          ? ' (inclusi suggerimenti per: ${trip.tags.join(', ')})'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added > 0
              ? '$added elementi aggiunti, organizzati in sacchetti$tagInfo'
              : 'Lista già completa'),
        ),
      );
    }
  }

  Future<void> _addItem(String text) async {
    if (text.trim().isEmpty) return;
    final provider = context.read<ChecklistProvider>();
    final cl = _getChecklist(provider);
    if (cl == null) return;
    await provider.addItem(widget.tripId, cl.id, text.trim(),
        category: _addBag);
    _addCtrl.clear();
  }

  // Raggruppa gli oggetti per sacchetto e costruisce una sezione per ciascuno,
  // con intestazione e barra di avanzamento dedicata.
  List<Widget> _buildBagSections(
      Checklist cl, ChecklistProvider provider) {
    // Raggruppa gli elementi per sacchetto (categoria), null -> "Altri".
    final groups = <String, List<ChecklistItem>>{};
    for (final item in cl.items) {
      final bag = (item.category == null || item.category!.isEmpty)
          ? _altriBag
          : item.category!;
      (groups[bag] ??= []).add(item);
    }

    // Ordina i sacchetti secondo _bagOrder; eventuali extra in coda.
    final bags = groups.keys.toList()
      ..sort((a, b) {
        final ia = _bagOrder.indexOf(a);
        final ib = _bagOrder.indexOf(b);
        return (ia == -1 ? 999 : ia).compareTo(ib == -1 ? 999 : ib);
      });

    final widgets = <Widget>[];
    for (final bag in bags) {
      final items = groups[bag]!;
      final done = items.where((i) => i.isCompleted).length;
      widgets.add(_BagHeader(
          name: bag, completed: done, total: items.length));
      for (final item in items) {
        widgets.add(CheckboxListTile(
          dense: true,
          value: item.isCompleted,
          onChanged: (_) =>
              provider.toggleItem(widget.tripId, cl.id, item.id),
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
          activeColor: AppColors.success,
          secondary: IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.error),
            onPressed: () =>
                provider.deleteItem(widget.tripId, cl.id, item.id),
          ),
        ));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, _) {
        final cl = _getChecklist(provider);

        if (cl == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _ProgressHeader(
                completed: cl.completedItems,
                total: cl.totalItems,
                progress: cl.progress,
                onGenerate: _generateDefault,
              ),
              Expanded(
                child: cl.items.isEmpty
                    ? _EmptyPackingState(onGenerate: _generateDefault)
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 100),
                        children: _buildBagSections(cl, provider),
                      ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    // Selettore del sacchetto in cui inserire il nuovo oggetto.
                    DropdownButton<String>(
                      value: _addBag,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      items: _bagOrder
                          .where((b) => b != _altriBag)
                          .map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _addBag = v ?? _addBag),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _addCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Aggiungi oggetto…',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: _addItem,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.primary, size: 32),
                      onPressed: () => _addItem(_addCtrl.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;
  final VoidCallback onGenerate;

  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.progress,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0
                      ? 'Nessun oggetto nella lista'
                      : '$completed / $total oggetti pronti',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white30,
                      color: Colors.white,
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 18),
            label: const Text('Genera lista',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(30),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}

// Intestazione di un sacchetto: nome, conteggio e barra di avanzamento dedicata.
class _BagHeader extends StatelessWidget {
  final String name;
  final int completed;
  final int total;
  const _BagHeader(
      {required this.name, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final full = total > 0 && completed == total;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Icon(full ? Icons.check_circle : Icons.inventory_2_outlined,
              size: 18,
              color: full ? AppColors.success : AppColors.primary),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text('$completed/$total',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                minHeight: 5,
                backgroundColor: AppColors.textHint.withAlpha(50),
                color: full ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPackingState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptyPackingState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.luggage_outlined,
              size: 72, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            'Lista valigia vuota',
            style: TextStyle(
                fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aggiungi oggetti manualmente o genera una lista base',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Genera lista base'),
          ),
        ],
      ),
    );
  }
}
