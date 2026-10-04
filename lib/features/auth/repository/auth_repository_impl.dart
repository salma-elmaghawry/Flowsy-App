import 'package:dartz/dartz.dart';
import 'package:flowsy/core/error_handling/error_mapper.dart';
import 'package:flowsy/core/error_handling/failures.dart';
import 'package:flowsy/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:flowsy/features/auth/domain/entities/app_user.dart';
import 'package:flowsy/features/auth/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<AppUser?> get authStateChanges =>
      _remoteDataSource.authStateChanges.map((model) => model?.toEntity());

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser?.toEntity();

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.signUp(
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(
    String email, {
    String? languageCode,
  }) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(
        email,
        languageCode: languageCode,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  }) async {
    try {
      await _remoteDataSource.deleteAccount(password: password);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
