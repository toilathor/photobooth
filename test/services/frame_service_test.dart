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
}
