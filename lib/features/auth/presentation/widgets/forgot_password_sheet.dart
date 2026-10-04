import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/animations/animations.dart';
import 'package:flowsy/core/helpers/app_validators.dart';
import 'package:flowsy/core/helpers/spacing.dart';
import 'package:flowsy/core/utils/app_text_styles.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_state.dart';

Future<void> showForgotPasswordSheet(
  BuildContext context, {
  String initialEmail = '',
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _ForgotPasswordSheet(initialEmail: initialEmail),
  );
}

class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordSheet({required this.initialEmail});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    context.read<AuthCubit>().sendPasswordResetEmail(
      _emailController.text.trim(),
      languageCode: context.locale.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, current) => current.action == AuthAction.resetPassword,
      listener: (context, state) {
        if (state.isSuccess) {
          setState(() => _sent = true);
        } else if (state.isFailure) {
          setState(
            () => _error = state.message ?? 'errors.unexpected_error'.tr(),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: _sent ? _buildSent(theme) : _buildForm(theme),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('auth.forgot.title'.tr(), style: theme.textTheme.displaySmall),
          verticalSpace(8),
          Text('auth.forgot.message'.tr(), style: theme.textTheme.bodyMedium),
          verticalSpace(20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.start,
            autofocus: widget.initialEmail.isEmpty,
            decoration: InputDecoration(
              labelText: 'auth.login.email_label'.tr(),
              hintText: 'auth.login.email_hint'.tr(),
            ),
            validator: AppValidators.validateEmail,
          ),
          if (_error != null) ...[
            verticalSpace(16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          verticalSpace(24),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading =
                  state.isLoading && state.action == AuthAction.resetPassword;
              return AnimatedButton(
                isLoading: isLoading,
                onPressed: _submit,
                backgroundColor: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12.r),
                child: Text(
                  'auth.forgot.submit'.tr(),
                  style: AppTextStyles.font16Normal.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mark_email_read_rounded,
          size: 56.sp,
          color: theme.colorScheme.primary,
        ).fadeInScale(),
        verticalSpace(16),
        Text(
          'auth.forgot.sent_title'.tr(),
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        verticalSpace(8),
        Text(
          'auth.forgot.sent_message'.tr(
            namedArgs: {'email': _emailController.text.trim()},
          ),
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        verticalSpace(24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.done'.tr()),
          ),
        ),
      ],
    );
  }
}
