import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/components/custom_scrollbar.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';

import 'photo_item_card.dart';
import 'previews_footer.dart';

class PhotoPreviewsPanel extends StatefulWidget {
  final bool isMobile;

  const PhotoPreviewsPanel({super.key, this.isMobile = false});

  @override
  State<PhotoPreviewsPanel> createState() => _PhotoPreviewsPanelState();
}

class _PhotoPreviewsPanelState extends State<PhotoPreviewsPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();

    if (widget.isMobile) {
      return SizedBox(
        height: 100,
        child: Center(
          child: CustomScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView.builder(
                controller: _scrollController,
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
                      isMirrored: provider.photoRequiresFlip,
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
                  isMirrored: provider.photoRequiresFlip,
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
