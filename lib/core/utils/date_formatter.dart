import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'it_IT');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'it_IT');
  static final _monthYear = DateFormat('MMMM yyyy', 'it_IT');
  static final _dayMonth = DateFormat('d MMM', 'it_IT');
  static final _timeFormat = DateFormat('HH:mm', 'it_IT');
  static final _currencyFormat =
      NumberFormat.currency(locale: 'it_IT', symbol: '€');

  static String date(DateTime dt) => _dateFormat.format(dt);
  static String dateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String monthYear(DateTime dt) => _monthYear.format(dt);
  static String dayMonth(DateTime dt) => _dayMonth.format(dt);
  static String time(DateTime dt) => _timeFormat.format(dt);
  static String currency(double amount) => _currencyFormat.format(amount);

  static String dateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${end.day} ${DateFormat('MMM yyyy', 'it_IT').format(start)}';
    }
    return '${_dayMonth.format(start)} – ${_dayMonth.format(end)} ${end.year}';
  }

  static String daysFromNow(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Oggi';
    if (diff == 1) return 'Domani';
    if (diff == -1) return 'Ieri';
    if (diff > 0) return 'Tra $diff giorni';
    return '${-diff} giorni fa';
  }
}
