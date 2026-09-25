import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/animations/animations.dart';
import 'package:wallet_split/core/helpers/app_validators.dart';
import 'package:wallet_split/core/helpers/extensions.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/core/routes/routes.dart';
import 'package:wallet_split/core/utils/app_text_styles.dart';
import 'package:wallet_split/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wallet_split/features/auth/presentation/cubit/auth_state.dart';
import 'package:wallet_split/features/auth/presentation/widgets/forgot_password_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.action != AuthAction.signIn) return;
            if (state.isFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message ?? '')));
            } else if (state.isSuccess) {
              context.pushNamedAndRemoveUntil(
                Routes.home,
                predicate: (route) => false,
              );
            }
          },
          builder: (context, state) {
            final isLoading =
                state.isLoading && state.action == AuthAction.signIn;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(40),
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 56.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ).fadeInScale(),
                    verticalSpace(16),
                    Text(
                      'auth.login.title'.tr(),
                      style: Theme.of(context).textTheme.displaySmall,
                    ).fadeInSlideUp(),
                    verticalSpace(32),
                    TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            labelText: 'auth.login.email_label'.tr(),
                            hintText: 'auth.login.email_hint'.tr(),
                          ),
                          validator: AppValidators.validateEmail,
                        )
                        .fadeInSlideUp(delay: const Duration(milliseconds: 100))
                        .shake(),
                    verticalSpace(16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: 'auth.login.password_label'.tr(),
                        hintText: 'auth.login.password_hint'.tr(),
                      ),
                      validator: AppValidators.validatePassword,
                    ).fadeInSlideUp(delay: const Duration(milliseconds: 150)),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => showForgotPasswordSheet(
                          context,
                          initialEmail: _emailController.text.trim(),
                        ),
                        child: Text(
                          'auth.login.forgot_password'.tr(),
                          style: AppTextStyles.font14SemiBold.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    verticalSpace(12),
                    AnimatedButton(
                      isLoading: isLoading,
                      onPressed: _submit,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Text(
                        'auth.login.submit'.tr(),
                        style: AppTextStyles.font16Normal.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).fadeInSlideUp(delay: const Duration(milliseconds: 200)),
                    verticalSpace(20),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pushNamed(Routes.signUp),
                        child: Text(
                          'auth.login.create_account'.tr(),
                          style: AppTextStyles.font14SemiBold.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
