import 'package:flowsy/features/wallets/data/models/allocation_model.dart';
import 'package:flowsy/features/wallets/data/models/money_transaction_model.dart';
import 'package:flowsy/features/wallets/data/models/wallet_model.dart';

abstract class WalletsRemoteDataSource {
  Stream<List<WalletModel>> watchWallets();
  Stream<WalletModel> watchWallet(String walletId);
  Stream<List<AllocationModel>> watchAllocations(String walletId);
  Stream<List<MoneyTransactionModel>> watchRecentTransactions({int limit});
  Stream<List<MoneyTransactionModel>> watchWalletTransactions(String walletId);

  Future<void> createWallet({required String name, required int colorValue});
  Future<void> updateWallet({
    required String walletId,
    required String name,
    required int colorValue,
  });
  Future<void> deleteWallet(String walletId);

  Future<void> createAllocation({
    required String walletId,
    required String label,
    required double amount,
    String? note,
  });
  Future<void> updateAllocation({
    required String walletId,
    required String allocationId,
    required String label,
    required double amount,
    String? note,
  });
  Future<void> deleteAllocation({
    required String walletId,
    required String allocationId,
  });

  Future<void> topUpWallet({
    required String walletId,
    required double amount,
    String? note,
  });

  Future<void> spendFromWallet({
    required String walletId,
    required double amount,
    String? allocationId,
    String? note,
  });

  /// Edits an existing transaction and re-balances the wallet (and any
  /// allocation it was paid from) by the difference.
  Future<void> updateTransaction({
    required String transactionId,
    required double amount,
    required DateTime createdAt,
    String? allocationId,
    String? note,
  });

  /// Deletes a transaction and reverts its effect on the wallet balance.
  Future<void> deleteTransaction(String transactionId);
}
