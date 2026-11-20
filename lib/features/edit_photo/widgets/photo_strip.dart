import 'dart:io' show File;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/components/branded_qr_code.dart';
import 'package:th_photobooth/core/configs/filter_config.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/models/qr_corner.dart';

class PhotoStrip extends StatelessWidget {
  final List<XFile> photos;
  final FrameData frame;
  final String selectedFilter;
  final double filterIntensity;
  final bool isMirrored;
  final String? galleryUrl;
  final bool showQrPlaceholder;
  final QrCorner qrCorner;

  const PhotoStrip({
    super.key,
    required this.photos,
    required this.frame,
    required this.selectedFilter,
    required this.filterIntensity,
    required this.isMirrored,
    this.galleryUrl,
    this.showQrPlaceholder = false,
    this.qrCorner = QrCorner.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useFallbackSize =
            constraints.maxWidth == double.infinity &&
            constraints.maxHeight == double.infinity;

        final Widget content = Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1),
              width: 0.1,
              style: BorderStyle.solid,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, innerConstraints) {
              final scaleX = innerConstraints.maxWidth / frame.size.width;
              final scaleY = innerConstraints.maxHeight / frame.size.height;
              final qrScale = math.min(scaleX, scaleY);
              final qrSize = BrandedQrCode.printSize(frame) * qrScale;
              final qrOrigin = qrCorner.origin(
                innerConstraints.biggest,
                qrSize,
                BrandedQrCode.printInset(frame) * qrScale,
              );

              return Stack(
                children: [
                  for (int i = 0; i < frame.slots.length; i++)
                    if (i < photos.length)
                      Positioned(
                        left: frame.slots[i].left * scaleX,
                        top: frame.slots[i].top * scaleY,
                        width: frame.slots[i].width * scaleX,
                        height: frame.slots[i].height * scaleY,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(
                            FilterConfig.getFilterMatrix(
                              selectedFilter,
                              filterIntensity,
                            ),
                          ),
                          child: Transform.scale(
                            scaleX: isMirrored ? -1 : 1,
                            child: kIsWeb
                                ? Image.network(
                                    photos[i].path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(photos[i].path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                  if (frame.path.isNotEmpty)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Image.asset(
                          frame.path,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error_outline),
                        ),
                      ),
                    ),
                  if (galleryUrl != null || showQrPlaceholder)
                    Positioned(
                      left: qrOrigin.dx,
                      top: qrOrigin.dy,
                      child: galleryUrl != null
                          ? BrandedQrCode(
                              data: galleryUrl!,
                              size: qrSize,
                              showLogo: false,
                            )
                          : ExcludeSemantics(
                              child: Container(
                                width: qrSize,
                                height: qrSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    qrSize * 0.12,
                                  ),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Colors.black26,
                                  size: qrSize * 0.5,
                                ),
                              ),
                            ),
                    ),
                ],
              );
            },
          ),
        );

        if (useFallbackSize) {
          return SizedBox(
            width: frame.size.width,
            height: frame.size.height,
            child: content,
          );
        }

        return AspectRatio(
          aspectRatio: frame.size.width / frame.size.height,
          child: content,
        );
      },
    );
  }
}
