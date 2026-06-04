import 'dart:ui' show ImageFilter;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:th_photobooth/components/expressive_button_group.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';

import 'photo_strip.dart';
import 'video_recap_player.dart';
import 'virtual_paper.dart';

class PreviewPanel extends StatelessWidget {
  final List<XFile> photos;
  final FrameData selectedFrame;
  final List<FrameData> availableFrames;
  final bool printTwoCopies;
  final bool showPaperPreview;
  final ValueChanged<bool> onTogglePrintTwoCopies;
  final ValueChanged<bool> onTogglePaperPreview;
  final XFile? videoRecapFile;
  final List<Duration> photoTimestamps;
  final String selectedFilter;
  final double filterIntensity;
  final bool isMirrored;
  final ScreenshotController? stripController;
  final ScreenshotController? paperController;

  const PreviewPanel({
    super.key,
    required this.photos,
    required this.selectedFrame,
    required this.availableFrames,
    required this.printTwoCopies,
    required this.showPaperPreview,
    required this.onTogglePrintTwoCopies,
    required this.onTogglePaperPreview,
    this.videoRecapFile,
    this.photoTimestamps = const [],
    required this.selectedFilter,
    required this.filterIntensity,
    required this.isMirrored,
    this.stripController,
    this.paperController,
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
                isMirrored: isMirrored,
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
    required ColorScheme colorScheme,
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

    final double frameAspectRatio =
        selectedFrame.size.width / selectedFrame.size.height;
    // If aspect ratio > 0.5, it's better to print Landscape (2 photos stacked horizontally or vertically)
    // For our specific frames: Strips are ~0.33 (Portrait), frame1 is ~0.77 (Landscape)
    final bool isLandscape = frameAspectRatio > 0.5;
    final bool paperIsLandscape = isLandscape && !printTwoCopies;
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
              child: _buildPreview(isLandscape: paperIsLandscape),
            ),
          ),
          // Floating Glass Control Pill (iOS / Western Style)
          Positioned(
            bottom: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View Mode Toggle (Edit / Print Preview)
                      _buildGlassPillButton(
                        icon: showPaperPreview
                            ? Icons.local_printshop_rounded
                            : Icons.edit_rounded,
                        isActive: showPaperPreview,
                        onTap: () => onTogglePaperPreview(!showPaperPreview),
                        colorScheme: colorScheme,
                        tooltip: showPaperPreview
                            ? t.preview.print_mode
                            : t.preview.edit_mode,
                      ),
                      const SizedBox(width: 8),
                      // Copies Count Toggle (1 / 2 Copies)
                      _buildGlassPillButton(
                        icon: printTwoCopies
                            ? Icons.looks_two_rounded
                            : Icons.looks_one_rounded,
                        isActive: printTwoCopies,
                        onTap: () => onTogglePrintTwoCopies(!printTwoCopies),
                        colorScheme: colorScheme,
                        tooltip: printTwoCopies
                            ? '${t.preview.copy}: 2'
                            : '${t.preview.copy}: 1',
                      ),
                      if (videoRecapFile != null) ...[
                        const SizedBox(width: 8),
                        // Video Recap Preview Button
                        _buildGlassPillButton(
                          icon: Icons.videocam_rounded,
                          isActive: false,
                          onTap: () => _showVideoRecap(context),
                          colorScheme: colorScheme,
                          tooltip: t.editor.watchVideoRecap,
                        ),
                      ],
                    ],
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
                        isMirrored: isMirrored,
                        isMobile: isMobile,
                        photos: photos,
                      ),
                    ],
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ExpressiveButtonGroup(
                      selectedIndex: showPaperPreview ? 1 : 0,
                      onChanged: (index) => onTogglePaperPreview(index == 1),
                      items: [
                        ExpressiveItemData(
                          label: t.preview.edit_mode,
                          icon: Icons.edit_outlined,
                        ),
                        ExpressiveItemData(
                          label: t.preview.print_mode,
                          icon: Icons.local_printshop_outlined,
                        ),
                      ],
                    ),
                    ExpressiveButtonGroup(
                      selectedIndex: printTwoCopies ? 1 : 0,
                      onChanged: (index) => onTogglePrintTwoCopies(index == 1),
                      items: [
                        ExpressiveItemData(
                          label: t.preview.copy,
                          icon: Icons.looks_one_outlined,
                        ),
                        ExpressiveItemData(
                          label: t.preview.copy,
                          icon: Icons.looks_two_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildPreview(isLandscape: paperIsLandscape),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStripsContent() {
    final strip = PhotoStrip(
      photos: photos,
      frame: selectedFrame,
      selectedFilter: selectedFilter,
      filterIntensity: filterIntensity,
      isMirrored: isMirrored,
    );

    if (printTwoCopies) {
      final double frameAspectRatio =
          selectedFrame.size.width / selectedFrame.size.height;
      final bool isLandscape = frameAspectRatio > 0.5;

      if (isLandscape) {
        // Stack two landscape photos vertically to fit portrait paper
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(fit: FlexFit.loose, child: strip),
            const SizedBox(height: 4),
            Flexible(fit: FlexFit.loose, child: strip),
          ],
        );
      } else {
        // Place two portrait strips side-by-side to fit portrait paper
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(fit: FlexFit.loose, child: strip),
            const SizedBox(width: 4),
            Flexible(fit: FlexFit.loose, child: strip),
          ],
        );
      }
    }
    return strip;
  }

  Widget _buildPreview({required bool isLandscape}) {
    if (showPaperPreview) {
      return Screenshot(
        controller: paperController ?? ScreenshotController(),
        child: VirtualPaper(
          isLandscape: isLandscape,
          child: _buildPhotoStripsContent(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Screenshot(
        controller: stripController ?? ScreenshotController(),
        child: _buildPhotoStripsContent(),
      ),
    );
  }
}

class _CompactVideoRecapButton extends StatelessWidget {
  final XFile videoFile;
  final FrameData frame;
  final List<Duration> photoTimestamps;
  final bool isMirrored;
  final bool isMobile;
  final List<XFile> photos;

  const _CompactVideoRecapButton({
    required this.videoFile,
    required this.frame,
    required this.photoTimestamps,
    required this.isMirrored,
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
                        isMirrored: isMirrored,
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
