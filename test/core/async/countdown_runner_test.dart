import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/core/async/cancellation_token.dart';
import 'package:th_photobooth/core/async/countdown_runner.dart';

void main() {
  test('returns immediately for a non-positive countdown', () async {
    final values = <int>[];

    final completed = await CountdownRunner().run(
      seconds: 0,
      cancellation: CancellationToken(),
      onTick: values.add,
    );

    expect(completed, isTrue);
    expect(values, [0]);
  });

  test('honors cancellation before the countdown completes', () async {
    final token = CancellationToken();
    final values = <int>[];

    final future = CountdownRunner().run(
      seconds: 1,
      cancellation: token,
      onTick: (remaining) {
        values.add(remaining);
        if (remaining == 1) token.cancel();
      },
    );

    expect(await future, isFalse);
    expect(values, [1]);
  });
}
