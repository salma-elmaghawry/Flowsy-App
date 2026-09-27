import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowsy/core/bloc/base_bloc.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_state.dart';
import 'package:flowsy/features/wallets/repository/wallets_repository.dart';

class WalletDetailCubit extends Cubit<WalletDetailState> {
  final WalletsRepository _repository;
  final String walletId;

  StreamSubscription? _walletSub;
  StreamSubscription? _allocationsSub;
  StreamSubscription? _transactionsSub;

  WalletDetailCubit(this._repository, this.walletId)
    : super(const WalletDetailState());

  void watchAll() {
    emit(
      state.copyWith(status: Status.loading, action: WalletDetailAction.watch),
    );

    _walletSub?.cancel();
    _walletSub = _repository.watchWallet(walletId).listen((either) {
      either.fold(
        (failure) => emit(
          state.copyWith(status: Status.failure, message: failure.message),
        ),
        (wallet) =>
            emit(state.copyWith(status: Status.success, wallet: wallet)),
      );
    });

    _allocationsSub?.cancel();
    _allocationsSub = _repository.watchAllocations(walletId).listen((either) {
      either.fold(
        (failure) => emit(
          state.copyWith(status: Status.failure, message: failure.message),
        ),
        (allocations) => emit(state.copyWith(allocations: allocations)),
      );
    });

    _transactionsSub?.cancel();
    _transactionsSub = _repository.watchWalletTransactions(walletId).listen((
      either,
    ) {
      either.fold(
        (failure) => emit(
          state.copyWith(status: Status.failure, message: failure.message),
        ),
        (transactions) => emit(state.copyWith(transactions: transactions)),
      );
    });
  }

  Future<void> updateWallet({
    required String name,
    required int colorValue,
  }) async {
    emit(
      state.copyWith(status: Status.loading, action: WalletDetailAction.watch),
    );
    final result = await _repository.updateWallet(
      walletId: walletId,
      name: name,
      colorValue: colorValue,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, message: failure.message),
      ),
      (_) => emit(state.copyWith(status: Status.success)),
    );
  }

  Future<void> topUp({required double amount, String? note}) async {
    emit(
      state.copyWith(status: Status.loading, action: WalletDetailAction.topUp),
    );
    final result = await _repository.topUpWallet(
      walletId: walletId,
      amount: amount,
      note: note,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletDetailAction.topUp,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: WalletDetailAction.topUp,
        ),
      ),
    );
  }

  Future<void> spend({
    required double amount,
    String? allocationId,
    String? note,
  }) async {
    emit(
      state.copyWith(status: Status.loading, action: WalletDetailAction.spend),
    );
    final result = await _repository.spendFromWallet(
      walletId: walletId,
      amount: amount,
      allocationId: allocationId,
      note: note,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletDetailAction.spend,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: WalletDetailAction.spend,
        ),
      ),
    );
  }

  Future<void> createAllocation({
    required String label,
    required double amount,
    String? note,
  }) async {
    emit(
      state.copyWith(
        status: Status.loading,
        action: WalletDetailAction.createAllocation,
      ),
    );
    final result = await _repository.createAllocation(
      walletId: walletId,
      label: label,
      amount: amount,
      note: note,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletDetailAction.createAllocation,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: WalletDetailAction.createAllocation,
        ),
      ),
    );
  }

  Future<void> updateAllocation({
    required String allocationId,
    required String label,
    required double amount,
    String? note,
  }) async {
    emit(
      state.copyWith(
        status: Status.loading,
        action: WalletDetailAction.updateAllocation,
      ),
    );
    final result = await _repository.updateAllocation(
      walletId: walletId,
      allocationId: allocationId,
      label: label,
      amount: amount,
      note: note,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletDetailAction.updateAllocation,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: WalletDetailAction.updateAllocation,
        ),
      ),
    );
  }

  Future<void> deleteAllocation(String allocationId) async {
    emit(
      state.copyWith(
        status: Status.loading,
        action: WalletDetailAction.deleteAllocation,
      ),
    );
    final result = await _repository.deleteAllocation(
      walletId: walletId,
      allocationId: allocationId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletDetailAction.deleteAllocation,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: WalletDetailAction.deleteAllocation,
        ),
      ),
    );
  }

  Future<void> deleteWallet() async {
    emit(
      state.copyWith(
        status: Status.loading,
        action: WalletDetailAction.deleteWallet,
      ),
    );
    final result = await _repository.deleteWallet(walletId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: WalletDetailAction.deleteWallet,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: Status.success,
          action: WalletDetailAction.deleteWallet,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _walletSub?.cancel();
    _allocationsSub?.cancel();
    _transactionsSub?.cancel();
    return super.close();
  }
}
