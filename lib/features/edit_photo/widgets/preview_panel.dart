import 'dart:io' show File;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:my_photobooth/models/frame_data.dart';

class PreviewPanel extends StatelessWidget {
  final List<XFile> photos;
  final FrameData selectedFrame;
  final bool printTwoCopies;
  final bool showPaperPreview;
  final ValueChanged<bool> onTogglePrintTwoCopies;
  final ValueChanged<bool> onTogglePaperPreview;

  const PreviewPanel({
    super.key,
    required this.photos,
    required this.selectedFrame,
    required this.printTwoCopies,
    required this.showPaperPreview,
    required this.onTogglePrintTwoCopies,
    required this.onTogglePaperPreview,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double frameAspectRatio =
        selectedFrame.size.width / selectedFrame.size.height;
    // If aspect ratio > 0.5, it's better to print Landscape (2 photos stacked horizontally or vertically)
    // For our specific frames: Strips are ~0.33 (Portrait), frame1 is ~0.77 (Landscape)
    final bool isLandscape = frameAspectRatio > 0.5;

    return Expanded(
      flex: 2,
      child: Container(
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
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'XEM TRƯỚC',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const Spacer(),
                  // Material 3 Expressive-style Button Group
                  _ExpressiveButtonGroup(
                    selectedIndex: showPaperPreview ? 1 : 0,
                    onChanged: (index) => onTogglePaperPreview(index == 1),
                    items: const [
                      _ExpressiveItemData(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                      ),
                      _ExpressiveItemData(
                        label: 'Print',
                        icon: Icons.local_printshop_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  _ExpressiveButtonGroup(
                    selectedIndex: printTwoCopies ? 1 : 0,
                    onChanged: (index) => onTogglePrintTwoCopies(index == 1),
                    items: const [
                      _ExpressiveItemData(
                        label: 'bản',
                        icon: Icons.looks_one_outlined,
                      ),
                      _ExpressiveItemData(
                        label: 'bản',
                        icon: Icons.looks_two_outlined,
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
                  child: showPaperPreview
                      ? _VirtualPaper(
                          isLandscape: isLandscape,
                          child: printTwoCopies
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: _PhotoStrip(
                                        photos: photos,
                                        frame: selectedFrame,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: _PhotoStrip(
                                        photos: photos,
                                        frame: selectedFrame,
                                      ),
                                    ),
                                  ],
                                )
                              : _PhotoStrip(
                                  photos: photos,
                                  frame: selectedFrame,
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
                          child: printTwoCopies
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: _PhotoStrip(
                                        photos: photos,
                                        frame: selectedFrame,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: _PhotoStrip(
                                        photos: photos,
                                        frame: selectedFrame,
                                      ),
                                    ),
                                  ],
                                )
                              : _PhotoStrip(
                                  photos: photos,
                                  frame: selectedFrame,
                                ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpressiveItemData {
  final String label;
  final IconData icon;

  const _ExpressiveItemData({required this.label, required this.icon});
}

class _ExpressiveButtonGroup extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<_ExpressiveItemData> items;

  const _ExpressiveButtonGroup({
    required this.selectedIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          return _ExpressiveButton(
            data: items[index],
            isSelected: isSelected,
            onTap: () => onChanged(index),
          );
        }),
      ),
    );
  }
}

class _ExpressiveButton extends StatelessWidget {
  final _ExpressiveItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpressiveButton({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onSecondary
                  : colorScheme.secondary.withValues(alpha: 0.5),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: SizedBox(width: isSelected ? 8 : 0),
            ),
            if (isSelected)
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSecondary,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VirtualPaper extends StatelessWidget {
  final Widget child;
  final bool isLandscape;

  const _VirtualPaper({
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
                top: 40,
                left: 0,
                right: 0,
                child: _DashedLine(isVertical: false),
              ),
              const Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _DashedLine(isVertical: false),
              ),
            ] else ...[
              const Positioned(
                left: 40,
                top: 0,
                bottom: 0,
                child: _DashedLine(isVertical: true),
              ),
              const Positioned(
                right: 40,
                top: 0,
                bottom: 0,
                child: _DashedLine(isVertical: true),
              ),
            ],
            // The actual content (photo strips)
            Padding(
              padding: isLandscape
                  ? const EdgeInsets.symmetric(horizontal: 45, vertical: 8)
                  : const EdgeInsets.symmetric(vertical: 45, horizontal: 8),
              child: Center(child: child),
            ),
            // Paper size indicator
            Positioned(
              bottom: 12,
              right: 12,
              child: Text(
                'CANON KP-108IN (4x6") - ${isLandscape ? "LANDSCAPE" : "PORTRAIT"}',
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.black26,
                  letterSpacing: 1,
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
            width: isVertical ? 1 : null,
            height: isVertical ? null : 1,
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

class _PhotoStrip extends StatelessWidget {
  final List<XFile> photos;
  final FrameData frame;

  const _PhotoStrip({required this.photos, required this.frame});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 0.5,
          style: BorderStyle
              .solid, // Note: standard Border doesn't support dashed easily, but we can simulate or use solid light color
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
                      child: kIsWeb
                          ? Image.network(photos[i].path, fit: BoxFit.cover)
                          : Image.file(File(photos[i].path), fit: BoxFit.cover),
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
