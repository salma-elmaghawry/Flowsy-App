import 'package:flutter_test/flutter_test.dart';
import 'package:flowsy/core/services/reminder_times.dart';

void main() {
  test('opening in the morning skips today and starts tomorrow at 5 PM', () {
    final times = upcomingReminderTimes(DateTime(2026, 9, 27, 10));
    expect(times.first, DateTime(2026, 9, 28, 17));
    expect(times.any((t) => t.day == 27), isFalse);
  });

  test('opening at 8 PM also skips the 9 PM reminder today', () {
    final times = upcomingReminderTimes(DateTime(2026, 9, 27, 20));
    expect(times.first, DateTime(2026, 9, 28, 17));
    expect(times.any((t) => t.day == 27), isFalse);
  });

  test('queues 7 days of 5 PM and 9 PM reminders', () {
    final times = upcomingReminderTimes(DateTime(2026, 9, 27, 10));
    expect(times, hasLength(14));
    expect(times.map((t) => t.hour).toSet(), {17, 21});
    expect(times.last, DateTime(2026, 10, 4, 21));
  });

  test('rolls over month and year boundaries', () {
    final times = upcomingReminderTimes(DateTime(2026, 12, 31, 9));
    expect(times.first, DateTime(2027, 1, 1, 17));
    expect(times[1], DateTime(2027, 1, 1, 21));
  });
}
