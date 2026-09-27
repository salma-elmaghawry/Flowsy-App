import 'package:flowsy/core/bloc/base_bloc.dart';
import 'package:flowsy/features/wallets/domain/entities/money_transaction.dart';
import 'package:flowsy/features/wallets/domain/entities/wallet.dart';

enum WalletsAction { watch, createWallet, updateWallet, deleteWallet }

class WalletsState extends BaseState {
  final List<Wallet> wallets;
  final List<MoneyTransaction> recentTransactions;
  final WalletsAction? action;

  const WalletsState({
    super.status = Status.initial,
    super.message,
    this.wallets = const [],
    this.recentTransactions = const [],
    this.action,
  });

  double get totalBalance =>
      wallets.fold<double>(0, (sum, w) => sum + w.balance);

  WalletsState copyWith({
    Status? status,
    String? message,
    List<Wallet>? wallets,
    List<MoneyTransaction>? recentTransactions,
    WalletsAction? action,
  }) {
    return WalletsState(
      status: status ?? this.status,
      message: message ?? this.message,
      wallets: wallets ?? this.wallets,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    wallets,
    recentTransactions,
    action,
  ];
}
