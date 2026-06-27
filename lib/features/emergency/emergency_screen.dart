import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/emergency_catalog.dart';
import '../../data/models/trip.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers/trip_provider.dart';

// Schermata "In caso di emergenza" (ICE): raccoglie i dati medici essenziali
// dell'utente (salvati in locale) e mostra i numeri di emergenza del paese di
// destinazione, dedotti automaticamente o scelti manualmente. È pensata per
// essere consultabile rapidamente anche completamente offline.
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _repo = SettingsRepository();

  final _bloodCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _contact1NameCtrl = TextEditingController();
  final _contact1PhoneCtrl = TextEditingController();
  final _contact2NameCtrl = TextEditingController();
  final _contact2PhoneCtrl = TextEditingController();

  String _country = 'Italia';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _bloodCtrl.dispose();
    _allergiesCtrl.dispose();
    _notesCtrl.dispose();
    _contact1NameCtrl.dispose();
    _contact1PhoneCtrl.dispose();
    _contact2NameCtrl.dispose();
    _contact2PhoneCtrl.dispose();
    super.dispose();
  }

  // Carica i dati medici salvati e deduce il paese dal viaggio più rilevante.
  Future<void> _load() async {
    _bloodCtrl.text = await _repo.get('ice_blood') ?? '';
    _allergiesCtrl.text = await _repo.get('ice_allergies') ?? '';
    _notesCtrl.text = await _repo.get('ice_notes') ?? '';
    _contact1NameCtrl.text = await _repo.get('ice_contact1_name') ?? '';
    _contact1PhoneCtrl.text = await _repo.get('ice_contact1_phone') ?? '';
    _contact2NameCtrl.text = await _repo.get('ice_contact2_name') ?? '';
    _contact2PhoneCtrl.text = await _repo.get('ice_contact2_phone') ?? '';

    // Deduce il paese dalla destinazione del viaggio in corso o del prossimo.
    if (mounted) {
      final trips = context.read<TripProvider>().trips;
      final relevant = _mostRelevantTrip(trips);
      if (relevant != null) {
        final detected = EmergencyCatalog.detectCountry(relevant.destination);
        if (detected != null) _country = detected;
      }
      setState(() => _loaded = true);
    }
  }

  // Sceglie il viaggio più rilevante: in corso, altrimenti il prossimo futuro.
  Trip? _mostRelevantTrip(List<Trip> trips) {
    if (trips.isEmpty) return null;
    Trip? ongoing;
    Trip? nextFuture;
    for (final t in trips) {
      final s = t.computedStatus;
      if (s == TripStatus.ongoing) ongoing = t;
      if (s == TripStatus.future) {
        if (nextFuture == null || t.startDate.isBefore(nextFuture.startDate)) {
          nextFuture = t;
        }
      }
    }
    return ongoing ?? nextFuture ?? trips.first;
  }

  Future<void> _save() async {
    await _repo.set('ice_blood', _bloodCtrl.text.trim());
    await _repo.set('ice_allergies', _allergiesCtrl.text.trim());
    await _repo.set('ice_notes', _notesCtrl.text.trim());
    await _repo.set('ice_contact1_name', _contact1NameCtrl.text.trim());
    await _repo.set('ice_contact1_phone', _contact1PhoneCtrl.text.trim());
    await _repo.set('ice_contact2_name', _contact2NameCtrl.text.trim());
    await _repo.set('ice_contact2_phone', _contact2PhoneCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dati di emergenza salvati')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emergenza')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final numbers = EmergencyCatalog.byCountry[_country] ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('In caso di emergenza'),
        backgroundColor: AppColors.error,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Numeri di emergenza per paese ---
          _SectionTitle('Numeri di emergenza', Icons.local_hospital_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.public, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      const Text('Paese: '),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _country,
                          isExpanded: true,
                          items: EmergencyCatalog.countries
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _country = v ?? _country),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...numbers.map((n) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.phone_in_talk,
                            color: AppColors.error),
                        title: Text(n.label),
                        trailing: Text(
                          n.number,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.error),
                        ),
                        // Tocca per copiare il numero negli appunti.
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: n.number));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Numero ${n.number} copiato')),
                          );
                        },
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Dati medici personali ---
          _SectionTitle('I miei dati medici', Icons.medical_information_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _bloodCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Gruppo sanguigno',
                        prefixIcon: Icon(Icons.bloodtype_outlined)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _allergiesCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Allergie',
                        prefixIcon: Icon(Icons.warning_amber_outlined)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Patologie / note mediche',
                        prefixIcon: Icon(Icons.notes_outlined)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Contatti da chiamare ---
          _SectionTitle('Contatti di emergenza', Icons.contact_phone_outlined),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _contactRow(_contact1NameCtrl, _contact1PhoneCtrl, 1),
                  const Divider(height: 24),
                  _contactRow(_contact2NameCtrl, _contact2PhoneCtrl, 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salva dati di emergenza'),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
      TextEditingController nameCtrl, TextEditingController phoneCtrl, int n) {
    return Column(
      children: [
        TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
              labelText: 'Contatto $n - Nome',
              prefixIcon: const Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
              labelText: 'Telefono',
              prefixIcon: Icon(Icons.phone_outlined)),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionTitle(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.error),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
