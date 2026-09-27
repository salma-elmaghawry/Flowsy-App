import 'package:flowsy/core/bloc/base_bloc.dart';
import 'package:flowsy/features/wallets/domain/entities/allocation.dart';
import 'package:flowsy/features/wallets/domain/entities/money_transaction.dart';
import 'package:flowsy/features/wallets/domain/entities/wallet.dart';

enum WalletDetailAction {
  watch,
  topUp,
  spend,
  createAllocation,
  updateAllocation,
  deleteAllocation,
  deleteWallet,
}

class WalletDetailState extends BaseState {
  final Wallet? wallet;
  final List<Allocation> allocations;
  final List<MoneyTransaction> transactions;
  final WalletDetailAction? action;

  const WalletDetailState({
    super.status = Status.initial,
    super.message,
    this.wallet,
    this.allocations = const [],
    this.transactions = const [],
    this.action,
  });

  double get allocatedTotal =>
      allocations.fold<double>(0, (sum, a) => sum + a.amount);

  double get remaining => (wallet?.balance ?? 0) - allocatedTotal;

  WalletDetailState copyWith({
    Status? status,
    String? message,
    Wallet? wallet,
    List<Allocation>? allocations,
    List<MoneyTransaction>? transactions,
    WalletDetailAction? action,
  }) {
    return WalletDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
      wallet: wallet ?? this.wallet,
      allocations: allocations ?? this.allocations,
      transactions: transactions ?? this.transactions,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    wallet,
    allocations,
    transactions,
    action,
  ];
}
