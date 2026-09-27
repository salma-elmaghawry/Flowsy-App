import 'package:dartz/dartz.dart';
import 'package:flowsy/core/error_handling/failures.dart';
import 'package:flowsy/features/wallets/domain/entities/allocation.dart';
import 'package:flowsy/features/wallets/domain/entities/money_transaction.dart';
import 'package:flowsy/features/wallets/domain/entities/wallet.dart';

abstract class WalletsRepository {
  Stream<Either<Failure, List<Wallet>>> watchWallets();
  Stream<Either<Failure, Wallet>> watchWallet(String walletId);
  Stream<Either<Failure, List<Allocation>>> watchAllocations(String walletId);
  Stream<Either<Failure, List<MoneyTransaction>>> watchRecentTransactions({
    int limit,
  });
  Stream<Either<Failure, List<MoneyTransaction>>> watchWalletTransactions(
    String walletId,
  );

  Future<Either<Failure, void>> createWallet({
    required String name,
    required int colorValue,
  });
  Future<Either<Failure, void>> updateWallet({
    required String walletId,
    required String name,
    required int colorValue,
  });
  Future<Either<Failure, void>> deleteWallet(String walletId);

  Future<Either<Failure, void>> createAllocation({
    required String walletId,
    required String label,
    required double amount,
    String? note,
  });
  Future<Either<Failure, void>> updateAllocation({
    required String walletId,
    required String allocationId,
    required String label,
    required double amount,
    String? note,
  });
  Future<Either<Failure, void>> deleteAllocation({
    required String walletId,
    required String allocationId,
  });

  Future<Either<Failure, void>> topUpWallet({
    required String walletId,
    required double amount,
    String? note,
  });

  Future<Either<Failure, void>> spendFromWallet({
    required String walletId,
    required double amount,
    String? allocationId,
    String? note,
  });
}
