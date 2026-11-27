import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/models/frame_data.dart';

/// Where two copies of a frame land on the 10.5x15.61 cm (6x4) print page, and
/// how much of each frame edge survives on the paper.
///
/// [PhotoPrintPreview] lays the page out from these values, so keep the two
/// in sync (a widget test checks it).
class PrintLayout {
  PrintLayout._();

  /// The print page: 10.5x15.61 cm portrait at 600 dpi.
  static const Size page = AppConfig.printPixelSize;

  static double get pxPerMm => page.width / 105.0;

  /// Gap between the two copies, in frame px.
  static const double copyGap = 4;

  /// Paper lost on each edge by the DNP DS-RX1HS. It prints 4x6 over
  /// 1844x1240 dots at 300 dpi (6.15x4.13"), wider than the paper, and trims
  /// the overflow so prints have no white border.
  static const double printerTrimSidesMm = 1.25;
  static const double printerTrimTopBottomMm = 1.9;

  /// Extra room kept clear of the trim line for paper feed and cutter drift.
  static const double safetyMarginMm = 1;

  /// Landscape-ish frames (group shots) are stacked; strips sit side by side.
  static bool stacksCopies(FrameData frame) =>
      frame.size.width / frame.size.height > 0.5;

  /// Both copies plus the gap, in frame px.
  static Size contentSize(FrameData frame) => stacksCopies(frame)
      ? Size(frame.size.width, frame.size.height * 2 + copyGap)
      : Size(frame.size.width * 2 + copyGap, frame.size.height);

  /// Page px per frame px. The content covers the page, so whichever axis
  /// overflows is cropped evenly on both sides.
  static double scale(FrameData frame) {
    final content = contentSize(frame);
    return math.max(page.width / content.width, page.height / content.height);
  }

  /// Minimum distance, in frame px, from a frame's left/right edge (dx) and
  /// top/bottom edge (dy) for content that must stay on the paper with
  /// [safetyMarginMm] to spare. Covers the page crop and the printer trim on
  /// the copies' outer edges.
  static Offset safeInset(FrameData frame) {
    final s = scale(frame);
    final content = contentSize(frame) * s;
    final cropX = math.max(0.0, (content.width - page.width) / 2);
    final cropY = math.max(0.0, (content.height - page.height) / 2);
    final margin = safetyMarginMm * pxPerMm;
    return Offset(
      (cropX + printerTrimSidesMm * pxPerMm + margin) / s,
      (cropY + printerTrimTopBottomMm * pxPerMm + margin) / s,
    );
  }
}
