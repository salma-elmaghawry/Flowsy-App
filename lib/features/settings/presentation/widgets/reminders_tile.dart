import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flowsy/core/injection/injection_container.dart';
import 'package:flowsy/core/services/daily_reminder_service.dart';
import 'package:flowsy/core/services/reminder_times.dart';

class RemindersTile extends StatefulWidget {
  const RemindersTile({super.key});

  @override
  State<RemindersTile> createState() => _RemindersTileState();
}

class _RemindersTileState extends State<RemindersTile> {
  final DailyReminderService _reminders = getIt<DailyReminderService>();
  late bool _enabled = _reminders.isEnabled;
  late List<ReminderTime> _times = _reminders.times;
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

  Future<void> _saveTimes(List<ReminderTime> times) async {
    setState(() {
      _busy = true;
      _times = normalizeReminderTimes(times);
    });
    await _reminders.setTimes(_times);
    if (mounted) setState(() => _busy = false);
  }

  Future<ReminderTime?> _pick(ReminderTime initial) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
      helpText: 'reminders.pick_time'.tr(),
    );
    if (picked == null) return null;
    return ReminderTime(picked.hour, picked.minute);
  }

  Future<void> _edit(ReminderTime current) async {
    final picked = await _pick(current);
    if (picked == null || picked == current) return;
    await _saveTimes([..._times.where((t) => t != current), picked]);
  }

  Future<void> _add() async {
    final picked = await _pick(const ReminderTime(20, 0));
    if (picked == null || _times.contains(picked)) return;
    await _saveTimes([..._times, picked]);
  }

  Future<void> _remove(ReminderTime time) =>
      _saveTimes(_times.where((t) => t != time).toList());

  String _label(ReminderTime t) => MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay(hour: t.hour, minute: t.minute));

  @override
  Widget build(BuildContext context) {
    final canRemove = _times.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(
            Icons.notifications_active_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text('reminders.toggle_title'.tr()),
          subtitle: Text('reminders.toggle_subtitle'.tr()),
          value: _enabled,
          onChanged: _busy ? null : _toggle,
        ),
        if (_enabled)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _times)
                InputChip(
                  avatar: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(_label(t)),
                  tooltip: 'reminders.edit_time'.tr(),
                  onPressed: _busy ? null : () => _edit(t),
                  onDeleted: (_busy || !canRemove) ? null : () => _remove(t),
                  deleteButtonTooltipMessage: 'reminders.remove_time'.tr(),
                ),
              if (_times.length < maxReminderTimes)
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: Text('reminders.add_time'.tr()),
                  onPressed: _busy ? null : _add,
                ),
            ],
          ),
      ],
    );
  }
}
