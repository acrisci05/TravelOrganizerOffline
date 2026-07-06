import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/stage_provider.dart';
import '../../providers/trip_provider.dart';

class ActivityFormScreen extends StatefulWidget {
  final String tripId;
  final String? stageId;
  final Activity? existingActivity;

  const ActivityFormScreen({
    super.key,
    required this.tripId,
    this.stageId,
    this.existingActivity,
  });

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _notesCtrl;
  DateTime? _dateTime;
  String? _stageDateError;
  late ActivityCategory _category;
  late ActivityStatus _status;
  String? _stageId;
  bool _isSaving = false;

  bool get _isEditing => widget.existingActivity != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existingActivity;
    _titleCtrl = TextEditingController(text: a?.title);
    _descCtrl = TextEditingController(text: a?.description);
    _locationCtrl = TextEditingController(text: a?.location);
    _costCtrl = TextEditingController(text: a?.estimatedCost?.toString());
    _notesCtrl = TextEditingController(text: a?.notes);
    _dateTime = a?.dateTime;
    _category = a?.category ?? ActivityCategory.other;
    _status = a?.status ?? ActivityStatus.todo;
    _stageId = a?.stageId ?? widget.stageId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stages = context.read<StageProvider>().getByTrip(widget.tripId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica attività' : 'Nuova attività'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Titolo *'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ActivityCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: ActivityCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.icon} ${c.label}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data e ora',
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                child: Text(
                  _dateTime != null
                      ? DateFormatter.dateTime(_dateTime!)
                      : 'Seleziona data e ora (opzionale)',
                  style: TextStyle(
                    color: _dateTime != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Luogo',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCtrl,
              decoration: const InputDecoration(
                labelText: 'Costo previsto (€)',
                prefixIcon: Icon(Icons.euro_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final parse = double.tryParse(v.replaceAll(',', '.'));
                  if (parse == null) {
                    return 'Inserisci un numero valido';
                  }
                  if (parse < 0) {
                    return 'Inserisci un numero positivo';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            if (stages.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: _stageId,
                decoration: InputDecoration(
                  labelText: 'Tappa associata',
                  errorText: _stageDateError,
                  errorMaxLines: 2,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Nessuna tappa'),
                  ),
                  ...stages.map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.title)),
                  ),
                ],
                onChanged: (v) {
                  final selectedStage = v == null
                      ? null
                      : stages.firstWhereOrNull((s) => s.id == v);

                  setState(() {
                    _stageId = v;
                    _stageDateError = null;

                    if (selectedStage == null || _dateTime == null) {
                      return;
                    }

                    final stageDate = selectedStage.date;
                    final isSameDay = DateUtils.isSameDay(_dateTime, stageDate);

                    if (!isSameDay) {
                      _dateTime = null;
                      _stageDateError =
                          'La data dell’attività deve coincidere con il giorno della tappa. '
                          'Seleziona di nuovo data e ora.';
                    }
                  });
                },
              ),
            const SizedBox(height: 12),
            if (_isEditing)
              DropdownButtonFormField<ActivityStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Stato'),
                items: ActivityStatus.values
                    .map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 2,
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
                  : Text(_isEditing ? 'Salva' : 'Aggiungi attività'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final trip = context.read<TripProvider>().getById(widget.tripId);
    if (trip == null) return;

    final stages = context.read<StageProvider>().getByTrip(widget.tripId);

    final selectedStage = _stageId == null
        ? null
        : stages.firstWhereOrNull((s) => s.id == _stageId);

    final firstDate = selectedStage != null
        ? DateUtils.dateOnly(selectedStage.date)
        : DateUtils.dateOnly(trip.startDate);

    final lastDate = selectedStage != null
        ? DateUtils.dateOnly(selectedStage.date)
        : DateUtils.dateOnly(trip.endDate);

    final today = DateUtils.dateOnly(DateTime.now());

    final initialDate = _dateTime != null
        ? DateUtils.dateOnly(_dateTime!)
        : today.isBefore(firstDate)
        ? firstDate
        : today.isAfter(lastDate)
        ? lastDate
        : today;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date == null || !mounted) return;

    final initialTime = _dateTime != null
        ? TimeOfDay.fromDateTime(_dateTime!)
        : TimeOfDay.now();

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time == null) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _stageDateError = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final provider = context.read<ActivityProvider>();
      final cost = _costCtrl.text.isEmpty
          ? null
          : double.tryParse(_costCtrl.text.replaceAll(',', '.'));

      if (_isEditing) {
        await provider.updateActivity(
          widget.existingActivity!.copyWith(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
            dateTime: _dateTime,
            location: _locationCtrl.text.isEmpty
                ? null
                : _locationCtrl.text.trim(),
            category: _category,
            estimatedCost: cost,
            status: _status,
            stageId: _stageId,
            clearStageId: _stageId == null,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
          ),
        );
      } else {
        await provider.addActivity(
          tripId: widget.tripId,
          stageId: _stageId,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
          dateTime: _dateTime,
          location: _locationCtrl.text.isEmpty
              ? null
              : _locationCtrl.text.trim(),
          category: _category,
          estimatedCost: cost,
          notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
