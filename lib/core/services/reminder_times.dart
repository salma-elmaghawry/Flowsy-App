/// A time of day (local, 24h) when the spending reminder fires.
class ReminderTime implements Comparable<ReminderTime> {
  final int hour;
  final int minute;

  const ReminderTime(this.hour, this.minute);

  int get _minutes => hour * 60 + minute;

  /// Stored as "HH:mm" in shared preferences.
  String encode() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Returns null for anything that is not a valid "HH:mm" value.
  static ReminderTime? tryDecode(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return ReminderTime(h, m);
  }

  @override
  int compareTo(ReminderTime other) => _minutes.compareTo(other._minutes);

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other._minutes == _minutes;

  @override
  int get hashCode => _minutes;

  @override
  String toString() => encode();
}

/// Used until the user picks their own times.
const List<ReminderTime> defaultReminderTimes = [
  ReminderTime(17, 0),
  ReminderTime(21, 0),
];

/// Most reminders a user can set per day.
const int maxReminderTimes = 4;

/// How many motivational messages exist under `reminders.messages` in the
/// translation files. Keep in sync with en.json and ar.json.
const int reminderMessageCount = 14;

/// Sorts [times] and drops duplicates.
List<ReminderTime> normalizeReminderTimes(Iterable<ReminderTime> times) =>
    (times.toSet().toList()..sort());

/// One repeating reminder: it first fires at [firstFire], then again at the
/// same weekday and time every week, with the message at [messageIndex].
class WeeklyReminder {
  final int id;
  final DateTime firstFire;
  final int messageIndex;

  const WeeklyReminder({
    required this.id,
    required this.firstFire,
    required this.messageIndex,
  });
}

/// One weekly repeating reminder per weekday and picked time.
///
/// They repeat on their own, so the user keeps getting them every day even
/// if they never open the app. Each weekday and time gets its own message,
/// so the text changes from one reminder to the next.
List<WeeklyReminder> weeklyReminderSchedule(
  DateTime now, {
  List<ReminderTime> times = defaultReminderTimes,
  int messageCount = reminderMessageCount,
}) {
  final sorted = normalizeReminderTimes(times);
  final result = <WeeklyReminder>[];
  for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
    final daysAhead = (weekday - now.weekday) % 7;
    for (final t in sorted) {
      var fire = DateTime(
        now.year,
        now.month,
        now.day + daysAhead,
        t.hour,
        t.minute,
      );
      if (!fire.isAfter(now)) {
        fire = DateTime(fire.year, fire.month, fire.day + 7, t.hour, t.minute);
      }
      final id = result.length;
      result.add(
        WeeklyReminder(
          id: id,
          firstFire: fire,
          messageIndex: id % messageCount,
        ),
      );
    }
  }
  return result;
}
