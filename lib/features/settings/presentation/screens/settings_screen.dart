import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/helpers/extensions.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/core/injection/injection_container.dart';
import 'package:wallet_split/core/routes/routes.dart';
import 'package:wallet_split/core/theme/controller/theme_cubit.dart';
import 'package:wallet_split/core/theme/controller/theme_state.dart';
import 'package:wallet_split/core/widgets/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_split/features/app_lock/presentation/cubit/app_lock_cubit.dart';
import 'package:wallet_split/features/app_lock/presentation/cubit/app_lock_state.dart';
import 'package:wallet_split/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wallet_split/features/auth/presentation/cubit/auth_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _changeLocale(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    await getIt<SharedPreferences>().setString(
      'app_locale',
      locale.languageCode,
    );
  }

  Future<void> _toggleAppLock(BuildContext context, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<AppLockCubit>().setEnabled(
      value,
      'app_lock.enable_reason'.tr(),
    );
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text('app_lock.enable_failed'.tr())),
      );
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('settings.sign_out_confirm_title'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('settings.sign_out'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().signOut();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (password != null && password.isNotEmpty && context.mounted) {
      context.read<AuthCubit>().deleteAccount(password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        final leftAccount =
            state.action == AuthAction.signOut ||
            state.action == AuthAction.deleteAccount;
        if (leftAccount && state.isSuccess) {
          if (state.action == AuthAction.deleteAccount) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('settings.delete_account_done'.tr())),
            );
          }
          context.pushNamedAndRemoveUntil(
            Routes.login,
            predicate: (route) => false,
          );
        } else if (state.action == AuthAction.deleteAccount &&
            state.isFailure &&
            state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, authState) => LoadingOverlay(
        isLoading:
            authState.action == AuthAction.deleteAccount && authState.isLoading,
        child: Scaffold(
          appBar: AppBar(title: Text('settings.title'.tr())),
          body: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              Text(
                'preferences.language'.tr(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              verticalSpace(8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('العربية'),
                      selected: context.locale.languageCode == 'ar',
                      onSelected: (_) =>
                          _changeLocale(context, const Locale('ar')),
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('English'),
                      selected: context.locale.languageCode == 'en',
                      onSelected: (_) =>
                          _changeLocale(context, const Locale('en')),
                    ),
                  ),
                ],
              ),
              verticalSpace(24),
              Text(
                'preferences.theme'.tr(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              verticalSpace(8),
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  return Wrap(
                    spacing: 12.w,
                    children: [
                      ChoiceChip(
                        label: Text('preferences.theme_light'.tr()),
                        selected: state.themeMode == ThemeMode.light,
                        onSelected: (_) => context
                            .read<ThemeCubit>()
                            .setThemeMode(ThemeMode.light),
                      ),
                      ChoiceChip(
                        label: Text('preferences.theme_dark'.tr()),
                        selected: state.themeMode == ThemeMode.dark,
                        onSelected: (_) => context
                            .read<ThemeCubit>()
                            .setThemeMode(ThemeMode.dark),
                      ),
                      ChoiceChip(
                        label: Text('preferences.theme_system'.tr()),
                        selected: state.themeMode == ThemeMode.system,
                        onSelected: (_) => context
                            .read<ThemeCubit>()
                            .setThemeMode(ThemeMode.system),
                      ),
                    ],
                  );
                },
              ),
              verticalSpace(24),
              Text(
                'app_lock.section_title'.tr(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              verticalSpace(4),
              BlocBuilder<AppLockCubit, AppLockState>(
                builder: (context, state) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      Icons.fingerprint_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text('app_lock.toggle_title'.tr()),
                    subtitle: Text(
                      state.supported
                          ? 'app_lock.toggle_subtitle'.tr()
                          : 'app_lock.not_supported'.tr(),
                    ),
                    value: state.enabled,
                    onChanged: (!state.supported || state.authenticating)
                        ? null
                        : (value) => _toggleAppLock(context, value),
                  );
                },
              ),
              verticalSpace(32),
              OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                icon: Icon(
                  Icons.logout_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  'settings.sign_out'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              verticalSpace(12),
              TextButton.icon(
                onPressed: () => _confirmDeleteAccount(context),
                icon: Icon(
                  Icons.delete_forever_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  'settings.delete_account'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks for the password (Firebase needs a fresh sign-in to delete an
/// account) and returns it, or null when cancelled.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
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
          onPressed: _controller.text.isEmpty
              ? null
              : () => Navigator.of(context).pop(_controller.text),
          child: Text(
            'settings.delete_account_confirm'.tr(),
            style: TextStyle(color: _controller.text.isEmpty ? null : error),
          ),
        ),
      ],
    );
  }
}
