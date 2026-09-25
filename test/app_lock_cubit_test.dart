import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_split/features/app_lock/data/app_lock_service.dart';
import 'package:wallet_split/features/app_lock/presentation/cubit/app_lock_cubit.dart';

class _FakeService implements AppLockService {
  bool enabled;
  bool supported;
  bool authResult;
  int prompts = 0;

  _FakeService({
    this.enabled = false,
    this.supported = true,
    this.authResult = true,
  });

  @override
  bool get isEnabled => enabled;

  @override
  Future<void> setEnabled(bool value) async => enabled = value;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return authResult;
  }
}

void main() {
  var now = DateTime(2026, 1, 1, 12);
  DateTime clock() => now;

  setUp(() => now = DateTime(2026, 1, 1, 12));

  test('starts unlocked when the lock is off', () async {
    final cubit = AppLockCubit(_FakeService(), now: clock);
    await cubit.init();
    expect(cubit.state.locked, isFalse);
  });

  test('starts locked when on, and unlocks after a successful prompt', () async {
    final cubit = AppLockCubit(_FakeService(enabled: true), now: clock);
    expect(cubit.state.locked, isTrue, reason: 'no data flash on launch');
    await cubit.init();
    await cubit.unlock('reason');
    expect(cubit.state.locked, isFalse);
  });

  test('stays locked when the prompt is cancelled', () async {
    final service = _FakeService(enabled: true, authResult: false);
    final cubit = AppLockCubit(service, now: clock);
    await cubit.init();
    await cubit.unlock('reason');
    expect(cubit.state.locked, isTrue);
  });

  test('never locks the user out if the phone has no screen lock', () async {
    final cubit = AppLockCubit(
      _FakeService(enabled: true, supported: false),
      now: clock,
    );
    await cubit.init();
    expect(cubit.state.locked, isFalse);
  });

  test('locks again only after 30 seconds in the background', () async {
    final cubit = AppLockCubit(_FakeService(enabled: true), now: clock);
    await cubit.init();
    await cubit.unlock('reason');

    cubit.onBackgrounded();
    now = now.add(const Duration(seconds: 10));
    cubit.onResumed();
    expect(cubit.state.locked, isFalse, reason: 'short switch stays open');

    cubit.onBackgrounded();
    now = now.add(const Duration(seconds: 31));
    cubit.onResumed();
    expect(cubit.state.locked, isTrue);
  });

  test('turning the lock on requires a successful prompt', () async {
    final service = _FakeService(authResult: false);
    final cubit = AppLockCubit(service, now: clock);
    await cubit.init();

    expect(await cubit.setEnabled(true, 'reason'), isFalse);
    expect(service.enabled, isFalse);

    service.authResult = true;
    expect(await cubit.setEnabled(true, 'reason'), isTrue);
    expect(service.enabled, isTrue);
    expect(cubit.state.locked, isFalse);
  });
}
