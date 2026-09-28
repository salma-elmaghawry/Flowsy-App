import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({required super.message});
}

class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure({required super.message});
}

class EmailNotConfirmedFailure extends Failure {
  const EmailNotConfirmedFailure({required super.message});
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({required super.message});
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure({required super.message});
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure({required super.message});
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({required super.message});
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class InsufficientFundsFailure extends Failure {
  const InsufficientFundsFailure({required super.message});
}

class NotAuthenticatedFailure extends Failure {
  const NotAuthenticatedFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
