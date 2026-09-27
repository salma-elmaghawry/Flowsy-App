import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flowsy/core/injection/injection_container.dart';
import 'package:flowsy/core/services/daily_reminder_service.dart';

/// Turns the 5 PM / 9 PM "log today's spending" reminders on or off.
class RemindersTile extends StatefulWidget {
  const RemindersTile({super.key});

  @override
  State<RemindersTile> createState() => _RemindersTileState();
}

class _RemindersTileState extends State<RemindersTile> {
  final DailyReminderService _reminders = getIt<DailyReminderService>();
  late bool _enabled = _reminders.isEnabled;
  bool _busy = false;

  Future<void> _toggle(bool value) async {
    setState(() {
      _busy = true;
      _enabled = value;
    });
    await _reminders.setEnabled(value);
    if (value) {
      await _reminders.requestPermission();
      await _reminders.refresh();
    } else {
      await _reminders.cancelAll();
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(
        Icons.notifications_active_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text('reminders.toggle_title'.tr()),
      subtitle: Text('reminders.toggle_subtitle'.tr()),
      value: _enabled,
      onChanged: _busy ? null : _toggle,
    );
  }
}
