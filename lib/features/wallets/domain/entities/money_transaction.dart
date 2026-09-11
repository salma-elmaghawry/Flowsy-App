import 'package:equatable/equatable.dart';

enum TransactionType { topUp, spend }

class MoneyTransaction extends Equatable {
  final String id;
  final String walletId;
  final String walletName;
  final String? allocationId;
  final String? allocationLabel;
  final TransactionType type;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const MoneyTransaction({
    required this.id,
    required this.walletId,
    required this.walletName,
    this.allocationId,
    this.allocationLabel,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    walletId,
    walletName,
    allocationId,
    allocationLabel,
    type,
    amount,
    note,
    createdAt,
  ];
}
