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

// Inserisce alcuni viaggi di esempio completi (Tokyo, Barcellona, Roma già
// conclusi e Parigi in programma). Servono a mostrare tutte le funzionalità
// dell'app: tag, modalità di viaggio, attività con orari, diario di viaggio,
// checklist organizzate in sacchetti e spese previste/effettive.
//
// I dati vengono scritti direttamente nei repository; il chiamante (main)
// li inserisce solo se il database è ancora vuoto.
class SeedData {
  static const _uuid = Uuid();

  static final _tripRepo = TripRepository();
  static final _stageRepo = StageRepository();
  static final _actRepo = ActivityRepository();
  static final _clRepo = ChecklistRepository();
  static final _expRepo = ExpenseRepository();

  static Future<void> populate() async {
    await _seedTokyo();
    await _seedBarcellona();
    await _seedRoma();
    await _seedParigi();
  }

  // ─────────────────────────────────────────────────────────────
  // VIAGGIO 1 — Tokyo (concluso)
  // ─────────────────────────────────────────────────────────────
  static Future<void> _seedTokyo() async {
    final tripId = _uuid.v4();
    await _tripRepo.insert(Trip(
      id: tripId,
      title: 'Avventura a Tokyo',
      destination: 'Tokyo, Giappone',
      startDate: DateTime(2026, 3, 5),
      endDate: DateTime(2026, 3, 14),
      description: 'Dieci giorni tra tradizione e modernità in Giappone.',
      status: TripStatus.completed,
      budget: 2800,
      participants: 'Marco, Giulia',
      notes: 'Acquistare il Japan Rail Pass prima della partenza.',
      tags: const ['Città', 'Estero'],
      transportMode: TransportMode.plane,
    ));

    final s1 = _uuid.v4();
    final s2 = _uuid.v4();
    await _stageRepo.insert(Stage(
      id: s1, tripId: tripId, title: 'Shibuya e Shinjuku',
      date: DateTime(2026, 3, 6), location: 'Shibuya, Tokyo', order: 0,
      description: 'I quartieri più vivaci e moderni della città.',
    ));
    await _stageRepo.insert(Stage(
      id: s2, tripId: tripId, title: 'Asakusa e tradizione',
      date: DateTime(2026, 3, 8), location: 'Asakusa, Tokyo', order: 1,
      description: 'Templi storici e cultura tradizionale giapponese.',
    ));

    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: s1,
      title: 'Attraversamento di Shibuya',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 3, 6, 10, 0),
      location: 'Shibuya Crossing',
      status: ActivityStatus.done,
      journalNote:
          'Incredibile vedere migliaia di persone attraversare insieme: '
          'la prima vera immagine di Tokyo.',
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: s1,
      title: 'Cena di ramen',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 3, 6, 20, 0),
      location: 'Ichiran Shibuya',
      estimatedCost: 18,
      status: ActivityStatus.done,
      journalNote: 'Il miglior ramen mai mangiato, servito in una cabina privata.',
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: s2,
      title: 'Tempio Senso-ji',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 3, 8, 9, 30),
      location: 'Asakusa',
      status: ActivityStatus.done,
      journalNote: 'Atmosfera magica all\'alba, prima dell\'arrivo dei turisti.',
    ));

    await _packingList(tripId, completed: true);

    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Volo A/R per Tokyo',
      amount: 950, category: ExpenseCategory.transport,
      date: DateTime(2026, 3, 5), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Hotel (9 notti)',
      amount: 1080, category: ExpenseCategory.accommodation,
      date: DateTime(2026, 3, 5), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Japan Rail Pass',
      amount: 270, category: ExpenseCategory.transport,
      date: DateTime(2026, 3, 5), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Pasti e street food',
      amount: 320, category: ExpenseCategory.food,
      date: DateTime(2026, 3, 7), paymentMethod: PaymentMethod.cash,
      status: ExpenseStatus.actual,
    ));
  }

  // ─────────────────────────────────────────────────────────────
  // VIAGGIO 2 — Barcellona (concluso)
  // ─────────────────────────────────────────────────────────────
  static Future<void> _seedBarcellona() async {
    final tripId = _uuid.v4();
    await _tripRepo.insert(Trip(
      id: tripId,
      title: 'Weekend a Barcellona',
      destination: 'Barcellona, Spagna',
      startDate: DateTime(2026, 4, 10),
      endDate: DateTime(2026, 4, 15),
      description: 'Arte di Gaudí, tapas e mare.',
      status: TripStatus.completed,
      budget: 800,
      participants: 'Marco, Sofia, Luca',
      tags: const ['Mare', 'Città', 'Estero'],
      transportMode: TransportMode.plane,
    ));

    final s1 = _uuid.v4();
    await _stageRepo.insert(Stage(
      id: s1, tripId: tripId, title: 'Le opere di Gaudí',
      date: DateTime(2026, 4, 11), location: 'Eixample, Barcellona', order: 0,
      description: 'Sagrada Família e Casa Batlló.',
    ));

    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: s1,
      title: 'Sagrada Família',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 4, 11, 10, 0),
      location: 'Carrer de Mallorca',
      estimatedCost: 26,
      status: ActivityStatus.done,
      journalNote: 'La luce attraverso le vetrate è qualcosa di indimenticabile.',
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: s1,
      title: 'Tapas alla Boqueria',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 4, 11, 13, 30),
      location: 'Mercat de la Boqueria',
      estimatedCost: 30,
      status: ActivityStatus.done,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId,
      title: 'Pomeriggio in spiaggia',
      category: ActivityCategory.free,
      dateTime: DateTime(2026, 4, 12, 15, 0),
      location: 'Barceloneta',
      status: ActivityStatus.done,
    ));

    await _packingList(tripId, completed: true);

    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Volo A/R',
      amount: 180, category: ExpenseCategory.transport,
      date: DateTime(2026, 4, 10), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Hotel (5 notti)',
      amount: 420, category: ExpenseCategory.accommodation,
      date: DateTime(2026, 4, 10), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Ristoranti e tapas',
      amount: 160, category: ExpenseCategory.food,
      date: DateTime(2026, 4, 11), paymentMethod: PaymentMethod.cash,
      status: ExpenseStatus.actual,
    ));
  }

  // ─────────────────────────────────────────────────────────────
  // VIAGGIO 3 — Roma (concluso)
  // ─────────────────────────────────────────────────────────────
  static Future<void> _seedRoma() async {
    final tripId = _uuid.v4();
    await _tripRepo.insert(Trip(
      id: tripId,
      title: 'Vacanza a Roma',
      destination: 'Roma, Italia',
      startDate: DateTime(2026, 5, 20),
      endDate: DateTime(2026, 5, 24),
      description: 'Un tuffo nella storia della Città Eterna.',
      status: TripStatus.completed,
      budget: 600,
      participants: 'Marco, Sofia',
      tags: const ['Città'],
      transportMode: TransportMode.train,
    ));

    final s1 = _uuid.v4();
    await _stageRepo.insert(Stage(
      id: s1, tripId: tripId, title: 'Roma antica',
      date: DateTime(2026, 5, 21), location: 'Colosseo, Roma', order: 0,
      description: 'Colosseo e Fori Imperiali.',
    ));

    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: s1,
      title: 'Visita al Colosseo',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 5, 21, 10, 0),
      location: 'Piazza del Colosseo',
      estimatedCost: 18,
      status: ActivityStatus.done,
      journalNote: 'Emozionante immaginare i gladiatori in quell\'arena.',
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: s1,
      title: 'Cena a Trastevere',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 5, 21, 20, 30),
      location: 'Trastevere',
      estimatedCost: 35,
      status: ActivityStatus.done,
    ));

    await _packingList(tripId, completed: true);

    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Treno A/R',
      amount: 90, category: ExpenseCategory.transport,
      date: DateTime(2026, 5, 20), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Hotel centro (4 notti)',
      amount: 360, category: ExpenseCategory.accommodation,
      date: DateTime(2026, 5, 20), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.actual,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Ristoranti',
      amount: 140, category: ExpenseCategory.food,
      date: DateTime(2026, 5, 21), paymentMethod: PaymentMethod.cash,
      status: ExpenseStatus.actual,
    ));
  }

  // ─────────────────────────────────────────────────────────────
  // VIAGGIO 4 — Parigi (in programma, itinerario completo)
  // ─────────────────────────────────────────────────────────────
  static Future<void> _seedParigi() async {
    final tripId = _uuid.v4();
    await _tripRepo.insert(Trip(
      id: tripId,
      title: 'Parigi in autunno',
      destination: 'Parigi, Francia',
      startDate: DateTime(2026, 10, 27),
      endDate: DateTime(2026, 11, 1),
      description:
          'Sei giorni nella Ville Lumière: musei, monumenti e gastronomia.',
      status: TripStatus.future,
      budget: 1400,
      participants: 'Marco, Sofia',
      notes: 'Prenotare in anticipo Louvre e Tour Eiffel per saltare la fila. '
          'Spostarsi con la metro (carnet di biglietti o Navigo).',
      tags: const ['Città', 'Estero'],
      transportMode: TransportMode.plane,
    ));

    // Tappe dell'itinerario.
    final d1 = _uuid.v4();
    final d2 = _uuid.v4();
    final d3 = _uuid.v4();
    final d4 = _uuid.v4();
    final d5 = _uuid.v4();

    await _stageRepo.insert(Stage(
      id: d1, tripId: tripId, title: 'Giorno 1 — Arrivo e Île de la Cité',
      date: DateTime(2026, 10, 27), location: 'Île de la Cité, Parigi', order: 0,
      description: 'Volo, check-in e primo contatto con il centro storico.',
    ));
    await _stageRepo.insert(Stage(
      id: d2, tripId: tripId, title: 'Giorno 2 — Louvre e Tour Eiffel',
      date: DateTime(2026, 10, 28), location: 'Rive Droite, Parigi', order: 1,
      description: 'I due simboli di Parigi in un\'unica giornata.',
    ));
    await _stageRepo.insert(Stage(
      id: d3, tripId: tripId, title: 'Giorno 3 — Montmartre',
      date: DateTime(2026, 10, 29), location: 'Montmartre, Parigi', order: 2,
      description: 'Il quartiere bohémien degli artisti.',
    ));
    await _stageRepo.insert(Stage(
      id: d4, tripId: tripId, title: 'Giorno 4 — Versailles',
      date: DateTime(2026, 10, 30), location: 'Reggia di Versailles', order: 3,
      description: 'Gita in giornata alla maestosa reggia.',
    ));
    await _stageRepo.insert(Stage(
      id: d5, tripId: tripId, title: 'Giorno 5 — Champs-Élysées e Marais',
      date: DateTime(2026, 10, 31), location: 'Champs-Élysées, Parigi', order: 4,
      description: 'Shopping, Arco di Trionfo e quartiere del Marais.',
    ));

    // --- Giorno 1 ---
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d1,
      title: 'Volo per Parigi (CDG)',
      category: ActivityCategory.transport,
      dateTime: DateTime(2026, 10, 27, 9, 0),
      location: 'Aeroporto Charles de Gaulle',
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d1,
      title: 'Check-in in hotel',
      category: ActivityCategory.booking,
      dateTime: DateTime(2026, 10, 27, 13, 0),
      location: 'Hotel Le Marais',
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d1,
      title: 'Cattedrale di Notre-Dame (esterno)',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 10, 27, 16, 0),
      location: 'Parvis Notre-Dame',
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d1,
      title: 'Cena bistrot: cassoulet e vino',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 10, 27, 20, 0),
      location: 'Le Marais',
      estimatedCost: 40,
      status: ActivityStatus.todo,
    ));

    // --- Giorno 2 ---
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d2,
      title: 'Museo del Louvre',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 10, 28, 9, 30),
      location: 'Rue de Rivoli',
      estimatedCost: 22,
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d2,
      title: 'Pranzo ai Jardin des Tuileries',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 10, 28, 13, 0),
      location: 'Jardin des Tuileries',
      estimatedCost: 20,
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d2,
      title: 'Tour Eiffel (salita al 2° piano)',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 10, 28, 16, 0),
      location: 'Champ de Mars',
      estimatedCost: 28,
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d2,
      title: 'Crociera serale sulla Senna',
      category: ActivityCategory.excursion,
      dateTime: DateTime(2026, 10, 28, 19, 30),
      location: 'Port de la Bourdonnais',
      estimatedCost: 18,
      status: ActivityStatus.todo,
    ));

    // --- Giorno 3 ---
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d3,
      title: 'Basilica del Sacré-Cœur',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 10, 29, 10, 0),
      location: 'Montmartre',
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d3,
      title: 'Place du Tertre (pittori)',
      category: ActivityCategory.free,
      dateTime: DateTime(2026, 10, 29, 11, 30),
      location: 'Place du Tertre',
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d3,
      title: 'Pranzo: crêpe e cidre',
      category: ActivityCategory.meal,
      dateTime: DateTime(2026, 10, 29, 13, 30),
      location: 'Montmartre',
      estimatedCost: 16,
      status: ActivityStatus.todo,
    ));

    // --- Giorno 4 ---
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d4,
      title: 'Reggia di Versailles e giardini',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 10, 30, 10, 0),
      location: 'Versailles',
      estimatedCost: 21,
      status: ActivityStatus.todo,
    ));

    // --- Giorno 5 ---
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d5,
      title: 'Arco di Trionfo e Champs-Élysées',
      category: ActivityCategory.visit,
      dateTime: DateTime(2026, 10, 31, 10, 30),
      location: 'Place Charles de Gaulle',
      status: ActivityStatus.todo,
    ));
    await _actRepo.insert(Activity(
      id: _uuid.v4(), tripId: tripId, stageId: d5,
      title: 'Shopping e Centre Pompidou',
      category: ActivityCategory.free,
      dateTime: DateTime(2026, 10, 31, 15, 0),
      location: 'Le Marais',
      estimatedCost: 14,
      status: ActivityStatus.todo,
    ));

    // Checklist valigia (con sacchetti) e documenti.
    await _packingList(tripId, completed: false);
    final docId = _uuid.v4();
    await _clRepo.insertChecklist(Checklist(
      id: docId, tripId: tripId, title: 'Documenti e prenotazioni',
      description: 'Da controllare prima della partenza',
      items: [
        ChecklistItem(id: _uuid.v4(), checklistId: docId, title: 'Carta d\'identità valida', order: 0, isCompleted: true),
        ChecklistItem(id: _uuid.v4(), checklistId: docId, title: 'Biglietti aerei', order: 1, isCompleted: true),
        ChecklistItem(id: _uuid.v4(), checklistId: docId, title: 'Conferma hotel', order: 2),
        ChecklistItem(id: _uuid.v4(), checklistId: docId, title: 'Biglietti Louvre e Tour Eiffel', order: 3),
        ChecklistItem(id: _uuid.v4(), checklistId: docId, title: 'Tessera sanitaria europea', order: 4),
      ],
    ));

    // Spese previste (il viaggio non è ancora avvenuto).
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Voli A/R Napoli–Parigi',
      amount: 240, category: ExpenseCategory.transport,
      date: DateTime(2026, 10, 27), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.planned,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Hotel Le Marais (5 notti)',
      amount: 650, category: ExpenseCategory.accommodation,
      date: DateTime(2026, 10, 27), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.planned,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Musei e attrazioni',
      amount: 140, category: ExpenseCategory.activity,
      date: DateTime(2026, 10, 28), paymentMethod: PaymentMethod.card,
      status: ExpenseStatus.planned,
    ));
    await _expRepo.insert(Expense(
      id: _uuid.v4(), tripId: tripId, title: 'Pasti (stima)',
      amount: 250, category: ExpenseCategory.food,
      date: DateTime(2026, 10, 28), paymentMethod: PaymentMethod.cash,
      status: ExpenseStatus.planned,
    ));
  }

  // Crea una "Lista Valigia" di esempio con oggetti organizzati in sacchetti.
  // Per i viaggi conclusi gli oggetti risultano già spuntati.
  static Future<void> _packingList(String tripId,
      {required bool completed}) async {
    final clId = _uuid.v4();
    // Oggetti di esempio: (titolo, sacchetto).
    const items = [
      ('Magliette', 'Abbigliamento'),
      ('Pantaloni', 'Abbigliamento'),
      ('Scarpe comode', 'Abbigliamento'),
      ('Carta d\'identità', 'Documenti'),
      ('Biglietti di viaggio', 'Documenti'),
      ('Caricabatterie telefono', 'Elettronica'),
      ('Power bank', 'Elettronica'),
      ('Spazzolino e dentifricio', 'Igiene'),
      ('Farmaci personali', 'Medicinali'),
    ];
    await _clRepo.insertChecklist(Checklist(
      id: clId, tripId: tripId, title: 'Lista Valigia',
      description: 'Oggetti da portare in viaggio',
      items: [
        for (int i = 0; i < items.length; i++)
          ChecklistItem(
            id: _uuid.v4(),
            checklistId: clId,
            title: items[i].$1,
            category: items[i].$2,
            order: i,
            isCompleted: completed,
          ),
      ],
    ));
  }
}
