import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/stage.dart';
import '../../providers/stage_provider.dart';

// Form di inserimento/modifica di una tappa: titolo, data, località, descrizione e note.
class StageFormScreen extends StatefulWidget {
  final String tripId;
  final Stage? existingStage;
  const StageFormScreen(
      {super.key, required this.tripId, this.existingStage});

  @override
  State<StageFormScreen> createState() => _StageFormScreenState();
}

class _StageFormScreenState extends State<StageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _date;
  bool _isSaving = false;

  bool get _isEditing => widget.existingStage != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existingStage;
    _titleCtrl = TextEditingController(text: s?.title);
    _locationCtrl = TextEditingController(text: s?.location);
    _descCtrl = TextEditingController(text: s?.description);
    _notesCtrl = TextEditingController(text: s?.notes);
    _date = s?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica tappa' : 'Nuova tappa'),
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
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  prefixIcon:
                      Icon(Icons.calendar_today_outlined),
                ),
                child: Text(DateFormatter.date(_date)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Località',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration:
                  const InputDecoration(labelText: 'Descrizione'),
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
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEditing ? 'Salva' : 'Aggiungi tappa'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final provider = context.read<StageProvider>();
      if (_isEditing) {
        final updated = widget.existingStage!.copyWith(
          title: _titleCtrl.text.trim(),
          date: _date,
          location: _locationCtrl.text.isEmpty
              ? null
              : _locationCtrl.text.trim(),
          description: _descCtrl.text.isEmpty
              ? null
              : _descCtrl.text.trim(),
          notes:
              _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
        );
        await provider.updateStage(updated);
      } else {
        await provider.addStage(
          tripId: widget.tripId,
          title: _titleCtrl.text.trim(),
          date: _date,
          location: _locationCtrl.text.isEmpty
              ? null
              : _locationCtrl.text.trim(),
          description: _descCtrl.text.isEmpty
              ? null
              : _descCtrl.text.trim(),
          notes: _notesCtrl.text.isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
