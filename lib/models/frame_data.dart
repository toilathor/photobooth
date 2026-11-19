import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/core/configs/app_config.dart';

class FrameData {
  final String filename;
  final int photoSlots;
  final Size size;
  final List<Rect> slots;
  final String categoryId;
  final String categoryName;

  const FrameData({
    this.filename = '',
    required this.photoSlots,
    this.size = Size.zero,
    this.slots = const [],
    this.categoryId = '',
    this.categoryName = '',
  });

  /// Factory for standard frames. The slot count follows the flavor
  /// ([AppConfig.standardPhotoCount]): 2 for personal, 4 for commercial.
  factory FrameData.standard({
    String filename = '',
    String categoryId = '',
    String categoryName = '',
  }) {
    const allSlots = [
      Rect.fromLTWH(40, 40, 800, 600),
      Rect.fromLTWH(40, 660, 800, 600),
      Rect.fromLTWH(40, 1280, 800, 600),
      Rect.fromLTWH(40, 1900, 800, 600),
    ];
    final int count = AppConfig.standardPhotoCount;
    return FrameData(
      filename: filename,
      photoSlots: count,
      size: const Size(880, 2650),
      slots: allSlots.sublist(0, count),
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  /// Factory for group frames (1 slot)
  factory FrameData.group({
    String filename = '',
    String categoryId = '',
    String categoryName = '',
    Rect? slot,
  }) {
    return FrameData(
      filename: filename,
      photoSlots: 1,
      size: const Size(2800, 2000),
      // [slot] (from `slot` in data.json) overrides the default for frames whose
      // photo area differs. The personal default fits the frames with the two
      // people standing beside a smaller photo area
      // (see scripts/generate_personal_frames.py).
      slots: [
        slot ??
            (AppConfig.flavor == AppFlavor.personal
                ? const Rect.fromLTWH(498, 323.5, 1804, 1353)
                : const Rect.fromLTWH(350, 212, 2100, 1575)),
      ],
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  /// Check if the frame layout is for a group shot (1 slot)
  bool get isGroup => photoSlots == 1;

  /// Asset path of the frame image (bundled with the app). [filename] is
  /// relative to the flavor folder, e.g. `standard/standard_1.png`.
  String get path =>
      filename.isEmpty ? '' : '${AppConfig.framesAssetRoot}$filename';
}
