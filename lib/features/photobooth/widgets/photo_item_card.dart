import 'dart:io' show File;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'skeleton_loader.dart';

class PhotoItemCard extends StatelessWidget {
  final XFile? photo;
  final bool isCapturing;
  final VoidCallback? onDelete;
  final bool isNextCapture;
  final bool isMirrored;
  final EdgeInsetsGeometry? margin;

  const PhotoItemCard({
    super.key,
    this.photo,
    required this.isCapturing,
    this.onDelete,
    this.isNextCapture = false,
    this.isMirrored = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          margin: margin ?? const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: photo != null
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Transform.scale(
                          scaleX: isMirrored ? -1 : 1,
                          child: kIsWeb
                              ? Image.network(
                                  photo!.path,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const SkeletonLoader();
                                  },
                                )
                              : Image.file(
                                  File(photo!.path),
                                  fit: BoxFit.cover,
                                  frameBuilder:
                                      (context, child, frame, wasSync) {
                                        if (wasSync) return child;
                                        return frame != null
                                            ? child
                                            : const SkeletonLoader();
                                      },
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: isCapturing ? null : onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(
                              alpha: isCapturing ? 0.2 : 0.5,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: isCapturing
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : isNextCapture
              ? const SkeletonLoader()
              : Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                    size: 48,
                  ),
                ),
        ),
      ),
    );
  }
}
