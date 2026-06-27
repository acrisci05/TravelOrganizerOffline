// Catalogo dei tag di viaggio e dei relativi oggetti suggeriti per la valigia.
// È una "matrice" predefinita e completamente offline: in base ai tag scelti per
// il viaggio (es. Mare, Estero) la lista valigia viene arricchita con gli oggetti
// più adatti, senza bisogno di alcuna connessione o servizio esterno.
//
// Ogni oggetto è associato a un "sacchetto" (bag): un raggruppamento logico
// (Abbigliamento, Documenti, Elettronica, ...) usato per organizzare la valigia
// in sotto-liste con barra di avanzamento per ciascun sacchetto.

// Oggetto da mettere in valigia, con il sacchetto di appartenenza.
class PackingItem {
  final String name;
  final String bag;
  const PackingItem(this.name, this.bag);
}

class PackingCatalog {
  // Sacchetti (categorie) standard della valigia.
  static const String bagAbbigliamento = 'Abbigliamento';
  static const String bagDocumenti = 'Documenti';
  static const String bagElettronica = 'Elettronica';
  static const String bagIgiene = 'Igiene';
  static const String bagMedicinali = 'Medicinali';
  static const String bagVarie = 'Varie';

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

  // Oggetti di base proposti per ogni viaggio, già suddivisi per sacchetto.
  static const List<PackingItem> baseItems = [
    PackingItem('T-shirt', bagAbbigliamento),
    PackingItem('Pantaloni', bagAbbigliamento),
    PackingItem('Scarpe', bagAbbigliamento),
    PackingItem('Giacca / Maglione', bagAbbigliamento),
    PackingItem('Biancheria intima', bagAbbigliamento),
    PackingItem('Calzini', bagAbbigliamento),
    PackingItem('Pigiama', bagAbbigliamento),
    PackingItem('Carta d\'identità', bagDocumenti),
    PackingItem('Biglietti di viaggio', bagDocumenti),
    PackingItem('Assicurazione viaggio', bagDocumenti),
    PackingItem('Conferme prenotazioni', bagDocumenti),
    PackingItem('Caricabatterie telefono', bagElettronica),
    PackingItem('Power bank', bagElettronica),
    PackingItem('Cuffie', bagElettronica),
    PackingItem('Adattatore presa', bagElettronica),
    PackingItem('Fotocamera', bagElettronica),
    PackingItem('Spazzolino e dentifricio', bagIgiene),
    PackingItem('Shampoo e balsamo', bagIgiene),
    PackingItem('Sapone / Gel doccia', bagIgiene),
    PackingItem('Deodorante', bagIgiene),
    PackingItem('Farmaci personali', bagMedicinali),
    PackingItem('Kit pronto soccorso', bagMedicinali),
    PackingItem('Crema solare', bagVarie),
    PackingItem('Occhiali da sole', bagVarie),
    PackingItem('Ombrello', bagVarie),
  ];

  // Oggetti suggeriti per ciascun tag (logica 100% locale), già con sacchetto.
  static const Map<String, List<PackingItem>> byTag = {
    'Mare': [
      PackingItem('Costume da bagno', bagAbbigliamento),
      PackingItem('Crema solare', bagVarie),
      PackingItem('Telo mare', bagVarie),
      PackingItem('Infradito', bagAbbigliamento),
      PackingItem('Occhiali da sole', bagVarie),
    ],
    'Montagna': [
      PackingItem('Scarponi da trekking', bagAbbigliamento),
      PackingItem('Giacca a vento', bagAbbigliamento),
      PackingItem('Borraccia', bagVarie),
      PackingItem('Pile termico', bagAbbigliamento),
    ],
    'Città': [
      PackingItem('Scarpe comode', bagAbbigliamento),
      PackingItem('Guida turistica', bagVarie),
      PackingItem('Power bank', bagElettronica),
      PackingItem('Borsa a tracolla', bagVarie),
    ],
    'Estero': [
      PackingItem('Passaporto', bagDocumenti),
      PackingItem('Adattatore prese', bagElettronica),
      PackingItem('Valuta locale', bagDocumenti),
      PackingItem('Documenti assicurazione', bagDocumenti),
    ],
    'Business': [
      PackingItem('Abito formale', bagAbbigliamento),
      PackingItem('Laptop', bagElettronica),
      PackingItem('Caricabatterie laptop', bagElettronica),
      PackingItem('Biglietti da visita', bagDocumenti),
    ],
    'Trekking': [
      PackingItem('Zaino da escursione', bagVarie),
      PackingItem('Kit pronto soccorso', bagMedicinali),
      PackingItem('Bastoncini da trekking', bagVarie),
      PackingItem('Snack energetici', bagVarie),
    ],
    'Inverno': [
      PackingItem('Giacca pesante', bagAbbigliamento),
      PackingItem('Guanti', bagAbbigliamento),
      PackingItem('Sciarpa', bagAbbigliamento),
      PackingItem('Berretto', bagAbbigliamento),
      PackingItem('Calze termiche', bagAbbigliamento),
    ],
  };

  // Restituisce gli oggetti suggeriti per i tag indicati, senza duplicati di nome.
  static List<PackingItem> suggestionsFor(List<String> tripTags) {
    final result = <PackingItem>[];
    final seen = <String>{};
    for (final tag in tripTags) {
      for (final item in byTag[tag] ?? const <PackingItem>[]) {
        if (seen.add(item.name)) result.add(item);
      }
    }
    return result;
  }
}
