import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/checklist.dart';
import '../../providers/checklist_provider.dart';

class PackingListScreen extends StatefulWidget {
  final String tripId;
  const PackingListScreen({super.key, required this.tripId});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  static const _packingTitle = '🧳 Lista Valigia';

  static const _defaultItems = [
    '👕 T-shirt',
    '👖 Pantaloni',
    '👟 Scarpe',
    '🧥 Giacca / Maglione',
    '🩲 Biancheria intima',
    '🧦 Calzini',
    '😴 Pigiama',
    '🛂 Passaporto / Carta d\'identità',
    '🎫 Biglietti di viaggio',
    '📋 Assicurazione viaggio',
    '🏨 Conferme prenotazioni',
    '📱 Caricabatterie telefono',
    '🔋 Power bank',
    '🎧 Cuffie',
    '🔌 Adattatore presa',
    '🪥 Spazzolino e dentifricio',
    '🧴 Shampoo e balsamo',
    '🧼 Sapone / Gel doccia',
    '🪒 Rasoio / Depilatore',
    '🧴 Deodorante',
    '💊 Farmaci personali',
    '🩹 Kit pronto soccorso',
    '☀️ Crema solare',
    '😎 Occhiali da sole',
    '☂️ Ombrello',
    '📷 Fotocamera',
  ];

  String? _checklistId;
  final _addCtrl = TextEditingController();

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
    final existing = checklists
        .where((c) => c.title == _packingTitle)
        .firstOrNull;
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

  Future<void> _generateDefault() async {
    if (!mounted) return;
    final provider = context.read<ChecklistProvider>();
    final cl = _getChecklist(provider);
    if (cl == null) return;
    final existing = cl.items.map((i) => i.title).toSet();
    int added = 0;
    for (final item in _defaultItems) {
      if (!existing.contains(item)) {
        await provider.addItem(widget.tripId, cl.id, item);
        added++;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added > 0
                ? '$added elementi aggiunti alla lista'
                : 'Lista già completa',
          ),
        ),
      );
    }
  }

  Future<void> _addItem(String text) async {
    if (text.trim().isEmpty) return;
    final provider = context.read<ChecklistProvider>();
    final cl = _getChecklist(provider);
    if (cl == null) return;
    await provider.addItem(widget.tripId, cl.id, text.trim());
    _addCtrl.clear();
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
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: cl.items.length,
                        itemBuilder: (ctx, i) {
                          final item = cl.items[i];
                          return CheckboxListTile(
                            value: item.isCompleted,
                            onChanged: (_) => provider.toggleItem(
                              widget.tripId,
                              cl.id,
                              item.id,
                            ),
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
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                              onPressed: () => provider.deleteItem(
                                widget.tripId,
                                cl.id,
                                item.id,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Aggiungi oggetto…',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: _addItem,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                        size: 32,
                      ),
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
                    fontSize: 15,
                  ),
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
          if (total == 0) ...[
            TextButton.icon(
              onPressed: onGenerate,
              icon: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                'Genera lista',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
          ],
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
          const Icon(
            Icons.luggage_outlined,
            size: 72,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'Lista valigia vuota',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
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
