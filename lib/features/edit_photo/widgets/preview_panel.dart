import 'dart:ui' show ImageFilter;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';

import 'photo_strip.dart';
import 'video_recap_player.dart';
import 'virtual_paper.dart';

class PreviewPanel extends StatelessWidget {
  final List<XFile> photos;
  final FrameData selectedFrame;
  final List<FrameData> availableFrames;
  final XFile? videoRecapFile;
  final List<Duration> photoTimestamps;
  final String selectedFilter;
  final double filterIntensity;
  final bool photoIsMirrored;
  final bool videoIsMirrored;
  final ScreenshotController? paperController;
  final String? galleryUrl;
  final bool showQrPlaceholder;

  const PreviewPanel({
    super.key,
    required this.photos,
    required this.selectedFrame,
    required this.availableFrames,
    this.videoRecapFile,
    this.photoTimestamps = const [],
    required this.selectedFilter,
    required this.filterIntensity,
    required this.photoIsMirrored,
    required this.videoIsMirrored,
    this.paperController,
    this.galleryUrl,
    this.showQrPlaceholder = false,
    this.isMobile = false,
  });

  final bool isMobile;

  void _showVideoRecap(BuildContext context) {
    if (videoRecapFile == null) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            constraints: isMobile
                ? null
                : const BoxConstraints(maxWidth: 900, maxHeight: 800),
            width: isMobile ? MediaQuery.sizeOf(context).width : null,
            height: isMobile ? MediaQuery.sizeOf(context).height : null,
            margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(32),
            child: Material(
              color: Colors.transparent,
              child: VideoRecapPlayer(
                videoFile: videoRecapFile!,
                frame: selectedFrame,
                photoTimestamps: photoTimestamps,
                videoIsMirrored: videoIsMirrored,
                photoIsMirrored: photoIsMirrored,
                photos: photos,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildGlassPillButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      verticalOffset: 20,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orientation = MediaQuery.orientationOf(context);
    final bool isLandscapeOrientation = orientation == Orientation.landscape;

    final bool isMobileLandscape = isMobile && isLandscapeOrientation;

    if (isMobile) {
      final Widget content = Stack(
        alignment: Alignment.center,
        children: [
          // Preview Canvas
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              padding: isMobileLandscape
                  ? const EdgeInsets.fromLTRB(12, 32, 12, 44)
                  : const EdgeInsets.fromLTRB(8, 8, 8, 44),
              child: _buildPreview(),
            ),
          ),
          if (videoRecapFile != null)
            Positioned(
              bottom: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildGlassPillButton(
                      icon: Icons.videocam_rounded,
                      isActive: false,
                      onTap: () => _showVideoRecap(context),
                      tooltip: t.editor.watchVideoRecap,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );

      if (isMobileLandscape) {
        return content;
      } else {
        // Portrait mobile: wrap in a styled Container that fills parent's Expanded
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.05),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: content,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.preview.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 2,
                        color: colorScheme.secondary,
                      ),
                    ),
                    if (videoRecapFile != null) ...[
                      const SizedBox(width: 12),
                      _CompactVideoRecapButton(
                        videoFile: videoRecapFile!,
                        frame: selectedFrame,
                        photoTimestamps: photoTimestamps,
                        videoIsMirrored: videoIsMirrored,
                        photoIsMirrored: photoIsMirrored,
                        isMobile: isMobile,
                        photos: photos,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildPreview(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Screenshot(
      controller: paperController ?? ScreenshotController(),
      child: PhotoPrintPreview(
        photos: photos,
        selectedFrame: selectedFrame,
        selectedFilter: selectedFilter,
        filterIntensity: filterIntensity,
        photoIsMirrored: photoIsMirrored,
        galleryUrl: galleryUrl,
        showQrPlaceholder: showQrPlaceholder,
      ),
    );
  }
}

class PhotoPrintPreview extends StatelessWidget {
  final List<XFile> photos;
  final FrameData selectedFrame;
  final String selectedFilter;
  final double filterIntensity;
  final bool photoIsMirrored;
  final String? galleryUrl;
  final bool showQrPlaceholder;

  const PhotoPrintPreview({
    super.key,
    required this.photos,
    required this.selectedFrame,
    required this.selectedFilter,
    required this.filterIntensity,
    required this.photoIsMirrored,
    this.galleryUrl,
    this.showQrPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final strip = PhotoStrip(
      photos: photos,
      frame: selectedFrame,
      selectedFilter: selectedFilter,
      filterIntensity: filterIntensity,
      isMirrored: photoIsMirrored,
      galleryUrl: galleryUrl,
      showQrPlaceholder: showQrPlaceholder,
    );
    final isLandscape =
        selectedFrame.size.width / selectedFrame.size.height > 0.5;
    final content = isLandscape
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(fit: FlexFit.loose, child: strip),
              const SizedBox(height: 4),
              Flexible(fit: FlexFit.loose, child: strip),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(fit: FlexFit.loose, child: strip),
              const SizedBox(width: 4),
              Flexible(fit: FlexFit.loose, child: strip),
            ],
          );

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          VirtualPaper(isLandscape: false, child: content),
          Positioned.fill(child: _CutGuide(isVertical: !isLandscape)),
        ],
      ),
    );
  }
}

class _CutGuide extends StatelessWidget {
  final bool isVertical;

  const _CutGuide({required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey(
          isVertical
              ? 'print-cut-guide-vertical'
              : 'print-cut-guide-horizontal',
        ),
        painter: _CutGuidePainter(isVertical: isVertical),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CutGuidePainter extends CustomPainter {
  final bool isVertical;

  const _CutGuidePainter({required this.isVertical});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 0.5;
    final length = isVertical ? size.height : size.width;

    for (double offset = 0; offset < length; offset += 12) {
      final end = (offset + 7).clamp(0, length).toDouble();
      if (isVertical) {
        canvas.drawLine(
          Offset(size.width / 2, offset),
          Offset(size.width / 2, end),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(offset, size.height / 2),
          Offset(end, size.height / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CutGuidePainter oldDelegate) =>
      oldDelegate.isVertical != isVertical;
}

class _CompactVideoRecapButton extends StatelessWidget {
  final XFile videoFile;
  final FrameData frame;
  final List<Duration> photoTimestamps;
  final bool videoIsMirrored;
  final bool photoIsMirrored;
  final bool isMobile;
  final List<XFile> photos;

  const _CompactVideoRecapButton({
    required this.videoFile,
    required this.frame,
    required this.photoTimestamps,
    required this.videoIsMirrored,
    required this.photoIsMirrored,
    required this.isMobile,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: '',
              barrierColor: Colors.black87,
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, anim1, anim2) {
                return Center(
                  child: Container(
                    constraints: isMobile
                        ? null
                        : const BoxConstraints(maxWidth: 900, maxHeight: 800),
                    width: isMobile ? MediaQuery.sizeOf(context).width : null,
                    height: isMobile ? MediaQuery.sizeOf(context).height : null,
                    margin: isMobile
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(32),
                    child: Material(
                      color: Colors.transparent,
                      child: VideoRecapPlayer(
                        videoFile: videoFile,
                        frame: frame,
                        photoTimestamps: photoTimestamps,
                        videoIsMirrored: videoIsMirrored,
                        photoIsMirrored: photoIsMirrored,
                        photos: photos,
                      ),
                    ),
                  ),
                );
              },
              transitionBuilder: (context, anim1, anim2, child) {
                return FadeTransition(
                  opacity: anim1,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: anim1,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.videocam_rounded,
              color: colorScheme.onSecondary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
