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
                if (framePath.isEmpty)
                  Container(
                    color: colorScheme.errorContainer,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.error,
                      size: 40,
                    ),
                  )
                else
                  Image.network(
                    framePath,
                    fit: BoxFit.cover,

                    cacheWidth:
                        150, // Optimize image memory and decoding time for smooth scrolling
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: frame != null
                                ? child
                                : Container(
                                    padding: const EdgeInsets.all(24),
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.05,
                                    ),
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colorScheme.secondary.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                      ),
                                    ),
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
