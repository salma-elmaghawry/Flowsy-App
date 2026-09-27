/// Hours of the day (24h, local time) when the spending reminder fires.
const List<int> reminderHours = [17, 21];

/// How many days ahead reminders are queued. If the app is not opened for
/// this long, reminders stop by themselves instead of nagging forever.
const int reminderDaysAhead = 7;

/// The reminder times to schedule when the app is opened at [now].
///
/// Opening the app counts as "checked in today", so today's reminders are
/// skipped and the list always starts tomorrow.
List<DateTime> upcomingReminderTimes(
  DateTime now, {
  int days = reminderDaysAhead,
  List<int> hours = reminderHours,
}) {
  return [
    for (var day = 1; day <= days; day++)
      for (final hour in hours)
        DateTime(now.year, now.month, now.day + day, hour),
  ];
}
