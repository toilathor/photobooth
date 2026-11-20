import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/services/frame_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads the photo areas a frame declares in data.json', () {
    final standard = FrameService.frameFromJson({
      'filename': 'standard/custom.png',
      'layout_type': 'standard',
      'slots': [
        for (var i = 0; i < AppConfig.standardPhotoCount; i++)
          [60, 800 + i * 620, 760, 570],
      ],
    })!;
    final group = FrameService.frameFromJson({
      'filename': 'group/custom.png',
      'layout_type': 'group',
      'slot': [66.67, 0, 2666.67, 2000],
    })!;

    expect(standard.slots.first, const Rect.fromLTWH(60, 800, 760, 570));
    expect(standard.slots, hasLength(AppConfig.standardPhotoCount));
    expect(group.slots.single, const Rect.fromLTWH(66.67, 0, 2666.67, 2000));
  });

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
