import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/services/frame_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the bundled frames of the active flavor', () async {
    final frames = await FrameService.loadFrames();

    expect(frames, isNotEmpty);
    for (final frame in frames) {
      // Every registered frame must exist in the asset bundle.
      final bytes = await FrameService.loadFrameBytes(frame.path);
      expect(bytes.lengthInBytes, greaterThan(0), reason: frame.path);
    }
  });

  test(
    'every frame slot sits inside its frame and keeps a 4:3 photo',
    () async {
      final frames = await FrameService.loadFrames();

      for (final frame in frames) {
        for (final slot in frame.slots) {
          expect(slot.left, greaterThanOrEqualTo(0), reason: frame.path);
          expect(slot.top, greaterThanOrEqualTo(0), reason: frame.path);
          expect(
            slot.right,
            lessThanOrEqualTo(frame.size.width),
            reason: frame.path,
          );
          expect(
            slot.bottom,
            lessThanOrEqualTo(frame.size.height),
            reason: frame.path,
          );
          expect(
            slot.width / slot.height,
            closeTo(4 / 3, 0.005),
            reason: frame.path,
          );
        }
      }
    },
  );
}
