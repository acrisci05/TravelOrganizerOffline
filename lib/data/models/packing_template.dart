// Modello di supporto alla feature avanzata "packing list per tipo di viaggio".
//
// A partire dal tipo di viaggio scelto dall'utente (mare, montagna, città,
// business, avventura, inverno) viene generata automaticamente una lista
// valigia composta da:
//   - un insieme di oggetti "base" comuni a qualsiasi viaggio;
//   - un insieme di oggetti specifici del tipo di viaggio selezionato.

/// Tipologie di viaggio previste per la generazione della packing list.
enum TripType { beach, mountain, city, business, adventure, winter }

extension TripTypeExtension on TripType {
  /// Etichetta leggibile mostrata nell'interfaccia.
  String get label {
    switch (this) {
      case TripType.beach:
        return 'Mare';
      case TripType.mountain:
        return 'Montagna';
      case TripType.city:
        return 'Città';
      case TripType.business:
        return 'Business';
      case TripType.adventure:
        return 'Avventura';
      case TripType.winter:
        return 'Inverno / Neve';
    }
  }

  /// Emoji rappresentativa del tipo di viaggio.
  String get icon {
    switch (this) {
      case TripType.beach:
        return '🏖️';
      case TripType.mountain:
        return '⛰️';
      case TripType.city:
        return '🏙️';
      case TripType.business:
        return '💼';
      case TripType.adventure:
        return '🎒';
      case TripType.winter:
        return '❄️';
    }
  }

  /// Oggetti specifici del tipo di viaggio, aggiunti a quelli di base.
  List<String> get specificItems {
    switch (this) {
      case TripType.beach:
        return const [
          '👙 Costume da bagno',
          '🩴 Infradito',
          '🏖️ Telo mare',
          '☀️ Crema solare',
          '🕶️ Occhiali da sole',
          '🧢 Cappello',
          '🤿 Maschera da snorkeling',
        ];
      case TripType.mountain:
        return const [
          '🥾 Scarponi da trekking',
          '🧥 Giacca a vento',
          '🎒 Zaino da escursione',
          '🚰 Borraccia',
          '🩹 Kit pronto soccorso',
          '🧦 Calze tecniche',
          '🗺️ Mappa dei sentieri',
        ];
      case TripType.city:
        return const [
          '👟 Scarpe comode',
          '📷 Fotocamera',
          '🎒 Zainetto',
          '☂️ Ombrello',
          '🗺️ Guida turistica',
          '🔋 Power bank',
        ];
      case TripType.business:
        return const [
          '👔 Abito / completo',
          '👞 Scarpe eleganti',
          '💻 Laptop',
          '📄 Documenti di lavoro',
          '🪪 Biglietti da visita',
          '🔌 Caricabatterie laptop',
        ];
      case TripType.adventure:
        return const [
          '🎒 Zaino capiente',
          '🔦 Torcia frontale',
          '🧭 Bussola',
          '🔋 Power bank',
          '🩹 Kit pronto soccorso',
          '🚰 Borraccia',
          '🔪 Coltellino multiuso',
        ];
      case TripType.winter:
        return const [
          '🧥 Giacca invernale',
          '🧤 Guanti',
          '🧣 Sciarpa',
          '🎿 Abbigliamento termico',
          '👢 Doposci',
          '🧴 Crema idratante',
          '🕶️ Occhiali da neve',
        ];
    }
  }

  /// Lista valigia completa: oggetti di base + oggetti specifici del tipo.
  List<String> buildPackingList() => [
        ...PackingTemplate.baseItems,
        ...specificItems,
      ];
}

/// Contenitore per gli oggetti di base validi per qualsiasi viaggio.
class PackingTemplate {
  const PackingTemplate._();

  /// Oggetti essenziali comuni a tutti i tipi di viaggio.
  static const List<String> baseItems = [
    '🛂 Documenti (carta d\'identità / passaporto)',
    '🎫 Biglietti di viaggio',
    '💳 Carte e contanti',
    '📱 Telefono e caricabatterie',
    '🩲 Biancheria intima',
    '🧦 Calzini',
    '😴 Pigiama',
    '👕 T-shirt',
    '🪥 Spazzolino e dentifricio',
    '🧴 Prodotti da bagno',
    '💊 Farmaci personali',
  ];
}
