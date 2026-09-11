import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallet_split/features/wallets/domain/entities/wallet.dart';

class WalletModel {
  final String id;
  final String name;
  final int colorValue;
  final double balance;
  final DateTime createdAt;

  const WalletModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.balance,
    required this.createdAt,
  });

  factory WalletModel.fromMap(String id, Map<String, dynamic> map) {
    return WalletModel(
      id: id,
      name: map['name'] as String? ?? '',
      colorValue: map['colorValue'] as int? ?? 0xFF0EA05A,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'colorValue': colorValue,
      'balance': balance,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Wallet toEntity() => Wallet(
    id: id,
    name: name,
    colorValue: colorValue,
    balance: balance,
    createdAt: createdAt,
  );
}
