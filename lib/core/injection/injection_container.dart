import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowsy/core/routes/app_router.dart';
import 'package:flowsy/core/services/daily_reminder_service.dart';
import 'package:flowsy/core/theme/controller/theme_cubit.dart';
import 'package:flowsy/features/app_lock/data/app_lock_service.dart';
import 'package:flowsy/features/app_lock/presentation/cubit/app_lock_cubit.dart';
import 'package:flowsy/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:flowsy/features/auth/data/datasource/auth_remote_datasource_impl.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowsy/features/auth/repository/auth_repository.dart';
import 'package:flowsy/features/auth/repository/auth_repository_impl.dart';
import 'package:flowsy/features/wallets/data/datasource/wallets_remote_datasource.dart';
import 'package:flowsy/features/wallets/data/datasource/wallets_remote_datasource_impl.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_cubit.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:flowsy/features/wallets/repository/wallets_repository.dart';
import 'package:flowsy/features/wallets/repository/wallets_repository_impl.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));

  // App lock (fingerprint / face / phone PIN)
  getIt.registerLazySingleton<AppLockService>(
    () => AppLockService(LocalAuthentication(), getIt()),
  );
  getIt.registerFactory<AppLockCubit>(() => AppLockCubit(getIt()));

  // Daily spending reminders (5 PM and 9 PM on days the app wasn't opened)
  getIt.registerLazySingleton<DailyReminderService>(
    () => DailyReminderService(FlutterLocalNotificationsPlugin(), getIt()),
  );

  // Firebase services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Auth feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt()));

  // Wallets feature
  getIt.registerLazySingleton<WalletsRemoteDataSource>(
    () => WalletsRemoteDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<WalletsRepository>(
    () => WalletsRepositoryImpl(getIt()),
  );
  getIt.registerFactory<WalletsCubit>(() => WalletsCubit(getIt()));
  getIt.registerFactoryParam<WalletDetailCubit, String, void>(
    (walletId, _) => WalletDetailCubit(getIt<WalletsRepository>(), walletId),
  );
}
