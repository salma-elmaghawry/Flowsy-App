import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallet_split/features/wallets/domain/entities/money_transaction.dart';

class MoneyTransactionModel {
  final String id;
  final String walletId;
  final String walletName;
  final String? allocationId;
  final String? allocationLabel;
  final TransactionType type;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const MoneyTransactionModel({
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

  factory MoneyTransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return MoneyTransactionModel(
      id: id,
      walletId: map['walletId'] as String? ?? '',
      walletName: map['walletName'] as String? ?? '',
      allocationId: map['allocationId'] as String?,
      allocationLabel: map['allocationLabel'] as String?,
      type: (map['type'] as String?) == 'topUp'
          ? TransactionType.topUp
          : TransactionType.spend,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      note: map['note'] as String?,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'walletName': walletName,
      'allocationId': allocationId,
      'allocationLabel': allocationLabel,
      'type': type == TransactionType.topUp ? 'topUp' : 'spend',
      'amount': amount,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MoneyTransaction toEntity() => MoneyTransaction(
    id: id,
    walletId: walletId,
    walletName: walletName,
    allocationId: allocationId,
    allocationLabel: allocationLabel,
    type: type,
    amount: amount,
    note: note,
    createdAt: createdAt,
  );
}
