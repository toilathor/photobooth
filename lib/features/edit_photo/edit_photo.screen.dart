import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_photobooth/components/photobooth_header.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:my_photobooth/features/edit_photo/widgets/editor_panel.dart';
import 'package:provider/provider.dart';

class EditPhotoScreen extends StatelessWidget {
  const EditPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<PhotoboothProvider, EditPhotoProvider>(
      builder: (context, photoboothProvider, editPhotoProvider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const PhotoboothHeader(),
                  Expanded(
                    child: Row(
                      children: [
                        PreviewPanel(
                          photos: photoboothProvider.capturedPhotos,
                          selectedFrame: editPhotoProvider.selectedFrame,
                          availableFrames: editPhotoProvider.filteredFrames,
                          printTwoCopies: editPhotoProvider.printTwoCopies,
                          showPaperPreview: editPhotoProvider.showPaperPreview,
                          onTogglePrintTwoCopies:
                              editPhotoProvider.togglePrintTwoCopies,
                          onTogglePaperPreview:
                              editPhotoProvider.togglePaperPreview,
                          videoRecapFile: photoboothProvider.videoRecapFile,
                          photoTimestamps: photoboothProvider.photoTimestamps,
                          selectedFilter: editPhotoProvider.selectedFilter,
                          filterIntensity: editPhotoProvider.filterIntensity,
                        ),
                        const Gap(24),
                        EditorPanel(
                          availableFrames: editPhotoProvider.filteredFrames,
                          selectedFrame: editPhotoProvider.selectedFrame.path,
                          onFrameSelected: editPhotoProvider.setSelectedFrame,
                          photos: photoboothProvider.capturedPhotos,
                          videoRecapFile: photoboothProvider.videoRecapFile,
                          photoTimestamps: photoboothProvider.photoTimestamps,
                          isProcessing: editPhotoProvider.isProcessing,
                          filters: editPhotoProvider.filters,
                          selectedFilter: editPhotoProvider.selectedFilter,
                          filterIntensity: editPhotoProvider.filterIntensity,
                          onFilterSelected: editPhotoProvider.setFilter,
                          onFilterIntensityChanged: editPhotoProvider.setFilterIntensity,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
