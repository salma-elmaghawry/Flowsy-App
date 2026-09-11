import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_split/core/bloc/base_bloc.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallets_state.dart';
import 'package:wallet_split/features/wallets/repository/wallets_repository.dart';

class WalletsCubit extends Cubit<WalletsState> {
  final WalletsRepository _repository;
  StreamSubscription? _walletsSub;
  StreamSubscription? _transactionsSub;

  WalletsCubit(this._repository) : super(const WalletsState());

  void watchAll() {
    emit(state.copyWith(status: Status.loading, action: WalletsAction.watch));

    _walletsSub?.cancel();
    _walletsSub = _repository.watchWallets().listen((either) {
      either.fold(
        (failure) => emit(
          state.copyWith(
            status: Status.failure,
            message: failure.message,
            action: WalletsAction.watch,
          ),
        ),
        (wallets) => emit(
          state.copyWith(
            status: Status.success,
            wallets: wallets,
            action: WalletsAction.watch,
          ),
        ),
      );
    });

    _transactionsSub?.cancel();
    _transactionsSub = _repository.watchRecentTransactions(limit: 20).listen((
      either,
    ) {
      either.fold(
        (failure) =>
            emit(state.copyWith(status: Status.failure, message: failure.message)),
        (transactions) =>
            emit(state.copyWith(recentTransactions: transactions)),
      );
    });
  }

  Future<void> createWallet({
    required String name,
    required int colorValue,
  }) async {
    emit(
      state.copyWith(
        status: Status.loading,
        action: WalletsAction.createWallet,
      ),
    );
    final result = await _repository.createWallet(
      name: name,
      colorValue: colorValue,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletsAction.createWallet,
        ),
      ),
      (_) => emit(
        state.copyWith(status: Status.success, action: WalletsAction.createWallet),
      ),
    );
  }

  Future<void> updateWallet({
    required String walletId,
    required String name,
    required int colorValue,
  }) async {
    emit(
      state.copyWith(
        status: Status.loading,
        action: WalletsAction.updateWallet,
      ),
    );
    final result = await _repository.updateWallet(
      walletId: walletId,
      name: name,
      colorValue: colorValue,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletsAction.updateWallet,
        ),
      ),
      (_) => emit(
        state.copyWith(status: Status.success, action: WalletsAction.updateWallet),
      ),
    );
  }

  Future<void> deleteWallet(String walletId) async {
    emit(
      state.copyWith(
        status: Status.loading,
        action: WalletsAction.deleteWallet,
      ),
    );
    final result = await _repository.deleteWallet(walletId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletsAction.deleteWallet,
        ),
      ),
      (_) => emit(
        state.copyWith(status: Status.success, action: WalletsAction.deleteWallet),
      ),
    );
  }

  @override
  Future<void> close() {
    _walletsSub?.cancel();
    _transactionsSub?.cancel();
    return super.close();
  }
}
