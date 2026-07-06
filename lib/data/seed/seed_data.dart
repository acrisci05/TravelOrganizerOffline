import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../models/stage.dart';
import '../models/activity.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/expense.dart';
import '../repositories/trip_repository.dart';
import '../repositories/stage_repository.dart';
import '../repositories/activity_repository.dart';
import '../repositories/checklist_repository.dart';
import '../repositories/expense_repository.dart';

// Inserisce dati demo direttamente nei repository (bypass providers),
// poi il chiamante ricarica i provider.
class SeedData {
  static final _uuid = const Uuid();

  static Future<void> populate() async {
    final tripRepo = TripRepository();
    final stageRepo = StageRepository();
    final actRepo = ActivityRepository();
    final clRepo = ChecklistRepository();
    final expRepo = ExpenseRepository();

    // ─────────────────────────────────────────────
    // VIAGGIO 1 — Vacanza a Roma (completato)
    // ─────────────────────────────────────────────
    final romaId = _uuid.v4();
    await tripRepo.insert(Trip(
      id: romaId,
      title: 'Vacanza a Roma',
      destination: 'Roma, Italia',
      startDate: DateTime(2026, 6, 5),
      endDate: DateTime(2026, 6, 9),
      description: 'Vacanza culturale nella Città Eterna',
      budget: 850.0,
      participants: 'Marco, Sofia, Luca',
      notes: 'Prenotare biglietti Colosseo in anticipo',
    ));

    // Tappe di Roma
    final romaS1 = _uuid.v4();
    final romaS2 = _uuid.v4();
    final romaS3 = _uuid.v4();

    await stageRepo.insert(Stage(
      id: romaS1, tripId: romaId, title: 'Fori Imperiali e Colosseo',
      date: DateTime(2026, 6, 5), location: 'Via Sacra, Roma', order: 0,
      description: 'Prima giornata nel cuore dell\'antica Roma',
    ));
    await stageRepo.insert(Stage(
      id: romaS2, tripId: romaId, title: 'Città del Vaticano',
      date: DateTime(2026, 6, 7), location: 'Viale Vaticano, Roma', order: 1,
      description: 'Visita ai Musei Vaticani e Cappella Sistina',
    ));
    await stageRepo.insert(Stage(
      id: romaS3, tripId: romaId, title: 'Trastevere e Gianicolo',
      date: DateTime(2026, 6, 8), location: 'Trastevere, Roma', order: 2,
      description: 'Il quartiere più caratteristico di Roma',
    ));

    // Attività di Roma
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: romaId, stageId: romaS1,
      title: 'Visita al Colosseo',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 6, 5, 10, 0),
      location: 'Piazza del Colosseo',
      estimatedCost: 18.0,
      status: ActivityStatus.done,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: romaId, stageId: romaS1,
      title: 'Passeggiata ai Fori Imperiali',
      category: ActivityCategory.excursion,
      dateTime: DateTime(2026, 6, 5, 14, 30),
      location: 'Fori Imperiali',
      status: ActivityStatus.done,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: romaId, stageId: romaS2,
      title: 'Musei Vaticani e Cappella Sistina',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 6, 7, 9, 0),
      location: 'Viale Vaticano 100',
      estimatedCost: 20.0,
      status: ActivityStatus.done,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: romaId, stageId: romaS2,
      title: 'Piazza San Pietro',
      category: ActivityCategory.excursion,
      dateTime: DateTime(2026, 6, 7, 12, 30),
      status: ActivityStatus.done,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: romaId, stageId: romaS3,
      title: 'Vista panoramica dal Gianicolo',
      category: ActivityCategory.free,
      dateTime: DateTime(2026, 6, 8, 17, 0),
      location: 'Piazzale Garibaldi',
      status: ActivityStatus.done,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: romaId, stageId: romaS3,
      title: 'Cena tipica a Trastevere',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 6, 8, 20, 0),
      location: 'Piazza di Santa Maria in Trastevere',
      estimatedCost: 35.0,
      status: ActivityStatus.done,
    ));

    // Checklist di Roma
    final clRomaId = _uuid.v4();
    await clRepo.insertChecklist(Checklist(
      id: clRomaId, tripId: romaId,
      title: 'Documenti e prenotazioni',
      description: 'Tutto il necessario per partire',
    ));
    final romaDocs = [
      'Carta d\'identità / Passaporto',
      'Biglietti treno Roma A/R',
      'Prenotazione hotel',
      'Biglietti Colosseo (prenotati online)',
      'Assicurazione viaggio',
    ];
    for (int i = 0; i < romaDocs.length; i++) {
      final itemId = _uuid.v4();
      await clRepo.insertItem(ChecklistItem(
        id: itemId, checklistId: clRomaId,
        title: romaDocs[i], order: i,
        isCompleted: true,
      ));
    }

    // Spese di Roma
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: romaId,
      title: 'Hotel Centro Roma (5 notti)',
      amount: 420.0, category: ExpenseCategory.accommodation,
      date: DateTime(2026, 6, 5),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: romaId,
      title: 'Biglietti Colosseo + Fori',
      amount: 54.0, category: ExpenseCategory.activity,
      date: DateTime(2026, 6, 5),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: romaId,
      title: 'Musei Vaticani (3 ingressi)',
      amount: 60.0, category: ExpenseCategory.activity,
      date: DateTime(2026, 6, 7),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: romaId,
      title: 'Ristoranti e pizzerie',
      amount: 165.0, category: ExpenseCategory.food,
      date: DateTime(2026, 6, 6),
      paymentMethod: PaymentMethod.cash,
      status: ExpenseStatus.actual,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: romaId,
      title: 'Treno Roma A/R',
      amount: 120.0, category: ExpenseCategory.transport,
      date: DateTime(2026, 6, 4),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));

    // ─────────────────────────────────────────────
    // VIAGGIO 2 — Weekend a Napoli (in corso)
    // ─────────────────────────────────────────────
    final napoliId = _uuid.v4();
    await tripRepo.insert(Trip(
      id: napoliId,
      title: 'Weekend a Napoli',
      destination: 'Napoli, Italia',
      startDate: DateTime(2026, 6, 25),
      endDate: DateTime(2026, 6, 27),
      description: 'Weekend tra pizza, arte e mare',
      budget: 400.0,
      participants: 'Marco, Sofia',
    ));

    // Tappe di Napoli
    final napoliS1 = _uuid.v4();
    final napoliS2 = _uuid.v4();

    await stageRepo.insert(Stage(
      id: napoliS1, tripId: napoliId,
      title: 'Centro Storico e Spaccanapoli',
      date: DateTime(2026, 6, 25), location: 'Via Spaccanapoli, Napoli', order: 0,
      description: 'Il cuore antico di Napoli, patrimonio UNESCO',
    ));
    await stageRepo.insert(Stage(
      id: napoliS2, tripId: napoliId,
      title: 'Lungomare di Mergellina',
      date: DateTime(2026, 6, 26), location: 'Via Caracciolo, Napoli', order: 1,
      description: 'Passeggiata sul lungomare e Castel dell\'Ovo',
    ));

    // Attività di Napoli
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: napoliId, stageId: napoliS1,
      title: 'Duomo di Napoli',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 6, 25, 10, 0),
      location: 'Via Duomo 147',
      status: ActivityStatus.done,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: napoliId, stageId: napoliS1,
      title: 'Pizza da Sorbillo',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 6, 25, 13, 0),
      location: 'Via dei Tribunali 32',
      estimatedCost: 15.0,
      status: ActivityStatus.done,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: napoliId, stageId: napoliS2,
      title: 'Passeggiata sul Lungomare',
      category: ActivityCategory.excursion,
      dateTime: DateTime(2026, 6, 26, 9, 0),
      status: ActivityStatus.todo,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: napoliId, stageId: napoliS2,
      title: 'Castel dell\'Ovo',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 6, 26, 11, 0),
      location: 'Borgo Marinari',
      status: ActivityStatus.todo,
    ));

    // Checklist di Napoli
    final clNapoliId = _uuid.v4();
    await clRepo.insertChecklist(Checklist(
      id: clNapoliId, tripId: napoliId,
      title: 'Da portare a Napoli',
    ));
    final napoliItems = [
      ('Scarpe comode per camminare', true),
      ('Macchina fotografica', true),
      ('Crema solare', false),
      ('Guida di Napoli', false),
      ('Borsa capiente', true),
    ];
    for (int i = 0; i < napoliItems.length; i++) {
      await clRepo.insertItem(ChecklistItem(
        id: _uuid.v4(), checklistId: clNapoliId,
        title: napoliItems[i].$1, order: i,
        isCompleted: napoliItems[i].$2,
      ));
    }

    // Spese di Napoli
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: napoliId,
      title: 'B&B Centro Napoli (2 notti)',
      amount: 160.0, category: ExpenseCategory.accommodation,
      date: DateTime(2026, 6, 25),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: napoliId,
      title: 'Pizza e street food',
      amount: 45.0, category: ExpenseCategory.food,
      date: DateTime(2026, 6, 25),
      paymentMethod: PaymentMethod.cash,
      status: ExpenseStatus.actual,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: napoliId,
      title: 'Treno Napoli A/R',
      amount: 95.0, category: ExpenseCategory.transport,
      date: DateTime(2026, 6, 25),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.planned,
    ));

    // ─────────────────────────────────────────────
    // VIAGGIO 3 — Avventura a Parigi (futuro)
    // ─────────────────────────────────────────────
    final parigiId = _uuid.v4();
    await tripRepo.insert(Trip(
      id: parigiId,
      title: 'Avventura a Parigi',
      destination: 'Parigi, Francia',
      startDate: DateTime(2026, 9, 10),
      endDate: DateTime(2026, 9, 16),
      description: 'Viaggio studio: architettura, arte e gastronomia',
      budget: 1500.0,
      participants: 'Marco',
      notes: 'Prenotare volo almeno 2 mesi prima',
    ));

    // Tappe di Parigi
    final parigiS1 = _uuid.v4();
    final parigiS2 = _uuid.v4();
    final parigiS3 = _uuid.v4();

    await stageRepo.insert(Stage(
      id: parigiS1, tripId: parigiId,
      title: 'Île de la Cité e Notre-Dame',
      date: DateTime(2026, 9, 10), location: 'Île de la Cité, Parigi', order: 0,
      description: 'Cuore storico di Parigi',
    ));
    await stageRepo.insert(Stage(
      id: parigiS2, tripId: parigiId,
      title: 'Montmartre e Sacré-Cœur',
      date: DateTime(2026, 9, 12), location: 'Montmartre, Parigi', order: 1,
      description: 'Il quartiere degli artisti',
    ));
    await stageRepo.insert(Stage(
      id: parigiS3, tripId: parigiId,
      title: 'Le Marais e Centre Pompidou',
      date: DateTime(2026, 9, 14), location: 'Le Marais, Parigi', order: 2,
      description: 'Arte contemporanea e architettura moderna',
    ));

    // Attività di Parigi
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: parigiId, stageId: parigiS1,
      title: 'Notre-Dame de Paris',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 9, 10, 10, 0),
      location: 'Parvis Notre-Dame',
      status: ActivityStatus.todo,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: parigiId, stageId: parigiS1,
      title: 'Crociera sulla Senna',
      category: ActivityCategory.excursion,
      dateTime: DateTime(2026, 9, 10, 15, 0),
      location: 'Port de la Bourdonnais',
      estimatedCost: 25.0,
      status: ActivityStatus.todo,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: parigiId, stageId: parigiS2,
      title: 'Basilica del Sacré-Cœur',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 9, 12, 9, 0),
      location: 'Place du Tertre',
      status: ActivityStatus.todo,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: parigiId, stageId: parigiS2,
      title: 'Quartiere degli artisti di Montmartre',
      category: ActivityCategory.free,
      dateTime: DateTime(2026, 9, 12, 11, 30),
      status: ActivityStatus.todo,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: parigiId, stageId: parigiS3,
      title: 'Centre Pompidou',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 9, 14, 10, 0),
      location: 'Place Georges-Pompidou',
      estimatedCost: 14.0,
      status: ActivityStatus.todo,
    ));
    await actRepo.insert(Activity(
      id: _uuid.v4(), tripId: parigiId, stageId: parigiS3,
      title: 'Cena gourmet a Le Marais',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 9, 14, 20, 0),
      location: 'Rue de Bretagne',
      estimatedCost: 55.0,
      status: ActivityStatus.todo,
    ));

    // Checklist di Parigi
    final clParigiId = _uuid.v4();
    await clRepo.insertChecklist(Checklist(
      id: clParigiId, tripId: parigiId,
      title: 'Preparativi Parigi',
      description: 'Da fare prima della partenza',
    ));
    final parigiItems = [
      ('Prenotare volo Napoli-Parigi', true),
      ('Prenotare hotel (6 notti)', false),
      ('Controllare scadenza passaporto', true),
      ('Comprare Pass Musées', false),
      ('Scaricare mappe offline di Parigi', false),
      ('Imparare frasi base in francese', false),
    ];
    for (int i = 0; i < parigiItems.length; i++) {
      await clRepo.insertItem(ChecklistItem(
        id: _uuid.v4(), checklistId: clParigiId,
        title: parigiItems[i].$1, order: i,
        isCompleted: parigiItems[i].$2,
      ));
    }

    // Spese di Parigi
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: parigiId,
      title: 'Volo A/R Napoli–Parigi',
      amount: 280.0, category: ExpenseCategory.transport,
      date: DateTime(2026, 9, 10),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.planned,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: parigiId,
      title: 'Hotel Parigi (6 notti)',
      amount: 720.0, category: ExpenseCategory.accommodation,
      date: DateTime(2026, 9, 10),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.planned,
    ));
    await expRepo.insert(Expense(
      id: _uuid.v4(), tripId: parigiId,
      title: 'Pass Musei + attrazioni',
      amount: 85.0, category: ExpenseCategory.activity,
      date: DateTime(2026, 9, 10),
      paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.planned,
    ));
  }
}
