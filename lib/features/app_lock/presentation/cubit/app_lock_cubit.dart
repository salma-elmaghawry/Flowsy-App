import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_split/features/app_lock/data/app_lock_service.dart';
import 'package:wallet_split/features/app_lock/presentation/cubit/app_lock_state.dart';

class AppLockCubit extends Cubit<AppLockState> {
  final AppLockService _service;
  final DateTime Function() _now;

  /// How long the app may sit in the background before it locks again.
  static const Duration relockAfter = Duration(seconds: 30);

  DateTime? _backgroundedAt;

  AppLockCubit(this._service, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      // Start locked when the lock is on, so no data flashes before the check.
      super(
        AppLockState(enabled: _service.isEnabled, locked: _service.isEnabled),
      );

  Future<void> init() async {
    final supported = await _service.isDeviceSupported();
    // If the phone's screen lock was removed, never trap the user out.
    emit(
      state.copyWith(supported: supported, locked: state.enabled && supported),
    );
  }

  Future<void> unlock(String reason) async {
    if (!state.locked || state.authenticating) return;
    emit(state.copyWith(authenticating: true));
    final ok = await _service.authenticate(reason);
    emit(state.copyWith(authenticating: false, locked: !ok));
  }

  /// Turning the lock on asks for the fingerprint / PIN first, so the user
  /// knows it works before it can lock them out.
  Future<bool> setEnabled(bool value, String reason) async {
    if (value) {
      if (!state.supported) return false;
      emit(state.copyWith(authenticating: true));
      final ok = await _service.authenticate(reason);
      emit(state.copyWith(authenticating: false));
      if (!ok) return false;
    }
    await _service.setEnabled(value);
    emit(state.copyWith(enabled: value, locked: false));
    return true;
  }

  void onBackgrounded() {
    // The system prompt itself can background the app; ignore that.
    if (state.authenticating) return;
    _backgroundedAt = _now();
  }

  void onResumed() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null || !state.enabled || !state.supported) return;
    if (_now().difference(since) >= relockAfter) {
      emit(state.copyWith(locked: true));
    }
  }
}
