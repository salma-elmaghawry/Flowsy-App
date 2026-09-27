import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/helpers/responsive.dart';
import 'package:flowsy/core/routes/app_router.dart';
import 'package:flowsy/core/routes/routes.dart';
import 'package:flowsy/core/theme/app_theme.dart';
import 'package:flowsy/core/theme/controller/theme_cubit.dart';
import 'package:flowsy/core/theme/controller/theme_state.dart';
import 'package:flowsy/features/app_lock/presentation/widgets/app_lock_gate.dart';

class FlowsyApp extends StatelessWidget {
  const FlowsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Responsive.designSizeFor(MediaQuery.sizeOf(context)),
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final isDarkMode = _isDarkMode(themeState.themeMode);

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: _systemUiOverlayStyle(isDarkMode),
              child: MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeState.themeMode,
                scrollBehavior: const _NoGlowScrollBehavior(),
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRouter().generateRoute,
                initialRoute: Routes.splash,
                builder: (context, child) =>
                    AppLockGate(child: child ?? const SizedBox.shrink()),
              ),
            );
          },
        );
      },
    );
  }
}

bool _isDarkMode(ThemeMode themeMode) {
  if (themeMode == ThemeMode.dark) return true;
  if (themeMode == ThemeMode.light) return false;

  return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
}

SystemUiOverlayStyle _systemUiOverlayStyle(bool isDarkMode) {
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
  );
}

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
