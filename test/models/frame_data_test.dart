import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/models/frame_data.dart';

void main() {
  group('FrameData.standard', () {
    test('has as many 800x600 slots as the flavor standard mode', () {
      final frame = FrameData.standard(filename: 'standard/standard_1.png');

      expect(frame.photoSlots, AppConfig.standardPhotoCount);
      expect(frame.size.width, 880);
      expect(frame.size.height, 2650);
      expect(frame.slots, hasLength(AppConfig.standardPhotoCount));
      expect(frame.slots.every((s) => s.width == 800 && s.height == 600), true);
      expect(frame.isGroup, false);
    });

    test('resolves its asset path from the bundled flavor folder', () {
      final frame = FrameData.standard(filename: 'standard/standard_1.png');

      expect(frame.path, '${AppConfig.framesAssetRoot}standard/standard_1.png');
    });

    test('uses the photo areas a frame declares, one per photo', () {
      final custom = [
        for (var i = 0; i < AppConfig.standardPhotoCount; i++)
          Rect.fromLTWH(60, 800 + i * 620.0, 760, 570),
      ];
      final frame = FrameData.standard(slots: custom);

      expect(frame.slots, custom);
      expect(frame.photoSlots, AppConfig.standardPhotoCount);
    });

    test('keeps the default photo areas when the declared count differs', () {
      final frame = FrameData.standard(
        slots: const [Rect.fromLTWH(60, 800, 760, 570)],
      );

      expect(frame.slots, FrameData.standard().slots);
    });
  });

  group('FrameData.group', () {
    test('keeps a 4:3 slot inside the 2800x2000 frame', () {
      final frame = FrameData.group(filename: 'group/group_1.png');
      final slot = frame.slots.single;

      expect(frame.size.width, 2800);
      expect(frame.size.height, 2000);
      expect(slot.width / slot.height, closeTo(4 / 3, 0.001));
      expect(slot.left, greaterThanOrEqualTo(0));
      expect(slot.right, lessThanOrEqualTo(2800));
      expect(slot.bottom, lessThanOrEqualTo(2000));
    });
  });

  test(
    'standard mode is the 2-photo layout for personal, 4 for commercial',
    () {
      final expected = AppConfig.flavor == AppFlavor.personal ? 2 : 4;

      expect(AppConfig.photoCounts, [1, expected]);
    },
  );

  test('group shot is the default mode', () {
    expect(AppConfig.defaultPhotoCount, 1);
  });
}
