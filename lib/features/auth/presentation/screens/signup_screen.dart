import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/animations/animations.dart';
import 'package:flowsy/core/helpers/app_validators.dart';
import 'package:flowsy/core/helpers/extensions.dart';
import 'package:flowsy/core/helpers/responsive.dart';
import 'package:flowsy/core/helpers/spacing.dart';
import 'package:flowsy/core/routes/routes.dart';
import 'package:flowsy/core/utils/app_text_styles.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('auth.signup.title'.tr())),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.action != AuthAction.signUp) return;
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
                state.isLoading && state.action == AuthAction.signUp;
            return SingleChildScrollView(
              padding: Responsive.scrollPadding(
                context,
                maxWidth: Responsive.formMaxWidth,
                horizontal: 24,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: 'auth.login.email_label'.tr(),
                        hintText: 'auth.login.email_hint'.tr(),
                      ),
                      validator: AppValidators.validateEmail,
                    ).fadeInSlideUp(),
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
                    ).fadeInSlideUp(delay: const Duration(milliseconds: 100)),
                    verticalSpace(16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: 'auth.signup.confirm_password_label'.tr(),
                        hintText: 'auth.signup.confirm_password_hint'.tr(),
                      ),
                      validator: (value) =>
                          AppValidators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                    ).fadeInSlideUp(delay: const Duration(milliseconds: 150)),
                    verticalSpace(28),
                    AnimatedButton(
                      isLoading: isLoading,
                      onPressed: _submit,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Text(
                        'auth.signup.submit'.tr(),
                        style: AppTextStyles.font16Normal.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).fadeInSlideUp(delay: const Duration(milliseconds: 200)),
                    verticalSpace(20),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'auth.signup.have_account'.tr(),
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
