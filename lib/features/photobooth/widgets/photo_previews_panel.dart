import 'package:flutter/material.dart';
import 'package:my_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:provider/provider.dart';

import 'photo_item_card.dart';
import 'previews_footer.dart';

class PhotoPreviewsPanel extends StatelessWidget {
  const PhotoPreviewsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();

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
