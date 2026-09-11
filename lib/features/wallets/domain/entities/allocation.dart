import 'package:equatable/equatable.dart';

class Allocation extends Equatable {
  final String id;
  final String walletId;
  final String label;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const Allocation({
    required this.id,
    required this.walletId,
    required this.label,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, walletId, label, amount, note, createdAt];
}
