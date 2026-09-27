import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/helpers/responsive.dart';
import 'package:flowsy/core/helpers/spacing.dart';
import 'package:flowsy/features/app_lock/presentation/cubit/app_lock_cubit.dart';
import 'package:flowsy/features/app_lock/presentation/cubit/app_lock_state.dart';

/// Sits above every screen. When the app lock is on, it covers the app with a
/// lock screen on launch and after the app was in the background for a while,
/// and asks for the fingerprint, face or phone PIN to continue.
class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AppLockCubit>();
    _lifecycle = AppLifecycleListener(
      onHide: cubit.onBackgrounded,
      onShow: cubit.onResumed,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptIfLocked());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _promptIfLocked() {
    if (!mounted) return;
    context.read<AppLockCubit>().unlock('app_lock.reason'.tr());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppLockCubit, AppLockState>(
      listenWhen: (previous, current) => !previous.locked && current.locked,
      listener: (context, state) => _promptIfLocked(),
      builder: (context, state) {
        return Stack(
          children: [
            widget.child,
            if (state.locked)
              Positioned.fill(
                child: _LockScreen(
                  authenticating: state.authenticating,
                  onUnlock: _promptIfLocked,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LockScreen extends StatelessWidget {
  final bool authenticating;
  final VoidCallback onUnlock;

  const _LockScreen({required this.authenticating, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: Responsive.formMaxWidth,
            ),
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 64.sp,
                  color: theme.colorScheme.primary,
                ),
                verticalSpace(20),
                Text(
                  'app_lock.locked_title'.tr(),
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(8),
                Text(
                  'app_lock.locked_message'.tr(),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(32),
                FilledButton.icon(
                  onPressed: authenticating ? null : onUnlock,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text('app_lock.unlock'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
