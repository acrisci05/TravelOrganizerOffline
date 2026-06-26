// Catalogo dei tag di viaggio e dei relativi oggetti suggeriti per la valigia.
// È una "matrice" predefinita e completamente offline: in base ai tag scelti per
// il viaggio (es. Mare, Estero) la lista valigia viene arricchita con gli oggetti
// più adatti, senza bisogno di alcuna connessione o servizio esterno.
class PackingCatalog {
  // Tag disponibili per caratterizzare un viaggio.
  static const List<String> tags = [
    'Mare',
    'Montagna',
    'Città',
    'Estero',
    'Business',
    'Trekking',
    'Inverno',
  ];

  // Oggetti suggeriti per ciascun tag (logica 100% locale).
  static const Map<String, List<String>> byTag = {
    'Mare': [
      'Costume da bagno',
      'Crema solare',
      'Telo mare',
      'Infradito',
      'Occhiali da sole',
    ],
    'Montagna': [
      'Scarponi da trekking',
      'Giacca a vento',
      'Borraccia',
      'Pile termico',
    ],
    'Città': [
      'Scarpe comode',
      'Guida turistica',
      'Power bank',
      'Borsa a tracolla',
    ],
    'Estero': [
      'Passaporto',
      'Adattatore prese',
      'Valuta locale',
      'Documenti assicurazione',
    ],
    'Business': [
      'Abito formale',
      'Laptop',
      'Caricabatterie laptop',
      'Biglietti da visita',
    ],
    'Trekking': [
      'Zaino da escursione',
      'Kit pronto soccorso',
      'Bastoncini da trekking',
      'Snack energetici',
    ],
    'Inverno': [
      'Giacca pesante',
      'Guanti',
      'Sciarpa',
      'Berretto',
      'Calze termiche',
    ],
  };

  // Restituisce gli oggetti suggeriti per i tag indicati, senza duplicati,
  // mantenendo l'ordine dei tag selezionati.
  static List<String> suggestionsFor(List<String> tripTags) {
    final result = <String>[];
    for (final tag in tripTags) {
      for (final item in byTag[tag] ?? const <String>[]) {
        if (!result.contains(item)) result.add(item);
      }
    }
    return result;
  }
}
