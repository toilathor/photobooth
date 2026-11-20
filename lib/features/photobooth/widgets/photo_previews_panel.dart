import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/components/custom_scrollbar.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

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

  void _removeWithUndo(PhotoboothProvider provider, int index) {
    if (index >= provider.capturedPhotos.length) return;
    final photo = provider.capturedPhotos[index];
    provider.removePhoto(index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.preview.photoRemoved),
          action: SnackBarAction(
            label: t.preview.undo,
            onPressed: () => provider.restorePhoto(index, photo),
          ),
        ),
      );
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
                      onDelete: () => _removeWithUndo(provider, index),
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

    final int count = provider.selectedPhotoCount;
    return Column(
      children: [
        Expanded(
          // Size the 4:3 cards from the available space and keep them grouped
          // at the top, aligned with the camera preview and the settings
          // panel, so a 1 or 2 photo layout does not spread the cards to the
          // top and bottom of a tall column.
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double cardGap = 12;
              final double cardHeight = math.max(
                0,
                constraints.maxHeight / count - cardGap,
              );
              final double cardWidth = math.min(
                constraints.maxWidth,
                cardHeight * 4 / 3,
              );
              return Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    count,
                    (index) => SizedBox(
                      width: cardWidth,
                      child: PhotoItemCard(
                        margin: const EdgeInsets.only(bottom: cardGap),
                        photo: provider.capturedPhotos.length > index
                            ? provider.capturedPhotos[index]
                            : null,
                        isCapturing: provider.isCapturing,
                        isMirrored: provider.photoRequiresFlip,
                        onDelete: () => _removeWithUndo(provider, index),
                        isNextCapture:
                            provider.isCapturing &&
                            provider.capturedPhotos.length == index,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const PreviewsFooter(),
      ],
    );
  }
}
