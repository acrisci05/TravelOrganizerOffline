// Dizionario interno (offline) dei numeri di emergenza per paese e logica per
// dedurre il paese a partire dal testo della destinazione di un viaggio.
// È pensato per la sezione "In caso di emergenza" (ICE), consultabile anche
// completamente offline e senza alcun servizio esterno.

// Singolo numero di emergenza con etichetta.
class EmergencyNumber {
  final String label;
  final String number;
  const EmergencyNumber(this.label, this.number);
}

class EmergencyCatalog {
  // Numeri di emergenza standard per paese/area.
  static const Map<String, List<EmergencyNumber>> byCountry = {
    'Italia': [
      EmergencyNumber('Numero unico emergenze', '112'),
      EmergencyNumber('Polizia', '113'),
      EmergencyNumber('Ambulanza', '118'),
      EmergencyNumber('Vigili del fuoco', '115'),
    ],
    'Europa (UE)': [
      EmergencyNumber('Numero unico europeo', '112'),
    ],
    'Francia': [
      EmergencyNumber('Numero unico europeo', '112'),
      EmergencyNumber('SAMU (medico)', '15'),
      EmergencyNumber('Polizia', '17'),
      EmergencyNumber('Pompieri', '18'),
    ],
    'Spagna': [
      EmergencyNumber('Numero unico emergenze', '112'),
    ],
    'Regno Unito': [
      EmergencyNumber('Emergenze', '999'),
      EmergencyNumber('Alternativo europeo', '112'),
    ],
    'Stati Uniti': [
      EmergencyNumber('Emergenze (police/fire/medical)', '911'),
    ],
    'Giappone': [
      EmergencyNumber('Polizia', '110'),
      EmergencyNumber('Ambulanza e pompieri', '119'),
    ],
    'Australia': [
      EmergencyNumber('Emergenze', '000'),
    ],
  };

  // Parole chiave (paese o città) che permettono di dedurre il paese.
  static const Map<String, List<String>> _keywords = {
    'Italia': ['italia', 'roma', 'napoli', 'milano', 'firenze', 'venezia'],
    'Francia': ['francia', 'parigi', 'paris', 'lione', 'nizza'],
    'Spagna': ['spagna', 'barcellona', 'madrid', 'siviglia', 'valencia'],
    'Regno Unito': ['regno unito', 'londra', 'london', 'inghilterra', 'uk'],
    'Stati Uniti': ['stati uniti', 'usa', 'new york', 'los angeles', 'miami'],
    'Giappone': ['giappone', 'tokyo', 'kyoto', 'osaka'],
    'Australia': ['australia', 'sydney', 'melbourne'],
  };

  // Elenco dei paesi disponibili nel dizionario (per il selettore).
  static List<String> get countries => byCountry.keys.toList();

  // Deduce il paese dal testo della destinazione (es. "Parigi, Francia").
  // Restituisce null se non riconosciuto.
  static String? detectCountry(String destination) {
    final d = destination.toLowerCase();
    for (final entry in _keywords.entries) {
      for (final kw in entry.value) {
        if (d.contains(kw)) return entry.key;
      }
    }
    return null;
  }
}
