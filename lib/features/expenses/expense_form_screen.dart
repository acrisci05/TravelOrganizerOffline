import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/expense.dart';
import '../../providers/expense_provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  final String tripId;
  final Expense? existingExpense;
  const ExpenseFormScreen(
      {super.key, required this.tripId, this.existingExpense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _date;
  late ExpenseCategory _category;
  late PaymentMethod _paymentMethod;
  late ExpenseStatus _status;
  bool _isSaving = false;

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingExpense;
    _titleCtrl = TextEditingController(text: e?.title);
    _amountCtrl =
        TextEditingController(text: e?.amount.toString());
    _notesCtrl = TextEditingController(text: e?.notes);
    _date = e?.date ?? DateTime.now();
    _category = e?.category ?? ExpenseCategory.other;
    _paymentMethod = e?.paymentMethod ?? PaymentMethod.cash;
    _status = e?.status ?? ExpenseStatus.actual;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica spesa' : 'Nuova spesa'),
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
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                  labelText: 'Importo (€) *',
                  prefixIcon: Icon(Icons.euro_outlined)),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obbligatorio';
                final parse = double.tryParse(v.replaceAll(',', '.'));
                if (parse == null) {
                  return 'Inserisci un numero valido';
                }
                if(parse < 0){
                  return 'Inserisci un numero positivo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _category,
              decoration:
                  const InputDecoration(labelText: 'Categoria'),
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.icon} ${c.label}'),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? _category),
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
            DropdownButtonFormField<ExpenseStatus>(
              initialValue: _status,
              decoration:
                  const InputDecoration(labelText: 'Tipo'),
              items: ExpenseStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                  labelText: 'Metodo di pagamento'),
              items: PaymentMethod.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(
                  () => _paymentMethod = v ?? _paymentMethod),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
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
                  : Text(_isEditing ? 'Salva' : 'Aggiungi spesa'),
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
      final provider = context.read<ExpenseProvider>();
      final amount = double.parse(
          _amountCtrl.text.replaceAll(',', '.'));
      if (_isEditing) {
        await provider.updateExpense(
            widget.existingExpense!.copyWith(
          title: _titleCtrl.text.trim(),
          amount: amount,
          category: _category,
          date: _date,
          paymentMethod: _paymentMethod,
          status: _status,
          notes: _notesCtrl.text.isEmpty
              ? null
              : _notesCtrl.text.trim(),
        ));
      } else {
        await provider.addExpense(
          tripId: widget.tripId,
          title: _titleCtrl.text.trim(),
          amount: amount,
          category: _category,
          date: _date,
          paymentMethod: _paymentMethod,
          status: _status,
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
