import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flowsy/core/helpers/spacing.dart';

/// Asks for the password (Firebase needs a fresh sign-in to delete an
/// account) and returns it, or null when cancelled.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _controller.text.isEmpty;
    return AlertDialog(
      title: Text('settings.delete_account_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('settings.delete_account_body'.tr()),
          verticalSpace(16),
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'settings.delete_account_password'.tr(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: isEmpty
              ? null
              : () => Navigator.of(context).pop(_controller.text),
          child: Text(
            'settings.delete_account_confirm'.tr(),
            style: TextStyle(
              color: isEmpty ? null : Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}
