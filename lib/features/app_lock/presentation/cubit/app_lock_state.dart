import 'package:equatable/equatable.dart';

class AppLockState extends Equatable {
  /// The user turned the lock on in settings.
  final bool enabled;

  /// The lock screen is currently covering the app.
  final bool locked;

  /// The phone has a fingerprint, face or screen lock set up.
  final bool supported;

  /// The system prompt is on screen.
  final bool authenticating;

  const AppLockState({
    this.enabled = false,
    this.locked = false,
    this.supported = true,
    this.authenticating = false,
  });

  AppLockState copyWith({
    bool? enabled,
    bool? locked,
    bool? supported,
    bool? authenticating,
  }) {
    return AppLockState(
      enabled: enabled ?? this.enabled,
      locked: locked ?? this.locked,
      supported: supported ?? this.supported,
      authenticating: authenticating ?? this.authenticating,
    );
  }

  @override
  List<Object?> get props => [enabled, locked, supported, authenticating];
}
