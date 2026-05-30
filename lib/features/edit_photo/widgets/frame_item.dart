import 'package:flutter/material.dart';

class FrameItem extends StatelessWidget {
  final String framePath;
  final bool isSelected;
  final VoidCallback onTap;

  const FrameItem({
    super.key,
    required this.framePath,
    required this.isSelected,
    required this.onTap,
  });

  String get _thumbnailPath {
    if (framePath.contains('assets/frames/collected/')) {
      return framePath.replaceFirst(
        'assets/frames/collected/',
        'assets/frames/thumbnails/',
      );
    } else if (framePath == 'assets/frames/frame1.png') {
      return 'assets/frames/thumbnails/frame1.png';
    }
    return framePath;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.asset(
                _thumbnailPath,
                fit: BoxFit.fitWidth,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: frame != null
                        ? child
                        : Container(color: colorScheme.surfaceContainerHighest),
                  );
                },
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
