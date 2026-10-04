import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Asks before deleting a note. Resolves to true only when confirmed.
Future<bool> confirmDeleteNote(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('notes.delete_confirm_title'.tr()),
      content: Text('notes.delete_confirm_message'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            'common.delete'.tr(),
            style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
