import 'dart:async';

class SessionLockService {
  final Duration timeout;
  Timer? _timer;
  void Function()? onLock;

  SessionLockService({this.timeout = const Duration(minutes: 2)});

  void start() {
    _timer?.cancel();
    _timer = Timer(timeout, () {
      if (onLock != null) onLock!();
    });
  }

  void reset() => start();
  void stop() => _timer?.cancel();
}
