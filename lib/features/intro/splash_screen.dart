import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/animations/animations.dart';
import 'package:flowsy/core/helpers/extensions.dart';
import 'package:flowsy/core/helpers/spacing.dart';
import 'package:flowsy/core/routes/routes.dart';
import 'package:flowsy/core/utils/app_text_styles.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final isAuthenticated = context.read<AuthCubit>().state.isAuthenticated;
    context.pushNamedAndRemoveUntil(
      isAuthenticated ? Routes.home : Routes.login,
      predicate: (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 72.sp,
              color: Colors.white,
            ).fadeInScale(),
            verticalSpace(16),
            Text(
              'app_name'.tr(),
              style: AppTextStyles.font32Bold.copyWith(color: Colors.white),
            ).fadeInSlideUp(delay: const Duration(milliseconds: 200)),
          ],
        ),
      ),
    );
  }
}
