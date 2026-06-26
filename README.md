# 🧳 Travel Organizer Offline

Applicazione mobile in **Flutter** per organizzare viaggi, tappe, attività, checklist e spese — **funziona completamente offline**, senza alcuna connessione di rete né backend.

Progetto per il corso di **Mobile Programming** — Traccia #1: *Travel Organizer Offline App*.

---

## ✨ Funzionalità principali

| Area | Cosa puoi fare |
|------|----------------|
| 🧳 **Viaggi** | Crea, modifica, duplica ed elimina viaggi (titolo, destinazione, date, budget, partecipanti, note, stato e tag) |
| 🗺️ **Tappe** | Suddividi il viaggio in tappe/giornate, riordinabili con il *drag & drop* |
| 📍 **Attività** | Pianifica visite, pasti, spostamenti, eventi… con categoria, orario, luogo, costo e stato |
| ✅ **Checklist** | Liste di documenti e cose da fare, con avanzamento e duplicazione |
| 💰 **Spese** | Spese previste ed effettive, metodo di pagamento, confronto con il budget |
| ⏱️ **Timeline** | Linea del tempo dell'itinerario con blocchi colorati per categoria |
| 📊 **Statistiche** | Riepiloghi e grafici su tutti i viaggi |

---

## 🚀 Feature avanzate

> La traccia richiede **almeno 2** feature avanzate: qui ne trovi **diverse**, tutte integrate e funzionanti.

- 🎒 **Packing List intelligente con Tag** — scegliendo i tag del viaggio (Mare, Montagna, Città, Estero, Business, Trekking, Inverno) la lista valigia viene generata in automatico con gli oggetti più adatti (es. *Mare → Costume, Crema solare*; *Estero → Passaporto, Adattatore prese*). Tutta la logica è una matrice predefinita **100% offline**.
- 📊 **Budget Gamification** — barra "salute del budget" che cambia colore 🟢 → 🟡 → 🔴 man mano che le spese si avvicinano al budget, con avviso quando una spesa lo supera.
- ⏱️ **Timeline visuale con tempi liberi** — le attività diventano blocchi colorati per categoria e l'app calcola i "buchi" liberi (*"Hai 3h di tempo libero"*).
- 📁 **Esporta / Importa viaggio (JSON + condivisione nativa)** — condividi un intero viaggio tramite il menu di sistema (WhatsApp, email, ecc.) e reimportalo su un altro dispositivo. ID rigenerati per non creare conflitti.
- 🔁 **Duplicazione** di viaggi, tappe e checklist.

---

## 🧠 Integrità e coerenza dei dati

- 🚫 **Niente viaggi sovrapposti**: l'app impedisce di salvare due viaggi con date che si accavallano.
- 🔗 **Eliminazione a cascata**: cancellando un viaggio vengono rimossi anche tappe, attività, checklist e spese collegate, e le statistiche si aggiornano subito.
- 📅 Validazione delle date (la fine non può precedere l'inizio) e dei campi obbligatori.

---

## 🔍 Ricerca, filtri e organizzazione

- 🔎 Ricerca viaggi per **titolo/destinazione** e filtro per **stato**.
- 🏷️ Filtri attività per **categoria, stato e giorno**.
- 💶 Filtri spese per **stato, categoria e importo** (min/max).
- 🗓️ Ricerca tappe per **nome/località** e filtro per **data**.

---

## 🛠️ Tecnologie

- **Flutter** (Material 3)
- **Provider** — gestione dello stato
- **sqflite** / `sqflite_common_ffi_web` — persistenza locale con SQLite (anche su Web via WebAssembly)
- **fl_chart** — grafici delle statistiche
- **intl** — formattazione di date e valuta in italiano
- **share_plus** — condivisione tramite il menu nativo
- **uuid** — generazione degli identificatori

---

## 🏗️ Architettura del progetto

Struttura a livelli (UI → Provider → Repository → Database):

```
lib/
├── core/            # Tema, colori, utility, catalogo packing
├── data/
│   ├── database/    # DatabaseHelper (SQLite, schema, migrazioni)
│   ├── models/      # Trip, Stage, Activity, Checklist, Expense…
│   ├── repositories/# Accesso ai dati (query SQL)
│   └── trip_transfer.dart  # Esporta/Importa viaggio in JSON
├── providers/       # Gestione dello stato (ChangeNotifier)
├── features/        # Schermate (viaggi, tappe, attività, spese…)
├── shared/widgets/  # Widget riutilizzabili
└── main.dart        # Avvio dell'app
```

---

## ▶️ Come eseguire l'app

> Richiede **Flutter SDK** installato ([guida ufficiale](https://docs.flutter.dev/get-started/install)).

```bash
# 1. Scarica le dipendenze
flutter pub get

# 2. Avvia su un dispositivo/emulatore Android
flutter run

# 3. Oppure avvia nel browser (Chrome)
flutter run -d chrome
```

L'app parte con un **archivio vuoto**: aggiungi il tuo primo viaggio con il pulsante **➕**.

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
