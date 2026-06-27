import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/activity.dart';
import '../../providers/trip_provider.dart';
import '../../providers/activity_provider.dart';
import '../trips/trip_detail_screen.dart';

// Evento mostrato nel calendario: può rappresentare l'inizio/fine di un viaggio
// oppure un'attività pianificata in un certo giorno.
class _CalendarEvent {
  final String title;
  final String tripId;
  final Color color;
  final IconData icon;
  _CalendarEvent({
    required this.title,
    required this.tripId,
    required this.color,
    required this.icon,
  });
}

// Schermata "Calendario": vista mensile con marker per i viaggi (partenza e
// ritorno) e per le attività pianificate. Toccando un giorno si vedono gli
// eventi di quella data e si può aprire il viaggio collegato.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  // Carica i viaggi (se necessario) e le attività di tutti i viaggi.
  Future<void> _load() async {
    if (!mounted) return;
    final tripProvider = context.read<TripProvider>();
    if (tripProvider.trips.isEmpty) await tripProvider.loadTrips();
    if (!mounted) return;
    final actProvider = context.read<ActivityProvider>();
    for (final t in tripProvider.trips) {
      await actProvider.loadForTrip(t.id);
    }
  }

  // Normalizza una data a mezzanotte (chiave della mappa degli eventi).
  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  // Costruisce la mappa giorno -> eventi a partire da viaggi e attività.
  Map<DateTime, List<_CalendarEvent>> _buildEvents(
      TripProvider tripProvider, ActivityProvider actProvider) {
    final map = <DateTime, List<_CalendarEvent>>{};
    void add(DateTime day, _CalendarEvent e) {
      (map[_dayKey(day)] ??= []).add(e);
    }

    for (final trip in tripProvider.trips) {
      // Marker di partenza e ritorno del viaggio.
      add(trip.startDate, _CalendarEvent(
        title: 'Partenza: ${trip.title}',
        tripId: trip.id,
        color: AppColors.primary,
        icon: Icons.flight_takeoff,
      ));
      if (_dayKey(trip.endDate) != _dayKey(trip.startDate)) {
        add(trip.endDate, _CalendarEvent(
          title: 'Ritorno: ${trip.title}',
          tripId: trip.id,
          color: AppColors.accent,
          icon: Icons.flight_land,
        ));
      }
      // Attività con data/ora.
      for (final a in actProvider.getByTrip(trip.id)) {
        if (a.dateTime != null) {
          add(a.dateTime!, _CalendarEvent(
            title: a.title,
            tripId: trip.id,
            color: a.category.color,
            icon: a.category.icon,
          ));
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final actProvider = context.watch<ActivityProvider>();
    final events = _buildEvents(tripProvider, actProvider);

    List<_CalendarEvent> eventsFor(DateTime day) =>
        events[_dayKey(day)] ?? [];

    final selectedEvents =
        _selectedDay != null ? eventsFor(_selectedDay!) : <_CalendarEvent>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar<_CalendarEvent>(
              locale: 'it_IT',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) =>
                  _selectedDay != null && isSameDay(_selectedDay, d),
              eventLoader: eventsFor,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mese',
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 4,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
            ),
          ),
          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(
                    child: Text(
                      'Nessun evento in questo giorno',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                        child: Text(
                          DateFormatter.date(_selectedDay!),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ),
                      ...selectedEvents.map((e) => Card(
                            child: ListTile(
                              leading: Icon(e.icon, color: e.color),
                              title: Text(e.title),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TripDetailScreen(tripId: e.tripId),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
