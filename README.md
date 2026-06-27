# 🧳 Travel Organizer Offline

Applicazione mobile in **Flutter** per organizzare viaggi, tappe, attività, checklist e spese — **funziona completamente offline**, senza alcuna connessione di rete né backend.

Progetto per il corso di **Mobile Programming** — Traccia #1: *Travel Organizer Offline App*.

---

## ✨ Funzionalità principali

| Area | Cosa puoi fare |
|------|----------------|
| 🧳 **Viaggi** | Crea, modifica, duplica ed elimina viaggi (con tag e **modalità di viaggio**: auto, aereo, treno, nave, crociera, bici…) |
| 🗺️ **Tappe** | Suddividi il viaggio in tappe/giornate, riordinabili con il *drag & drop* |
| 📍 **Attività** | Pianifica visite, pasti, spostamenti, eventi… con categoria, orario, luogo, costo e stato |
| ✅ **Checklist** | Liste di documenti e cose da fare, con avanzamento e duplicazione |
| 💰 **Spese** | Spese previste ed effettive, confronto con il budget, ritmo di spesa |
| ⏱️ **Timeline** | Linea del tempo dell'itinerario con blocchi colorati e tempi liberi |
| 📅 **Calendario** | Vista mensile con marker per viaggi e attività |
| 📊 **Statistiche** | Riepiloghi e grafici su tutti i viaggi |
| 🚨 **Emergenza** | Dati medici personali e numeri di emergenza del paese |

---

## 🚀 Feature avanzate

> La traccia richiede **almeno 2** feature avanzate: qui ne trovi **tante**, tutte integrate e funzionanti.

- 🎒 **Packing list intelligente con Tag e Sacchetti** — scegli i tag del viaggio (Mare, Montagna, Città, Estero, Business, Trekking, Inverno) e la lista valigia viene generata in automatico (*Mare → Costume, Crema solare*; *Estero → Passaporto, Adattatore*) e **organizzata in sacchetti** (Abbigliamento, Documenti, Elettronica…) ognuno con la sua barra di avanzamento.
- 📊 **Budget Gamification + ritmo di spesa** — barra "salute budget" 🟢→🟡→🔴, avviso quando una spesa sfora il budget e **calcolo del budget giornaliero ricalcolato** (*"stai spendendo il 66% più del previsto"*).
- ⏱️ **Timeline visuale con tempi liberi** — attività come blocchi colorati per categoria e badge *"Hai 3h di tempo libero"*.
- 📁 **Esporta / Importa viaggio (JSON + condivisione nativa)** — condividi un intero viaggio via menu di sistema e reimportalo su un altro dispositivo.
- 📅 **Calendario mensile interattivo** — marker su partenze, ritorni e attività; tocca un giorno per vederne gli eventi.
- 📑 **Diario di viaggio con foto** — per ogni attività scrivi un ricordo e allega una foto dalla galleria/fotocamera.
- ⏰ **Notifiche locali** — promemoria **30 minuti prima** di ogni attività con orario, anche ad app chiusa.
- 🚨 **Sezione "In caso di emergenza" (ICE)** — dati medici salvati in locale + numeri di emergenza dedotti dal paese di destinazione (112, 911, 110/119…).
- 🔍 **Ricerca globale "Spotlight"** — cerca in tempo reale tra viaggi, tappe, attività e spese, con risultati raggruppati.
- 🔁 **Duplicazione** di viaggi, tappe e checklist.

---

## 🧠 Integrità e coerenza dei dati

- 🚫 **Niente viaggi sovrapposti**: l'app impedisce di salvare due viaggi con date che si accavallano.
- 🔗 **Eliminazione a cascata**: cancellando un viaggio si rimuovono anche tappe, attività, checklist e spese, e le statistiche si aggiornano subito.
- 📅 Validazione delle date e dei campi obbligatori.
- 🗃️ **Database versionato** con migrazioni automatiche.

---

## 🧳 Viaggi di esempio

Al primo avvio l'app carica **4 viaggi completi** che mostrano tutte le funzionalità:

- 🇯🇵 **Tokyo**, 🇪🇸 **Barcellona**, 🇮🇹 **Roma** — viaggi *conclusi* con ricordi nel diario, spese effettive e checklist completate.
- 🇫🇷 **Parigi** — viaggio *in programma* (27 ott – 1 nov 2026) con **itinerario completo** di 5 giornate (Louvre, Tour Eiffel, Montmartre, Versailles…).

---

## 🛠️ Tecnologie

- **Flutter** (Material 3) · **Provider** (gestione stato)
- **sqflite** / `sqflite_common_ffi_web` — persistenza locale SQLite (anche su Web)
- **fl_chart** — grafici · **table_calendar** — calendario
- **image_picker** — foto del diario · **flutter_local_notifications** + **timezone** — promemoria
- **share_plus** — condivisione nativa · **intl** — date/valuta · **uuid** — ID

---

## 🏗️ Struttura del progetto

```
lib/
├── core/            # Tema, utility, cataloghi (packing, emergenza), notifiche
├── data/
│   ├── database/    # DatabaseHelper (schema + migrazioni)
│   ├── models/      # Trip, Stage, Activity, Checklist, Expense
│   ├── repositories/# Accesso ai dati (query SQL)
│   ├── seed/        # Viaggi di esempio
│   ├── trip_transfer.dart  # Esporta/Importa JSON
│   └── global_search.dart  # Ricerca globale
├── providers/       # Stato (ChangeNotifier)
├── features/        # Schermate (viaggi, calendario, emergenza, ricerca…)
├── shared/widgets/  # Widget riutilizzabili
└── main.dart
```

---

## ▶️ Come eseguire l'app

> Richiede **Flutter SDK** installato ([guida ufficiale](https://docs.flutter.dev/get-started/install)).

```bash
flutter pub get          # scarica le dipendenze
flutter run              # avvia su dispositivo/emulatore Android
# oppure
flutter run -d chrome    # avvia nel browser
```

### ✅ Eseguire i test

```bash
flutter test
```

---

## 📂 Persistenza

Tutti i dati sono salvati in un **database SQLite locale** sul dispositivo.
L'app **non usa API remote** e funziona interamente offline.

---

## 👥 Autori

Progetto realizzato per il corso di **Mobile Programming** — A.A. 2025/2026.
