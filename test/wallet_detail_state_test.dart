import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_split/features/wallets/domain/entities/allocation.dart';
import 'package:wallet_split/features/wallets/domain/entities/wallet.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallet_detail_state.dart';

Wallet _wallet(double balance) => Wallet(
  id: 'w',
  name: 'Wallet',
  colorValue: 0xFF0EA05A,
  balance: balance,
  createdAt: DateTime(2026),
);

Allocation _plan(String label, double amount) => Allocation(
  id: label,
  walletId: 'w',
  label: label,
  amount: amount,
  createdAt: DateTime(2026),
);

void main() {
  test('Vodafone Cash: 100 in account, spend 20 + 20, so I have 60', () {
    final state = WalletDetailState(
      wallet: _wallet(100),
      allocations: [_plan('a', 20), _plan('b', 20)],
    );
    expect(state.allocatedTotal, 40);
    expect(state.remaining, 60);
  });

  test('InstaPay: 810 in account, spend 800, so I have 10', () {
    final state = WalletDetailState(
      wallet: _wallet(810),
      allocations: [_plan('internet and bakas', 800)],
    );
    expect(state.remaining, 10);
  });

  test('planning more than the balance goes negative', () {
    final state = WalletDetailState(
      wallet: _wallet(50),
      allocations: [_plan('a', 80)],
    );
    expect(state.remaining, -30);
  });
}
