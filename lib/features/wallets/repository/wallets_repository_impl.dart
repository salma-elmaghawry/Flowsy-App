import 'package:dartz/dartz.dart';
import 'package:wallet_split/core/error_handling/error_mapper.dart';
import 'package:wallet_split/core/error_handling/failures.dart';
import 'package:wallet_split/features/wallets/data/datasource/wallets_remote_datasource.dart';
import 'package:wallet_split/features/wallets/domain/entities/allocation.dart';
import 'package:wallet_split/features/wallets/domain/entities/money_transaction.dart';
import 'package:wallet_split/features/wallets/domain/entities/wallet.dart';
import 'package:wallet_split/features/wallets/repository/wallets_repository.dart';

class WalletsRepositoryImpl implements WalletsRepository {
  final WalletsRemoteDataSource _remoteDataSource;

  WalletsRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<Failure, List<Wallet>>> watchWallets() async* {
    try {
      await for (final models in _remoteDataSource.watchWallets()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left(ErrorMapper.map(e));
    }
  }

  @override
  Stream<Either<Failure, Wallet>> watchWallet(String walletId) async* {
    try {
      await for (final model in _remoteDataSource.watchWallet(walletId)) {
        yield Right(model.toEntity());
      }
    } catch (e) {
      yield Left(ErrorMapper.map(e));
    }
  }

  @override
  Stream<Either<Failure, List<Allocation>>> watchAllocations(
    String walletId,
  ) async* {
    try {
      await for (final models in _remoteDataSource.watchAllocations(
        walletId,
      )) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left(ErrorMapper.map(e));
    }
  }

  @override
  Stream<Either<Failure, List<MoneyTransaction>>> watchRecentTransactions({
    int limit = 20,
  }) async* {
    try {
      await for (final models in _remoteDataSource.watchRecentTransactions(
        limit: limit,
      )) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left(ErrorMapper.map(e));
    }
  }

  @override
  Stream<Either<Failure, List<MoneyTransaction>>> watchWalletTransactions(
    String walletId,
  ) async* {
    try {
      await for (final models in _remoteDataSource.watchWalletTransactions(
        walletId,
      )) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> createWallet({
    required String name,
    required int colorValue,
  }) async {
    try {
      await _remoteDataSource.createWallet(name: name, colorValue: colorValue);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateWallet({
    required String walletId,
    required String name,
    required int colorValue,
  }) async {
    try {
      await _remoteDataSource.updateWallet(
        walletId: walletId,
        name: name,
        colorValue: colorValue,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWallet(String walletId) async {
    try {
      await _remoteDataSource.deleteWallet(walletId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> createAllocation({
    required String walletId,
    required String label,
    required double amount,
    String? note,
  }) async {
    try {
      await _remoteDataSource.createAllocation(
        walletId: walletId,
        label: label,
        amount: amount,
        note: note,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateAllocation({
    required String walletId,
    required String allocationId,
    required String label,
    required double amount,
    String? note,
  }) async {
    try {
      await _remoteDataSource.updateAllocation(
        walletId: walletId,
        allocationId: allocationId,
        label: label,
        amount: amount,
        note: note,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllocation({
    required String walletId,
    required String allocationId,
  }) async {
    try {
      await _remoteDataSource.deleteAllocation(
        walletId: walletId,
        allocationId: allocationId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> topUpWallet({
    required String walletId,
    required double amount,
    String? note,
  }) async {
    try {
      await _remoteDataSource.topUpWallet(
        walletId: walletId,
        amount: amount,
        note: note,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> spendFromWallet({
    required String walletId,
    required double amount,
    String? allocationId,
    String? note,
  }) async {
    try {
      await _remoteDataSource.spendFromWallet(
        walletId: walletId,
        amount: amount,
        allocationId: allocationId,
        note: note,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
