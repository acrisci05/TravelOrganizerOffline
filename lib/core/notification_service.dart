import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/models/activity.dart';

// Servizio di notifiche locali: programma un promemoria 30 minuti prima di
// un'attività con orario, sfruttando le API native del sistema operativo (quindi
// senza alcun server). Le notifiche restano programmate anche ad app chiusa.
//
// Tutte le operazioni sono protette: su Web o se l'inizializzazione fallisce, i
// metodi non fanno nulla, così l'app continua a funzionare ovunque.
class NotificationService {
  // Singleton: un'unica istanza condivisa in tutta l'app.
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Minuti di anticipo del promemoria rispetto all'inizio dell'attività.
  static const int reminderMinutesBefore = 30;

  // Inizializza il plugin, i fusi orari e chiede i permessi. Va chiamato
  // all'avvio dell'app (in main). Su Web non fa nulla.
  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    try {
      tz.initializeTimeZones();
      // Per semplicità si usa il fuso orario italiano (l'app è pensata per l'Italia).
      tz.setLocalLocation(tz.getLocation('Europe/Rome'));

      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      // Richiede il permesso di inviare notifiche (Android 13+ / iOS).
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _initialized = true;
    } catch (_) {
      // Su piattaforme non supportate l'app prosegue senza notifiche.
      _initialized = false;
    }
  }

  // Genera un id di notifica stabile (32 bit) a partire dall'id dell'attività.
  int _idFor(String activityId) => activityId.hashCode & 0x7fffffff;

  // Programma (o riprogramma) il promemoria per un'attività. Se l'attività non
  // ha orario, o l'orario del promemoria è già passato, non programma nulla.
  Future<void> scheduleActivityReminder(Activity activity) async {
    if (!_initialized || activity.dateTime == null) return;
    try {
      // Cancella un eventuale promemoria precedente per la stessa attività.
      await _plugin.cancel(_idFor(activity.id));

      final when = activity.dateTime!
          .subtract(const Duration(minutes: reminderMinutesBefore));
      if (when.isBefore(DateTime.now())) return; // troppo tardi

      final scheduled = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        _idFor(activity.id),
        'Promemoria attività',
        '${activity.title} tra $reminderMinutesBefore minuti',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'activity_reminders',
            'Promemoria attività',
            channelDescription:
                'Promemoria per le attività pianificate del viaggio',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Ignora eventuali errori di programmazione: non devono bloccare l'app.
    }
  }

  // Annulla il promemoria associato a un'attività (es. quando viene eliminata).
  Future<void> cancelActivityReminder(String activityId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_idFor(activityId));
    } catch (_) {
      // Ignora eventuali errori.
    }
  }
}
