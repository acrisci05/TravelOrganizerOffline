import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/widgets/confirm_dialog.dart';

class TripFormScreen extends StatefulWidget {
  final Trip? existingTrip;
  const TripFormScreen({super.key, this.existingTrip});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _destCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _participantsCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSaving = false;

  bool get _isEditing => widget.existingTrip != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTrip;
    _titleCtrl = TextEditingController(text: t?.title);
    _destCtrl = TextEditingController(text: t?.destination);
    _descCtrl = TextEditingController(text: t?.description);
    _budgetCtrl = TextEditingController(text: t?.budget?.toString());
    _participantsCtrl = TextEditingController(text: t?.participants);
    _notesCtrl = TextEditingController(text: t?.notes);
    _startDate = t?.startDate ?? DateTime.now().add(const Duration(days: 1));
    _endDate = t?.endDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _destCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    _participantsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica viaggio' : 'Nuovo viaggio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(
              _titleCtrl,
              'Titolo *',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            _field(
              _destCtrl,
              'Destinazione *',
              prefixIcon: Icons.place_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            _DateRangePicker(
              startDate: _startDate,
              endDate: _endDate,
              onStartChanged: (d) => setState(() => _startDate = d),
              onEndChanged: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: 12),
            _field(
              _budgetCtrl,
              'Budget previsto (€)',
              prefixIcon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null) {
                    return 'Inserisci un numero valido';
                  }
                  if (parsed < 0) {
                    return 'Il budget non può essere negativo';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              _participantsCtrl,
              'Partecipanti',
              prefixIcon: Icons.group_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              _descCtrl,
              'Descrizione',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _field(
              _notesCtrl,
              'Note',
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Salva modifiche' : 'Crea viaggio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }

  // TripStatus computedStatus (DateTime startDat, DateTime endDay){
  // }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La data di fine non può essere prima della data di inizio',
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
    );
    final endDay = DateTime(_endDate.year, _endDate.month, _endDate.day);

    if (startDay.isBefore(today)) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Conferma la data inserita',
        message:
            'La data di inizio del viaggio è precedente ad oggi. Vuoi continuare comunque?',
            confirmLabel: 'Continua',
      );
      if (confirmed != true) return;
    }

    if (endDay.isBefore(today)) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Conferma la data inserita',
        message:
            'La data di fine del viaggio è precedente ad oggi. Vuoi continuare comunque?',
            confirmLabel: 'Continua',
      );
      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);
    try {
      final provider = context.read<TripProvider>();
      final budget = _budgetCtrl.text.isEmpty
          ? null
          : double.tryParse(_budgetCtrl.text.replaceAll(',', '.'));

      if (_isEditing) {
        final draft = widget.existingTrip!.copyWith(
          title: _titleCtrl.text.trim(),
          destination: _destCtrl.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
          // status: computedStatus(),
          budget: budget,
          participants: _participantsCtrl.text.isEmpty
              ? null
              : _participantsCtrl.text.trim(),
          notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
        );
        final updated = draft.copyWith(
          status: draft.computedStatus,
        );
        await provider.updateTrip(updated);
      } else {
        await provider.addTrip(
          title: _titleCtrl.text.trim(),
          destination: _destCtrl.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
          budget: budget,
          participants: _participantsCtrl.text.isEmpty
              ? null
              : _participantsCtrl.text.trim(),
          notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _DateRangePicker extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;

  const _DateRangePicker({
    required this.startDate,
    required this.endDate,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _dateTile(
            context,
            label: 'Partenza',
            date: startDate,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (d != null) onStartChanged(d);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 20),
        ),
        Expanded(
          child: _dateTile(
            context,
            label: 'Ritorno',
            date: endDate,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: endDate.isBefore(startDate) ? startDate : endDate,
                firstDate: startDate,
                lastDate: DateTime(2100),
              );
              if (d != null) onEndChanged(d);
            },
          ),
        ),
      ],
    );
  }

  Widget _dateTile(
    BuildContext context, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(DateFormatter.date(date)),
      ),
    );
  }
}
