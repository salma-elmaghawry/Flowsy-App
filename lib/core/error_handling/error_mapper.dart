import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_exceptions.dart';
import 'failures.dart';

/// Maps raw exceptions from any layer into typed, localized [Failure]s.
/// Every message goes through `.tr()` so the user always sees a localized error.
class ErrorMapper {
  static Failure map(dynamic error) {
    if (error is InsufficientFundsException) {
      return InsufficientFundsFailure(
        message: 'wallets.errors.insufficient_funds'.tr(),
      );
    }

    if (error is NotAuthenticatedException) {
      return NotAuthenticatedFailure(
        message: 'errors.not_authenticated'.tr(),
      );
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
        case 'invalid-credential':
        case 'wrong-password':
          return InvalidCredentialsFailure(
            message: 'auth.errors.invalid_credentials'.tr(),
          );
        case 'user-not-found':
          return UserNotFoundFailure(
            message: 'auth.errors.user_not_found'.tr(),
          );
        case 'email-already-in-use':
          return EmailAlreadyInUseFailure(
            message: 'auth.errors.email_in_use'.tr(),
          );
        case 'weak-password':
          return WeakPasswordFailure(
            message: 'auth.errors.weak_password'.tr(),
          );
        case 'too-many-requests':
          return TooManyRequestsFailure(
            message: 'auth.errors.rate_limit_exceeded'.tr(),
          );
        case 'network-request-failed':
          return NetworkFailure(message: 'errors.network_error'.tr());
        default:
          return UnexpectedFailure(message: 'errors.unexpected_error'.tr());
      }
    }

    if (error is FirebaseException) {
      // Thrown by cloud_firestore (plugin == 'cloud_firestore') and other
      // Firebase plugins that share this exception type.
      switch (error.code) {
        case 'permission-denied':
          return PermissionDeniedFailure(
            message: 'errors.permission_denied'.tr(),
          );
        case 'not-found':
          return NotFoundFailure(message: 'errors.not_found'.tr());
        case 'unavailable':
        case 'deadline-exceeded':
          return NetworkFailure(message: 'errors.network_error'.tr());
        default:
          return ServerFailure(message: 'errors.server_error'.tr());
      }
    }

    if (error is SocketException || error is TimeoutException) {
      return NetworkFailure(message: 'errors.network_error'.tr());
    }

    if (error is HttpException) {
      return ServerFailure(message: 'errors.server_error'.tr());
    }

    if (error is FormatException) {
      return ServerFailure(message: 'errors.server_error'.tr());
    }

    return UnexpectedFailure(message: 'errors.unexpected_error'.tr());
  }
}
