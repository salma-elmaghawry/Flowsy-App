/// Plain-Dart exceptions thrown by data sources for domain-specific error
/// cases that don't come from a backend SDK exception type. Mapped to
/// [Failure]s by [ErrorMapper] before the generic Firebase/network branches.
class InsufficientFundsException implements Exception {
  const InsufficientFundsException();
}

class NotAuthenticatedException implements Exception {
  const NotAuthenticatedException();
}
