import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowsy/core/injection/injection_container.dart';
import 'package:flowsy/core/routes/routes.dart';
import 'package:flowsy/features/auth/presentation/screens/login_screen.dart';
import 'package:flowsy/features/auth/presentation/screens/signup_screen.dart';
import 'package:flowsy/features/intro/splash_screen.dart';
import 'package:flowsy/features/settings/presentation/screens/settings_screen.dart';
import 'package:flowsy/features/wallets/domain/entities/wallet.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_cubit.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:flowsy/features/wallets/presentation/screens/home_screen.dart';
import 'package:flowsy/features/wallets/presentation/screens/wallet_detail_screen.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<WalletsCubit>(),
            child: const HomeScreen(),
          ),
        );

      case Routes.walletDetail:
        final wallet = settings.arguments as Wallet;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<WalletDetailCubit>(param1: wallet.id),
            child: WalletDetailScreen(wallet: wallet),
          ),
        );

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
