import 'dart:io' show File;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:th_photobooth/core/configs/filter_config.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/components/expressive_button_group.dart';

import 'video_recap_player.dart';

const double _perforationGap = 20.0;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double frameAspectRatio =
        selectedFrame.size.width / selectedFrame.size.height;
    // If aspect ratio > 0.5, it's better to print Landscape (2 photos stacked horizontally or vertically)
    // For our specific frames: Strips are ~0.33 (Portrait), frame1 is ~0.77 (Landscape)
    final bool isLandscape = frameAspectRatio > 0.5;

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
            padding: isMobile
                ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0)
                : const EdgeInsets.all(24.0),
            child: isMobile
                ? Column(
                    children: [
                      Row(
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
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ExpressiveButtonGroup(
                            selectedIndex: showPaperPreview ? 1 : 0,
                            onChanged: (index) =>
                                onTogglePaperPreview(index == 1),
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
                            onChanged: (index) =>
                                onTogglePrintTwoCopies(index == 1),
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
                  )
                : Wrap(
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
                            onChanged: (index) =>
                                onTogglePaperPreview(index == 1),
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
                            onChanged: (index) =>
                                onTogglePrintTwoCopies(index == 1),
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
          isMobile
              ? Container(
                  height: 380,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: showPaperPreview
                      ? Screenshot(
                          controller: paperController ?? ScreenshotController(),
                          child: VirtualPaper(
                            isLandscape: isLandscape,
                            child: printTwoCopies
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: PhotoStrip(
                                          photos: photos,
                                          frame: selectedFrame,
                                          selectedFilter: selectedFilter,
                                          filterIntensity: filterIntensity,
                                          isMirrored: isMirrored,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: PhotoStrip(
                                          photos: photos,
                                          frame: selectedFrame,
                                          selectedFilter: selectedFilter,
                                          filterIntensity: filterIntensity,
                                          isMirrored: isMirrored,
                                        ),
                                      ),
                                    ],
                                  )
                                : PhotoStrip(
                                    photos: photos,
                                    frame: selectedFrame,
                                    selectedFilter: selectedFilter,
                                    filterIntensity: filterIntensity,
                                    isMirrored: isMirrored,
                                  ),
                          ),
                        )
                      : Container(
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
                            controller:
                                stripController ?? ScreenshotController(),
                            child: printTwoCopies
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: PhotoStrip(
                                          photos: photos,
                                          frame: selectedFrame,
                                          selectedFilter: selectedFilter,
                                          filterIntensity: filterIntensity,
                                          isMirrored: isMirrored,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: PhotoStrip(
                                          photos: photos,
                                          frame: selectedFrame,
                                          selectedFilter: selectedFilter,
                                          filterIntensity: filterIntensity,
                                          isMirrored: isMirrored,
                                        ),
                                      ),
                                    ],
                                  )
                                : PhotoStrip(
                                    photos: photos,
                                    frame: selectedFrame,
                                    selectedFilter: selectedFilter,
                                    filterIntensity: filterIntensity,
                                    isMirrored: isMirrored,
                                  ),
                          ),
                        ),
                )
              : Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: showPaperPreview
                          ? Screenshot(
                              controller:
                                  paperController ?? ScreenshotController(),
                              child: VirtualPaper(
                                isLandscape: isLandscape,
                                child: printTwoCopies
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: PhotoStrip(
                                              photos: photos,
                                              frame: selectedFrame,
                                              selectedFilter: selectedFilter,
                                              filterIntensity: filterIntensity,
                                              isMirrored: isMirrored,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: PhotoStrip(
                                              photos: photos,
                                              frame: selectedFrame,
                                              selectedFilter: selectedFilter,
                                              filterIntensity: filterIntensity,
                                              isMirrored: isMirrored,
                                            ),
                                          ),
                                        ],
                                      )
                                    : PhotoStrip(
                                        photos: photos,
                                        frame: selectedFrame,
                                        selectedFilter: selectedFilter,
                                        filterIntensity: filterIntensity,
                                        isMirrored: isMirrored,
                                      ),
                              ),
                            )
                          : Container(
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
                                controller:
                                    stripController ?? ScreenshotController(),
                                child: printTwoCopies
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: PhotoStrip(
                                              photos: photos,
                                              frame: selectedFrame,
                                              selectedFilter: selectedFilter,
                                              filterIntensity: filterIntensity,
                                              isMirrored: isMirrored,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: PhotoStrip(
                                              photos: photos,
                                              frame: selectedFrame,
                                              selectedFilter: selectedFilter,
                                              filterIntensity: filterIntensity,
                                              isMirrored: isMirrored,
                                            ),
                                          ),
                                        ],
                                      )
                                    : PhotoStrip(
                                        photos: photos,
                                        frame: selectedFrame,
                                        selectedFilter: selectedFilter,
                                        filterIntensity: filterIntensity,
                                        isMirrored: isMirrored,
                                      ),
                              ),
                            ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}


