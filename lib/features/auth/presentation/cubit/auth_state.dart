import 'package:wallet_split/core/bloc/base_bloc.dart';
import 'package:wallet_split/features/auth/domain/entities/app_user.dart';

enum AuthAction { checkStatus, signIn, signUp, signOut, resetPassword }

class AuthState extends BaseState {
  final AppUser? user;
  final AuthAction? action;

  const AuthState({
    super.status = Status.initial,
    super.message,
    this.user,
    this.action,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Status? status,
    String? message,
    AppUser? user,
    AuthAction? action,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [status, message, user, action];
}
