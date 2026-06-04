import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

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
    if (framePath.isEmpty) return '';
    if (framePath.startsWith('http')) return framePath;
    final filename = Uri.parse(framePath).pathSegments.last;
    return 'assets/frames/thumbnails/$filename';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          child: Text(t.editor.chooseFrame),
          onPressed: () {
            onTap();
            Navigator.pop(context);
          },
        ),
      ],
      child: GestureDetector(
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
                if (_thumbnailPath.isEmpty)
                  Container(
                    color: colorScheme.errorContainer,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.error,
                      size: 40,
                    ),
                  )
                else
                  Image.asset(
                    _thumbnailPath,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: frame != null
                                ? child
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                  ),
                          );
                        },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.errorContainer,
                        child: Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 40,
                        ),
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
      ),
    );
  }
}
