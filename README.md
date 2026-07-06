## ProgettoMobilePrivato
# To-do list:
1. Controllare perché il bilancio delle spese totali non risulta, non conta il costo delle attività
2. ✔️ Controllare lo stato del viaggio (Archiviato, In corso, Futuro e Passato)
    - l'Errore stava nel trips_list_screen.dart che non prendeva il valore di status ma di computedstatus. Controllare bene poi il funzionamento
3. ✔️Controllare l'ordinamento dei viaggi (1: in corso, 2: Futuro, 3:Passato/Archiviato)
    - Modifica in trips_lsit_screen e trip_provider
4. ✔️Cambiare il colore delle cards in base allo stato (che viene calcolato ogni volta che viene caricata la schermata dei viaggi)
    controllare anche il filtro per data in modo che facci aselezionare solo le date del viaggio
    - Modifica trips/trip_form_screen.dart
7. ✔️Visualizzare gli archiviati a parte
    - Modifica di trips_list_screen.dart e trip_provider.dart
8. ✔️Si possono aggiungere spese in negativo alle singole trips, alle attività
    - Ho modificato feature/expenses/expense_form_screen.dart, feature/activities/activity_form_screen.dart
9. ✔️Controllare il segmento valigia perché utilizza AI per generare una valigia
    - non usa AI ma un array popolato dai vari oggetti
10. ✔️Le checklist devono apparire chiuse e si aprono al touch della lista
    - Ho modificato features/checklists/checklists_screen.dart
11. ✔️Se la checklist "🧳 Valigia " esiste, deve scomparire il pulsante "Genera valigia"
    - Ho modificato packing/packing_list_screen.dart
12. ❌Gli elementi della valigia generata deve essere forse più corta
13. Le spese delle attività non compaiono nelle spese totali delle statistics
14. ✔️Nei viaggi si possono mettere date prima di oggi sia alla modifica che alla creazione
    - esce un messaggio di conferma, ho modificato trips_lsit+screen, trip_form_scree, e app_colors
15. ✔️Nelle tappe va fatto un controllo sulla data scelta in modo che sia contenuta all'interno del viaggio
    - Ho modificato stage_form_screen.dart
16. ✔️Le timeline risultano aperte e dovrebbero FORSE essere chiuse di default come le checklists
    - Ho modificato timeline_screen.dart
17. ✔️Date picker del filtro deve essere compreso tra data di inizio e data di fine del trip
    - Ho cambiato activity_form_screen.dart
18. ❌Quando non si sceglie la data dellá ttivitàq va presa la data della tappa associata (se c'è)
    - Ripensandoci si può anche non scegliere la data, bisogna però che la data dell'attività scelta
19. ✔️Aggiustato l'ordine delle tappe nel loro ordine vero piuttosto che alfabetico
    - Ho modificato stages_tab.dart
20. ✔️Timeline deve essere sempre ordinata per data e basta
    - Ho cambiato timeline_screen.dart
21. ✔️Le attività possono essere filtrate per data oppure possono essere ordinate per nome, priorità o data. Il dato filtra per data è presente all'interno del pulsante con icona affianco alla searchbar
    - Ho cambiato stage_tab.dart
22. ✔️Le attività adesso possono cambiare tappa associata e data/ora
    - activity_form_screen.dart, activity.dart
23. Le attività checckate e con un prezzo devono contribuire alle spese effettive, eventualmente devo aggiungere un'altra riga alla sezione delle statistiche totali
24. Fare in modo che il tag si aggiorni automaticamente come lo sfondo delle carte dei viaggi