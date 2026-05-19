import 'package:flutter/material.dart';
import 'package:my_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:provider/provider.dart';

import 'photo_item_card.dart';
import 'previews_footer.dart';

class PhotoPreviewsPanel extends StatelessWidget {
  final bool isMobile;

  const PhotoPreviewsPanel({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();

    if (isMobile) {
      return SizedBox(
        height: 90,
        child: Center(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: provider.selectedPhotoCount,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 120,
                child: PhotoItemCard(
                  photo: provider.capturedPhotos.length > index
                      ? provider.capturedPhotos[index]
                      : null,
                  isCapturing: provider.isCapturing,
                  isMirrored: provider.isMirrored,
                  onDelete: () => provider.removePhoto(index),
                  isNextCapture:
                      provider.isCapturing &&
                      provider.capturedPhotos.length == index,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
              );
            },
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Column(
            children: List.generate(
              provider.selectedPhotoCount,
              (index) => Flexible(
                child: PhotoItemCard(
                  photo: provider.capturedPhotos.length > index
                      ? provider.capturedPhotos[index]
                      : null,
                  isCapturing: provider.isCapturing,
                  isMirrored: provider.isMirrored,
                  onDelete: () => provider.removePhoto(index),
                  isNextCapture:
                      provider.isCapturing &&
                      provider.capturedPhotos.length == index,
                ),
              ),
            ),
          ),
        ),
        const PreviewsFooter(),
      ],
    );
  }
}
