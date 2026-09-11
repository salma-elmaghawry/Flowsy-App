

import 'package:equatable/equatable.dart';

enum Status { initial, loading, success, failure }

abstract class BaseState extends Equatable {
  final Status status;
  final String? message;

  const BaseState({
    this.status = Status.initial,
    this.message,
  });

   bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isFailure => status == Status.failure;
   
  @override
  List<Object?> get props => [status, message];
}