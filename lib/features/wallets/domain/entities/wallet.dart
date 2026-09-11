import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final String name;
  final int colorValue;
  final double balance;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.balance,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, colorValue, balance, createdAt];
}
