import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flowsy/core/services/reminder_times.dart';

/// Reminds the user at the times they picked (5 PM and 9 PM by default) to
/// log today's spending, but only on
/// days they have not opened the app. Every app open reschedules the queue
/// starting tomorrow, which silences whatever was left for today.
class DailyReminderService {
  static const String enabledKey = 'daily_reminders_enabled';
  static const String permissionAskedKey = 'daily_reminders_permission_asked';
  static const String timesKey = 'daily_reminders_times';
  static const String _channelId = 'daily_reminders';
  static const String _channelName = 'Daily reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  final SharedPreferences _prefs;
  final DateTime Function() _now;

  bool _ready = false;

  DailyReminderService(this._plugin, this._prefs, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  bool get isEnabled => _prefs.getBool(enabledKey) ?? true;

  Future<void> setEnabled(bool value) => _prefs.setBool(enabledKey, value);

  /// The user's reminder times, sorted. Falls back to the defaults when
  /// nothing valid is saved.
  List<ReminderTime> get times {
    final saved = _prefs.getStringList(timesKey);
    if (saved == null) return defaultReminderTimes;
    final parsed = normalizeReminderTimes(
      saved.map(ReminderTime.tryDecode).whereType<ReminderTime>(),
    );
    return parsed.isEmpty ? defaultReminderTimes : parsed;
  }

  /// Saves [value] and re-queues the reminders with the new times.
  Future<void> setTimes(List<ReminderTime> value) async {
    final normalized = normalizeReminderTimes(value);
    await _prefs.setStringList(
      timesKey,
      normalized.map((t) => t.encode()).toList(),
    );
    await refresh();
  }

  bool get permissionAsked => _prefs.getBool(permissionAskedKey) ?? false;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tz_data.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (e) {
      // Reminders are a nice-to-have; never block app start on them.
      debugPrint('DailyReminderService.init failed: $e');
    }
  }

  /// Shows the system notification prompt. Returns true when allowed.
  Future<bool> requestPermission() async {
    await _prefs.setBool(permissionAskedKey, true);
    if (!_ready) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (e) {
      debugPrint('DailyReminderService.requestPermission failed: $e');
    }
    return false;
  }

  /// Re-queues all reminders in the current app language. Call on app open
  /// and after the language or the times change.
  Future<void> refresh() => reschedule(
    (i) => (
      title: 'reminders.messages.$i.title'.tr(),
      body: 'reminders.messages.$i.body'.tr(),
    ),
  );

  /// Clears pending reminders and queues one weekly repeating reminder per
  /// weekday and picked time. [message] gives the already translated text
  /// for a message index.
  Future<void> reschedule(
    ({String title, String body}) Function(int index) message,
  ) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      if (!isEnabled) return;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      for (final r in weeklyReminderSchedule(_now(), times: times)) {
        final t = r.firstFire;
        final text = message(r.messageIndex);
        await _plugin.zonedSchedule(
          id: r.id,
          scheduledDate: tz.TZDateTime(
            tz.local,
            t.year,
            t.month,
            t.day,
            t.hour,
            t.minute,
          ),
          notificationDetails: details,
          // Inexact avoids the exact-alarm permission Google Play restricts.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          title: text.title,
          body: text.body,
        );
      }
    } catch (e) {
      debugPrint('DailyReminderService.reschedule failed: $e');
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('DailyReminderService.cancelAll failed: $e');
    }
  }
}
