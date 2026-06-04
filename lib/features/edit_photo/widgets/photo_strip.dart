import 'dart:io' show File;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:th_photobooth/core/configs/filter_config.dart';
import 'package:th_photobooth/models/frame_data.dart';

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
                        child: CachedNetworkImage(
                          imageUrl: frame.path,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error_outline),
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
