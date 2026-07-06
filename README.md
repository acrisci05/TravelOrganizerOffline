# Travel Organizer Offline

Applicazione mobile sviluppata in **Flutter** per la pianificazione e la gestione
**completamente offline** di viaggi, itinerari, tappe, attività, checklist e spese.

Il progetto è stato realizzato per l'esame di *Mobile Programming* (A.A. 2025/2026)
seguendo la traccia *"Travel Organizer Offline App"*.

---

## Funzionalità principali

- **Gestione dei viaggi**: creazione, modifica, eliminazione e consultazione del
  dettaglio di ogni viaggio (titolo, destinazione, date, budget, partecipanti, note,
  stato calcolato automaticamente: futuro, in corso, completato, archiviato).
- **Tappe / giornate**: organizzazione del viaggio in tappe ordinabili (drag & drop),
  ciascuna con data, località, descrizione e note.
- **Attività / itinerario**: pianificazione delle attività (visite, escursioni, pasti,
  trasporti, prenotazioni…) associate al viaggio e/o a una tappa, con categoria,
  data/ora, luogo, costo previsto e stato (da fare, completata, annullata).
- **Checklist**: liste di controllo con elementi spuntabili e barra di avanzamento.
- **Spese**: registrazione delle spese previste ed effettive con categoria, importo,
  metodo di pagamento e confronto con il budget del viaggio.
- **Ricerca, filtri e ordinamento**: ricerca viaggi per titolo/destinazione, filtri per
  stato, categoria, data e importo, ordinamento delle tappe.
- **Riepiloghi e statistiche**: dashboard con totali, conteggi per stato, grafico a
  torta delle spese per categoria, confronto budget/spese e classifica delle tappe con
  più attività.

## Feature avanzate

1. **Duplicazione completa del viaggio**: copia un viaggio con tutte le sue tappe,
   attività e checklist (con rimappatura corretta delle associazioni tappa↔attività).
2. **Packing list per tipo di viaggio**: generazione automatica della lista valigia in
   base al tipo di viaggio scelto dall'utente (mare, montagna, città, business,
   avventura, inverno).
3. **Timeline dell'itinerario**: vista cronologica di tappe e attività del viaggio.

---

## Requisiti

- Flutter SDK **3.44+** (Dart 3.11+)
- Un dispositivo/emulatore Android, oppure supporto Web/desktop

## Esecuzione

```bash
flutter pub get
flutter run
```

Al primo avvio, se il database locale è vuoto, l'app viene popolata con alcuni dati di
esempio (tre viaggi con relative tappe, attività, checklist e spese).

---

## Architettura

Il progetto adopera un'architettura a livelli con separazione delle responsabilità:

```
lib/
├── core/          # tema, colori e utility (formattazione date/valuta)
├── data/
│   ├── models/        # modelli di dominio (Trip, Stage, Activity, Checklist, Expense…)
│   ├── database/      # DatabaseHelper (SQLite, schema, indici)
│   ├── repositories/  # accesso ai dati (una repository per entità)
│   └── seed/          # dati demo iniziali
├── providers/     # gestione dello stato (ChangeNotifier + Provider)
├── features/      # schermate raggruppate per funzionalità
└── shared/        # widget riutilizzabili (dialog, empty state, chip di stato)
```

- **Persistenza**: database locale **SQLite** tramite `sqflite`
  (`sqflite_common_ffi_web` per l'esecuzione su Web).
- **Gestione dello stato**: pattern **Provider** con `ChangeNotifier`.
- **Navigazione**: `Navigator` con `MaterialPageRoute` e passaggio esplicito dei dati
  tra schermate; navigazione a tab all'interno del dettaglio viaggio.

## Librerie principali

| Libreria | Utilizzo |
|----------|----------|
| `provider` | gestione dello stato |
| `sqflite` / `sqflite_common_ffi_web` | persistenza locale |
| `uuid` | generazione identificatori univoci |
| `intl` | formattazione di date e valuta in italiano |
| `fl_chart` | grafici nella dashboard statistiche |

---

## Documentazione

La relazione tecnica completa è disponibile nella cartella [`docs/`](docs/) in formato
LaTeX (`relazione.tex`).
