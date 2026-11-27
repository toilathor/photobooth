import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/models/qr_corner.dart';

class FrameData {
  final String filename;
  final int photoSlots;
  final Size size;
  final List<Rect> slots;
  final String categoryId;
  final String categoryName;

  /// QR corners that would cover the frame's artwork (e.g. the couple's names),
  /// from `blocked_qr_corners` in data.json.
  final Set<QrCorner> blockedQrCorners;

  /// Corner the QR moves to when this frame is picked, from
  /// `default_qr_corner` in data.json. Null keeps the guest's last choice.
  final QrCorner? defaultQrCorner;

  const FrameData({
    this.filename = '',
    required this.photoSlots,
    this.size = Size.zero,
    this.slots = const [],
    this.categoryId = '',
    this.categoryName = '',
    this.blockedQrCorners = const {},
    this.defaultQrCorner,
  });

  /// Factory for standard frames. The slot count follows the flavor
  /// ([AppConfig.standardPhotoCount]): 2 for personal, 4 for commercial.
  /// [slots] (from `slots` in data.json) replaces the default photo areas for
  /// frames laid out differently; it is ignored unless it holds exactly one
  /// rect per photo.
  factory FrameData.standard({
    String filename = '',
    String categoryId = '',
    String categoryName = '',
    List<Rect>? slots,
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
      slots: slots != null && slots.length == count
          ? slots
          : allSlots.sublist(0, count),
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
    Set<QrCorner> blockedQrCorners = const {},
    QrCorner? defaultQrCorner,
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
      blockedQrCorners: blockedQrCorners,
      defaultQrCorner: defaultQrCorner,
    );
  }

  /// Check if the frame layout is for a group shot (1 slot)
  bool get isGroup => photoSlots == 1;

  /// Corners the guest may put the QR in on this frame.
  List<QrCorner> get qrCorners =>
      QrCorner.values.where((c) => !blockedQrCorners.contains(c)).toList();

  /// The QR corner on this frame: [defaultQrCorner], else [current], moved to
  /// the nearest allowed corner (same row first, then same column) if blocked.
  QrCorner fitQrCorner(QrCorner current) {
    final preferred = defaultQrCorner ?? current;
    final allowed = qrCorners;
    if (allowed.isEmpty || allowed.contains(preferred)) return preferred;
    return allowed.firstWhere(
      (c) => c.isTop == preferred.isTop,
      orElse: () => allowed.firstWhere(
        (c) => c.isLeft == preferred.isLeft,
        orElse: () => allowed.first,
      ),
    );
  }

  /// Asset path of the frame image (bundled with the app). [filename] is
  /// relative to the flavor folder, e.g. `standard/standard_1.png`.
  String get path =>
      filename.isEmpty ? '' : '${AppConfig.framesAssetRoot}$filename';

  /// Small copy for the frame picker, made by `update_frames_data.dart`.
  String get thumbnailPath => filename.isEmpty
      ? ''
      : '${AppConfig.framesAssetRoot}thumbnails/$filename';
}
