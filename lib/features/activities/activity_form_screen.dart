import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/stage_provider.dart';
import '../../shared/widgets/local_image.dart';

// Form di inserimento/modifica di un'attività: categoria, data/ora, luogo, costo,
// tappa associata e stato. In modalità modifica precompila i campi esistenti.
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
  // Controller per il pensiero del diario di viaggio.
  late final TextEditingController _journalCtrl;
  DateTime? _dateTime;
  late ActivityCategory _category;
  late ActivityStatus _status;
  String? _stageId;
  // Percorso della foto del diario selezionata (galleria o fotocamera).
  String? _photoPath;
  // Selettore di immagini nativo.
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  bool get _isEditing => widget.existingActivity != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existingActivity;
    _titleCtrl = TextEditingController(text: a?.title);
    _descCtrl = TextEditingController(text: a?.description);
    _locationCtrl = TextEditingController(text: a?.location);
    _costCtrl =
        TextEditingController(text: a?.estimatedCost?.toString());
    _notesCtrl = TextEditingController(text: a?.notes);
    _journalCtrl = TextEditingController(text: a?.journalNote);
    _dateTime = a?.dateTime;
    _category = a?.category ?? ActivityCategory.other;
    _status = a?.status ?? ActivityStatus.todo;
    _stageId = a?.stageId ?? widget.stageId;
    _photoPath = a?.photoPath;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    _journalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stages =
        context.read<StageProvider>().getByTrip(widget.tripId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditing ? 'Modifica attività' : 'Nuova attività'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration:
                  const InputDecoration(labelText: 'Titolo *'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ActivityCategory>(
              initialValue: _category,
              decoration:
                  const InputDecoration(labelText: 'Categoria'),
              items: ActivityCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.icon, size: 18),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data e ora',
                  prefixIcon:
                      Icon(Icons.schedule_outlined),
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
                  prefixIcon: Icon(Icons.place_outlined)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costCtrl,
              decoration: const InputDecoration(
                  labelText: 'Costo previsto (€)',
                  prefixIcon: Icon(Icons.euro_outlined)),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Inserisci un numero valido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            if (stages.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: _stageId,
                decoration:
                    const InputDecoration(labelText: 'Tappa associata'),
                items: [
                  const DropdownMenuItem(
                      value: null,
                      child: Text('Nessuna tappa')),
                  ...stages.map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.title),
                      )),
                ],
                onChanged: (v) => setState(() => _stageId = v),
              ),
            const SizedBox(height: 12),
            if (_isEditing)
              DropdownButtonFormField<ActivityStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Stato'),
                items: ActivityStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _status = v ?? _status),
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
              decoration:
                  const InputDecoration(labelText: 'Note'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            // --- Diario di viaggio: pensiero + foto dal telefono ---
            Row(
              children: const [
                Icon(Icons.menu_book_outlined,
                    size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Diario di viaggio',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Annota un ricordo e aggiungi una foto di questa attività',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _journalCtrl,
              decoration: const InputDecoration(
                labelText: 'I miei ricordi',
                prefixIcon: Icon(Icons.edit_note_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildPhotoSection(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEditing ? 'Salva' : 'Aggiungi attività'),
            ),
          ],
        ),
      ),
    );
  }

  // True se è stata selezionata una foto valida.
  bool get _hasPhoto => _photoPath != null && _photoPath!.isNotEmpty;

  // Sezione foto: mostra l'anteprima con il pulsante per rimuoverla, oppure i
  // pulsanti per scegliere un'immagine dalla galleria o scattarla.
  Widget _buildPhotoSection() {
    if (_hasPhoto) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LocalImage(
              path: _photoPath!,
              width: double.infinity,
              height: 180,
            ),
          ),
          // Pulsante per rimuovere la foto (la stringa vuota indica "nessuna foto").
          Padding(
            padding: const EdgeInsets.all(6),
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 16,
              child: IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: Colors.white),
                onPressed: () => setState(() => _photoPath = ''),
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickPhoto(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galleria'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickPhoto(ImageSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Fotocamera'),
          ),
        ),
      ],
    );
  }

  // Apre galleria o fotocamera e salva il percorso dell'immagine selezionata.
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
          source: source, maxWidth: 1600, imageQuality: 80);
      if (picked != null && mounted) {
        setState(() => _photoPath = picked.path);
      }
    } catch (_) {
      // Su alcune piattaforme la fotocamera potrebbe non essere disponibile.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire la fotocamera/galleria')),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
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
        await provider.updateActivity(widget.existingActivity!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.isEmpty
              ? null
              : _descCtrl.text.trim(),
          dateTime: _dateTime,
          location: _locationCtrl.text.isEmpty
              ? null
              : _locationCtrl.text.trim(),
          category: _category,
          estimatedCost: cost,
          status: _status,
          stageId: _stageId,
          notes: _notesCtrl.text.isEmpty
              ? null
              : _notesCtrl.text.trim(),
          // Diario: stringa vuota indica "nessun contenuto" (consente la rimozione).
          journalNote: _journalCtrl.text.trim(),
          photoPath: _photoPath ?? '',
        ));
      } else {
        final created = await provider.addActivity(
          tripId: widget.tripId,
          stageId: _stageId,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.isEmpty
              ? null
              : _descCtrl.text.trim(),
          dateTime: _dateTime,
          location: _locationCtrl.text.isEmpty
              ? null
              : _locationCtrl.text.trim(),
          category: _category,
          estimatedCost: cost,
          notes: _notesCtrl.text.isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
        // Se è stato compilato il diario, aggiorna l'attività appena creata.
        if (_journalCtrl.text.trim().isNotEmpty || _hasPhoto) {
          await provider.updateActivity(created.copyWith(
            journalNote: _journalCtrl.text.trim(),
            photoPath: _photoPath ?? '',
          ));
        }
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
