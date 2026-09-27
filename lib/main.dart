import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowsy/app.dart';
import 'package:flowsy/core/injection/injection_container.dart';
import 'package:flowsy/core/services/daily_reminder_service.dart';
import 'package:flowsy/core/theme/controller/theme_cubit.dart';
import 'package:flowsy/features/app_lock/presentation/cubit/app_lock_cubit.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowsy/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupInjection();
  await getIt<DailyReminderService>().init();

  final savedLocaleCode = getIt<SharedPreferences>().getString('app_locale');
  final startLocale = (savedLocaleCode != null)
      ? Locale(savedLocaleCode)
      : null;

  runApp(
    EasyLocalization(
      startLocale: startLocale,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => getIt<ThemeCubit>()),
          BlocProvider<AuthCubit>(
            create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
          ),
          BlocProvider<AppLockCubit>(
            create: (context) => getIt<AppLockCubit>()..init(),
          ),
        ],
        child: const FlowsyApp(),
      ),
    ),
  );
}
