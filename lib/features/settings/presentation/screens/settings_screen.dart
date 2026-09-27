import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowsy/core/helpers/extensions.dart';
import 'package:flowsy/core/helpers/responsive.dart';
import 'package:flowsy/core/helpers/spacing.dart';
import 'package:flowsy/core/injection/injection_container.dart';
import 'package:flowsy/core/routes/routes.dart';
import 'package:flowsy/core/services/daily_reminder_service.dart';
import 'package:flowsy/core/theme/controller/theme_cubit.dart';
import 'package:flowsy/core/theme/controller/theme_state.dart';
import 'package:flowsy/core/widgets/loading_overlay.dart';
import 'package:flowsy/features/app_lock/presentation/cubit/app_lock_cubit.dart';
import 'package:flowsy/features/app_lock/presentation/cubit/app_lock_state.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowsy/features/settings/presentation/widgets/choice_group.dart';
import 'package:flowsy/features/settings/presentation/widgets/delete_account_dialog.dart';
import 'package:flowsy/features/settings/presentation/widgets/reminders_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _languages = {'ar': 'العربية', 'en': 'English'};
  static const _themeModes = [
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.system,
  ];

  void _showSnack(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _changeLocale(BuildContext context, String code) async {
    await context.setLocale(Locale(code));
    await getIt<SharedPreferences>().setString('app_locale', code);
    // Queued reminders carry their text, so re-queue them in the new language.
    await getIt<DailyReminderService>().refresh();
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

  /// Clears reminders, then runs [action] on the [AuthCubit].
  Future<void> _leaveAccount(
    BuildContext context,
    void Function(AuthCubit cubit) action,
  ) async {
    await getIt<DailyReminderService>().cancelAll();
    if (context.mounted) action(context.read<AuthCubit>());
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
      await _leaveAccount(context, (cubit) => cubit.signOut());
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );
    if (password != null && password.isNotEmpty && context.mounted) {
      await _leaveAccount(
        context,
        (cubit) => cubit.deleteAccount(password: password),
      );
    }
  }

  void _onAuthChanged(BuildContext context, AuthState state) {
    final isDelete = state.action == AuthAction.deleteAccount;
    final leftAccount = isDelete || state.action == AuthAction.signOut;
    if (leftAccount && state.isSuccess) {
      if (isDelete) _showSnack(context, 'settings.delete_account_done'.tr());
      context.pushNamedAndRemoveUntil(Routes.login, predicate: (_) => false);
    } else if (isDelete && state.isFailure && state.message != null) {
      _showSnack(context, state.message!);
    }
  }

  Widget _label(BuildContext context, String key) =>
      Text(key.tr(), style: Theme.of(context).textTheme.labelMedium);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final danger = ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(theme.colorScheme.error),
    );
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: _onAuthChanged,
      builder: (context, authState) => LoadingOverlay(
        isLoading:
            authState.action == AuthAction.deleteAccount && authState.isLoading,
        child: Scaffold(
          appBar: AppBar(title: Text('settings.title'.tr())),
          body: ListView(
            padding: Responsive.scrollPadding(context),
            children: [
              _label(context, 'preferences.language'),
              verticalSpace(8),
              ChoiceGroup<String>(
                expanded: true,
                options: _languages,
                selected: context.locale.languageCode,
                onSelected: (code) => _changeLocale(context, code),
              ),
              verticalSpace(24),
              _label(context, 'preferences.theme'),
              verticalSpace(8),
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) => ChoiceGroup<ThemeMode>(
                  options: {
                    for (final mode in _themeModes)
                      mode: 'preferences.theme_${mode.name}'.tr(),
                  },
                  selected: state.themeMode,
                  onSelected: context.read<ThemeCubit>().setThemeMode,
                ),
              ),
              verticalSpace(24),
              _label(context, 'app_lock.section_title'),
              verticalSpace(4),
              BlocBuilder<AppLockCubit, AppLockState>(
                builder: (context, state) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    Icons.fingerprint_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text('app_lock.toggle_title'.tr()),
                  subtitle: Text(
                    (state.supported
                            ? 'app_lock.toggle_subtitle'
                            : 'app_lock.not_supported')
                        .tr(),
                  ),
                  value: state.enabled,
                  onChanged: (!state.supported || state.authenticating)
                      ? null
                      : (value) => _toggleAppLock(context, value),
                ),
              ),
              verticalSpace(24),
              _label(context, 'reminders.section_title'),
              verticalSpace(4),
              const RemindersTile(),
              verticalSpace(32),
              OutlinedButton.icon(
                style: danger,
                onPressed: () => _confirmSignOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: Text('settings.sign_out'.tr()),
              ),
              verticalSpace(12),
              TextButton.icon(
                style: danger,
                onPressed: () => _confirmDeleteAccount(context),
                icon: const Icon(Icons.delete_forever_rounded),
                label: Text('settings.delete_account'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
