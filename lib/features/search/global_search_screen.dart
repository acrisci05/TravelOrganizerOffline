import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/global_search.dart';
import '../trips/trip_detail_screen.dart';

// Schermata di ricerca globale "Spotlight": mentre l'utente digita, cerca in
// modo predittivo tra viaggi, tappe, attività e spese e mostra i risultati
// raggruppati per categoria. Toccando un risultato si apre il viaggio collegato.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _service = GlobalSearchService();
  final _ctrl = TextEditingController();
  List<SearchResult> _results = [];
  bool _searched = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Esegue la ricerca a ogni modifica del testo (ricerca predittiva).
  Future<void> _onChanged(String value) async {
    final results = await _service.search(value);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searched = value.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Raggruppa i risultati per tipo, mantenendo l'ordine delle categorie.
    final grouped = <SearchResultType, List<SearchResult>>{};
    for (final r in _results) {
      (grouped[r.type] ??= []).add(r);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Cerca ovunque: viaggi, tappe, attività, spese…',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                _onChanged('');
              },
            ),
        ],
      ),
      body: !_searched
          ? const _SearchHint()
          : _results.isEmpty
              ? const _NoResults()
              : ListView(
                  children: [
                    for (final type in SearchResultType.values)
                      if (grouped[type] != null) ...[
                        _SectionHeader(
                            label: type.label,
                            count: grouped[type]!.length),
                        ...grouped[type]!.map((r) => _ResultTile(result: r)),
                      ],
                  ],
                ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        '$label ($count)',
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 13),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final SearchResult result;
  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(result.type.icon, color: AppColors.primary),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: const Icon(Icons.chevron_right),
        // Tutti i risultati aprono il viaggio collegato.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TripDetailScreen(tripId: result.tripId),
          ),
        ),
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore,
              size: 72, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('Cerca in tutta l\'app',
              style: TextStyle(
                  fontSize: 16, color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text('Digita una parola per trovare viaggi, tappe,\nattività e spese',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('Nessun risultato trovato',
              style: TextStyle(
                  fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
