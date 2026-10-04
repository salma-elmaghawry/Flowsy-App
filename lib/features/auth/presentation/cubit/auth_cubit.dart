import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowsy/core/bloc/base_bloc.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowsy/features/auth/repository/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  void checkAuthStatus() {
    emit(
      state.copyWith(status: Status.loading, action: AuthAction.checkStatus),
    );
    final user = _repository.currentUser;
    emit(
      state.copyWith(
        status: Status.success,
        user: user,
        action: AuthAction.checkStatus,
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: Status.loading, action: AuthAction.signIn));
    final result = await _repository.signIn(email: email, password: password);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: AuthAction.signIn,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: Status.success,
          user: user,
          action: AuthAction.signIn,
        ),
      ),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(state.copyWith(status: Status.loading, action: AuthAction.signUp));
    final result = await _repository.signUp(email: email, password: password);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: AuthAction.signUp,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: Status.success,
          user: user,
          action: AuthAction.signUp,
        ),
      ),
    );
  }

  Future<void> sendPasswordResetEmail(
    String email, {
    String? languageCode,
  }) async {
    emit(
      state.copyWith(status: Status.loading, action: AuthAction.resetPassword),
    );
    final result = await _repository.sendPasswordResetEmail(
      email,
      languageCode: languageCode,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: AuthAction.resetPassword,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: AuthAction.resetPassword,
        ),
      ),
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: Status.loading, action: AuthAction.signOut));
    final result = await _repository.signOut();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: AuthAction.signOut,
        ),
      ),
      (_) => emit(
        const AuthState(status: Status.success, action: AuthAction.signOut),
      ),
    );
  }

  Future<void> deleteAccount({required String password}) async {
    emit(
      state.copyWith(status: Status.loading, action: AuthAction.deleteAccount),
    );
    final result = await _repository.deleteAccount(password: password);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: AuthAction.deleteAccount,
        ),
      ),
      (_) => emit(
        const AuthState(
          status: Status.success,
          action: AuthAction.deleteAccount,
        ),
      ),
    );
  }
}
