import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowsy/core/bloc/base_bloc.dart';
import 'package:flowsy/core/error_handling/failures.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowsy/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowsy/features/auth/repository/auth_repository.dart';

class _FakeAuthRepo implements AuthRepository {
  String? sentTo;
  Failure? failWith;

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(
    String email, {
    String? languageCode,
  }) async {
    if (failWith != null) return Left(failWith!);
    sentTo = email;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('sends the reset email and reports success', () async {
    final repo = _FakeAuthRepo();
    final cubit = AuthCubit(repo);
    await cubit.sendPasswordResetEmail('salma@example.com');
    expect(repo.sentTo, 'salma@example.com');
    expect(cubit.state.action, AuthAction.resetPassword);
    expect(cubit.state.status, Status.success);
  });

  test('reports the failure message', () async {
    final repo = _FakeAuthRepo()
      ..failWith = const NetworkFailure(message: 'offline');
    final cubit = AuthCubit(repo);
    await cubit.sendPasswordResetEmail('salma@example.com');
    expect(cubit.state.status, Status.failure);
    expect(cubit.state.message, 'offline');
  });
}
