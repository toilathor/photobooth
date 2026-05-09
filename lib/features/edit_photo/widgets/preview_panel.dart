import 'dart:io' show File;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:my_photobooth/models/frame_data.dart';

class PreviewPanel extends StatelessWidget {
  final List<XFile> photos;
  final FrameData selectedFrame;
  final bool printTwoCopies;
  final ValueChanged<bool> onTogglePrintTwoCopies;

  const PreviewPanel({
    super.key,
    required this.photos,
    required this.selectedFrame,
    required this.printTwoCopies,
    required this.onTogglePrintTwoCopies,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                      : _PhotoStrip(photos: photos, frame: selectedFrame),
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

class _PhotoStrip extends StatelessWidget {
  final List<XFile> photos;
  final FrameData frame;

  const _PhotoStrip({required this.photos, required this.frame});

  @override
  Widget build(BuildContext context) {
    // AspectRatio matches the original frame size precisely.
    return AspectRatio(
      aspectRatio: frame.size.width / frame.size.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale factors
          final scaleX = constraints.maxWidth / frame.size.width;
          final scaleY = constraints.maxHeight / frame.size.height;

          return Stack(
            children: [
              // Photos layer (bottom)
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
              // Frame layer (top)
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.asset(frame.path, fit: BoxFit.fill),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