class VirtualPaper extends StatelessWidget {
  final Widget child;
  final bool isLandscape;

  const VirtualPaper({
    super.key,
    required this.child,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    // KP-108IN is 100mm x 148mm (4x6 inch)
    final double paperAspectRatio = isLandscape ? 148 / 100 : 100 / 148;

    return AspectRatio(
      aspectRatio: paperAspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Perforation Lines
            if (!isLandscape) ...[
              const Positioned(
                top: _perforationGap,
                left: 0,
                right: 0,
                child: _DashedLine(isVertical: false),
              ),
              const Positioned(
                bottom: _perforationGap,
                left: 0,
                right: 0,
                child: _DashedLine(isVertical: false),
              ),
            ] else ...[
              const Positioned(
                left: _perforationGap,
                top: 0,
                bottom: 0,
                child: _DashedLine(isVertical: true),
              ),
              const Positioned(
                right: _perforationGap,
                top: 0,
                bottom: 0,
                child: _DashedLine(isVertical: true),
              ),
            ],
            // The actual content (photo strips)
            Padding(
              padding: isLandscape
                  ? const EdgeInsets.symmetric(
                      horizontal: _perforationGap + 4,
                      vertical: 4,
                    )
                  : const EdgeInsets.symmetric(
                      vertical: _perforationGap + 4,
                      horizontal: 4,
                    ),
              child: Center(child: child),
            ),
            // Paper size indicator (Placed in the perforation margin area)
            if (isLandscape)
              Positioned(
                left: 8,
                top: 8,
                right: 8,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'CANON KP-108IN (4x6") - ${t.preview.landscape}',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withValues(alpha: 0.1),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  'CANON KP-108IN (4x6") - ${t.preview.portrait}',
                  style: TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withValues(alpha: 0.1),
                    letterSpacing: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final bool isVertical;
  const _DashedLine({required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: isVertical ? Axis.vertical : Axis.horizontal,
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            width: isVertical ? 0.5 : null,
            height: isVertical ? null : 0.5,
            margin: isVertical
                ? const EdgeInsets.symmetric(vertical: 2)
                : const EdgeInsets.symmetric(horizontal: 2),
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}

class PhotoStrip extends StatelessWidget {
  final List<XFile> photos;
  final FrameData frame;
  final String selectedFilter;
  final double filterIntensity;
  final bool isMirrored;

  const PhotoStrip({
    super.key,
    required this.photos,
    required this.frame,
    required this.selectedFilter,
    required this.filterIntensity,
    required this.isMirrored,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 0.1,
          style: BorderStyle.solid,
        ),
      ),
      child: AspectRatio(
        aspectRatio: frame.size.width / frame.size.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scaleX = constraints.maxWidth / frame.size.width;
            final scaleY = constraints.maxHeight / frame.size.height;

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
                              ? Image.network(photos[i].path, fit: BoxFit.cover)
                              : Image.file(
                                  File(photos[i].path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.asset(frame.path, fit: BoxFit.fill),
                  ),
                ),
              ],
            );
          },
        ),
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

  const _CompactVideoRecapButton({
    required this.videoFile,
    required this.frame,
    required this.photoTimestamps,
    required this.isMirrored,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.8),
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
