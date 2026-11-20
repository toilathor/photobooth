import 'cancellation_token.dart';

/// Runs a wall-clock based countdown without owning any UI state.
class CountdownRunner {
  static const _tickInterval = Duration(milliseconds: 30);

  Future<bool> run({
    required int seconds,
    required CancellationToken cancellation,
    required void Function(int remaining) onTick,
  }) async {
    if (seconds <= 0) {
      onTick(0);
      return !cancellation.isCancelled;
    }

    final startedAt = DateTime.now();
    var remaining = seconds;
    var lastReported = seconds + 1;
    onTick(remaining);

    while (remaining > 0 && !cancellation.isCancelled) {
      final elapsed = DateTime.now().difference(startedAt).inMilliseconds;
      final expected = (seconds - elapsed ~/ 1000).clamp(0, seconds);

      if (expected < lastReported) {
        remaining = expected;
        lastReported = expected;
        onTick(remaining);
      }

      if (remaining > 0) {
        await Future<void>.delayed(_tickInterval);
      }
    }

    return remaining == 0 && !cancellation.isCancelled;
  }
}
