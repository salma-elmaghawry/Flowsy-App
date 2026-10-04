import 'package:flutter_test/flutter_test.dart';
import 'package:flowsy/core/services/reminder_times.dart';

void main() {
  // Sunday 27 Sep 2026.
  final sundayMorning = DateTime(2026, 9, 27, 10);

  test('queues one reminder per weekday and time', () {
    final schedule = weeklyReminderSchedule(sundayMorning);
    expect(schedule, hasLength(14));
    expect(schedule.map((r) => r.firstFire.weekday).toSet(), hasLength(7));
    expect(schedule.map((r) => r.id).toSet(), hasLength(14));
  });

  test('still reminds today when the app was opened earlier today', () {
    final fires = weeklyReminderSchedule(sundayMorning).map((r) => r.firstFire);
    expect(fires, contains(DateTime(2026, 9, 27, 17)));
    expect(fires, contains(DateTime(2026, 9, 27, 21)));
  });

  test('a time that already passed today moves to next week', () {
    final fires = weeklyReminderSchedule(
      DateTime(2026, 9, 27, 18),
    ).map((r) => r.firstFire);
    expect(fires, contains(DateTime(2026, 9, 27, 21)));
    expect(fires, contains(DateTime(2026, 10, 4, 17)));
    expect(fires, isNot(contains(DateTime(2026, 9, 27, 17))));
  });

  test('every first fire is in the coming week', () {
    for (final r in weeklyReminderSchedule(sundayMorning)) {
      expect(r.firstFire.isAfter(sundayMorning), isTrue);
      expect(
        r.firstFire.difference(sundayMorning) <= const Duration(days: 7),
        isTrue,
      );
    }
  });

  test('two daily times use all 14 messages once a week', () {
    final indexes = weeklyReminderSchedule(
      sundayMorning,
    ).map((r) => r.messageIndex).toSet();
    expect(indexes, {for (var i = 0; i < reminderMessageCount; i++) i});
  });

  test('message indexes wrap when there are more slots than messages', () {
    final schedule = weeklyReminderSchedule(
      sundayMorning,
      times: const [
        ReminderTime(8, 0),
        ReminderTime(13, 0),
        ReminderTime(17, 0),
        ReminderTime(21, 0),
      ],
    );
    expect(schedule, hasLength(28));
    expect(
      schedule.every((r) => r.messageIndex < reminderMessageCount),
      isTrue,
    );
  });

  test('supports minutes and rolls over the year', () {
    final fires = weeklyReminderSchedule(
      DateTime(2026, 12, 31, 23),
      times: const [ReminderTime(8, 15)],
    ).map((r) => r.firstFire);
    expect(fires, contains(DateTime(2027, 1, 1, 8, 15)));
  });

  test('encodes and decodes HH:mm and rejects bad values', () {
    expect(const ReminderTime(7, 5).encode(), '07:05');
    expect(ReminderTime.tryDecode('07:05'), const ReminderTime(7, 5));
    expect(ReminderTime.tryDecode('24:00'), isNull);
    expect(ReminderTime.tryDecode('nope'), isNull);
  });
}
