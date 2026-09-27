import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowsy/features/wallets/domain/entities/allocation.dart';

class AllocationModel {
  final String id;
  final String walletId;
  final String label;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const AllocationModel({
    required this.id,
    required this.walletId,
    required this.label,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  factory AllocationModel.fromMap(
    String id,
    String walletId,
    Map<String, dynamic> map,
  ) {
    return AllocationModel(
      id: id,
      walletId: walletId,
      label: map['label'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      note: map['note'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'amount': amount,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Allocation toEntity() => Allocation(
    id: id,
    walletId: walletId,
    label: label,
    amount: amount,
    note: note,
    createdAt: createdAt,
  );
}
