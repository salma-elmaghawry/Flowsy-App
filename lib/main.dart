import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_split/app.dart';
import 'package:wallet_split/core/injection/injection_container.dart';
import 'package:wallet_split/core/theme/controller/theme_cubit.dart';
import 'package:wallet_split/features/app_lock/presentation/cubit/app_lock_cubit.dart';
import 'package:wallet_split/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wallet_split/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupInjection();

  final savedLocaleCode = getIt<SharedPreferences>().getString('app_locale');
  final startLocale = (savedLocaleCode != null) ? Locale(savedLocaleCode) : null;

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
