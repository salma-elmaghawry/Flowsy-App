import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowsy/core/error_handling/failures.dart';
import 'package:flowsy/features/wallets/domain/entities/allocation.dart';
import 'package:flowsy/features/wallets/domain/entities/money_transaction.dart';
import 'package:flowsy/features/wallets/domain/entities/wallet.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_cubit.dart';
import 'package:flowsy/features/wallets/presentation/widgets/add_transaction_sheet.dart';
import 'package:flowsy/features/wallets/repository/wallets_repository.dart';

/// Repository fake whose live streams the test pushes into by hand, so it can
/// reproduce several success states arriving for a single save.
class _FakeRepo implements WalletsRepository {
  final wallet = StreamController<Either<Failure, Wallet>>.broadcast();
  final transactions =
      StreamController<Either<Failure, List<MoneyTransaction>>>.broadcast();
  double? toppedUp;

  @override
  Stream<Either<Failure, Wallet>> watchWallet(String walletId) => wallet.stream;

  @override
  Stream<Either<Failure, List<Allocation>>> watchAllocations(String id) =>
      Stream.value(const Right([]));

  @override
  Stream<Either<Failure, List<MoneyTransaction>>> watchWalletTransactions(
    String walletId,
  ) => transactions.stream;

  @override
  Future<Either<Failure, void>> topUpWallet({
    required String walletId,
    required double amount,
    String? note,
  }) async {
    toppedUp = amount;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Wallet _wallet(double balance) => Wallet(
  id: 'w1',
  name: 'Insta pay',
  colorValue: 0xFF0EA05A,
  balance: balance,
  createdAt: DateTime(2026),
);

void main() {
  testWidgets('adding money closes only the form, not the screens under it', (
    tester,
  ) async {
    final repo = _FakeRepo();
    final cubit = WalletDetailCubit(repo, 'w1')..watchAll();
    repo.wallet.add(Right(_wallet(0)));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp(
          home: const Scaffold(body: Text('home screen')),
          routes: {
            '/wallet': (_) => BlocProvider.value(
              value: cubit,
              child: Builder(
                builder: (context) => Scaffold(
                  body: Column(
                    children: [
                      const Text('wallet screen'),
                      ElevatedButton(
                        onPressed: () => showAddTransactionSheet(
                          context,
                          type: TransactionType.topUp,
                        ),
                        child: const Text('open form'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Home -> wallet screen -> add-money form.
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/wallet');
    await tester.pumpAndSettle();
    await tester.tap(find.text('open form'));
    await tester.pumpAndSettle();

    // Arabic digits must be accepted.
    await tester.enterText(find.byType(TextFormField).first, '٨٠٠');
    await tester.tap(find.text('common.save'));
    await tester.pump();

    // The live streams deliver more success states while the form closes.
    repo.wallet.add(Right(_wallet(800)));
    await tester.pump(const Duration(milliseconds: 50));
    repo.transactions.add(const Right([]));
    await tester.pumpAndSettle();

    expect(repo.toppedUp, 800);
    expect(find.text('common.save'), findsNothing, reason: 'form closed');
    expect(find.text('wallet screen'), findsOneWidget,
        reason: 'wallet screen must still be open');

    await cubit.close();
  });
}
