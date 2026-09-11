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
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.action == AuthAction.signOut && state.isSuccess) {
          context.pushNamedAndRemoveUntil(
            Routes.login,
            predicate: (route) => false,
          );
        }
      },
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
          ],
        ),
      ),
    );
  }
}
