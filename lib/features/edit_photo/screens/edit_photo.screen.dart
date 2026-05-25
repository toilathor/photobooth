import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:th_photobooth/components/google_sign_in_button.dart';
import 'package:th_photobooth/components/photobooth_header.dart';
import 'package:th_photobooth/core/configs/storage_config.dart';
import 'package:th_photobooth/features/edit_photo/providers/edit_photo.provider.dart';
import 'package:th_photobooth/features/edit_photo/widgets/editor_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/qr_share_dialog.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/storage_factory.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screenshot/screenshot.dart';

class EditPhotoScreen extends StatefulWidget {
  const EditPhotoScreen({super.key});

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final ScreenshotController _stripController = ScreenshotController();
  final ScreenshotController _paperController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    StorageFactory.instance.init();
  }

  Future<void> _handleQRRequest(BuildContext context) async {
    final provider = context.read<EditPhotoProvider>();

    await provider.handleQRRequest(
      onShowLoading: () => _showSimpleLoading(context),
      onHideLoading: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      onShowQR: (url) {
        showDialog<void>(
          context: context,
          builder: (context) => QRShareDialog(url: url),
        );
      },
      onShowLogin: () {
        showWebLoginDialog(
          context,
          onLoginSuccess: () => _handleQRRequest(context),
        );
      },
      onStartUpload: () => _showUploadProgressDialog(context, provider),
      onShowError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.google_drive.error(error: error))),
        );
      },
      capturePaper: () => _capturePaperIndependent(provider),
      captureStrip: () => _captureStripIndependent(provider),
    );
  }

  void _showSimpleLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.secondary,
                      ),
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

  void _showUploadProgressDialog(
    BuildContext context,
    EditPhotoProvider provider,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Consumer<EditPhotoProvider>(
            builder: (context, provider, _) {
              final colorScheme = Theme.of(context).colorScheme;
              final progress = provider.uploadProgress;

              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 50,
                        spreadRadius: -10,
                        offset: const Offset(0, 25),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: provider.isPreparingUpload ? 0 : progress,
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return SizedBox(
                            width: 160,
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background circle
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: 1.0,
                                    strokeWidth: 12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary.withValues(
                                        alpha: 0.05,
                                      ),
                                    ),
                                  ),
                                ),
                                // Progress circle
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: provider.isPreparingUpload
                                        ? null
                                        : value,
                                    strokeWidth: 12,
                                    strokeCap: StrokeCap.round,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                if (!provider.isPreparingUpload)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${(value * 100).toInt()}',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w900,
                                          color: colorScheme.secondary,
                                          height: 1,
                                          letterSpacing: -2,
                                        ),
                                      ),
                                      Text(
                                        '%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.secondary
                                              .withValues(alpha: 0.5),
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeInOutSine,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Icon(
                                          Icons.cloud_upload_rounded,
                                          color: colorScheme.secondary,
                                          size: 56,
                                        ),
                                      );
                                    },
                                    onEnd:
                                        () {}, // Loop handled by TweenAnimationBuilder if needed or just use a loop
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Gap(40),
                      Text(
                        provider.isPreparingUpload
                            ? t.google_drive.preparing
                            : t.google_drive.uploading.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const Gap(16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          provider.uploadStatusMessage,
                          key: ValueKey(provider.uploadStatusMessage),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<Uint8List?> _captureStripIndependent(
    EditPhotoProvider provider,
  ) async {
    try {
      final widget = PhotoStrip(
        photos: provider.capturedPhotos,
        frame: provider.selectedFrame,
        selectedFilter: provider.selectedFilter,
        filterIntensity: provider.filterIntensity,
        isMirrored: provider.isMirrored,
      );

      return await _stripController.captureFromWidget(
        Material(color: Colors.transparent, child: widget),
        targetSize: provider.selectedFrame.size,
        pixelRatio: 2.0, // Tăng độ sắc nét
      );
    } catch (e) {
      debugPrint('Error capturing strip independently: $e');
      return null;
    }
  }

  Future<Uint8List?> _capturePaperIndependent(
    EditPhotoProvider provider,
  ) async {
    try {
      final double frameAspectRatio =
          provider.selectedFrame.size.width /
          provider.selectedFrame.size.height;
      final bool isLandscape = frameAspectRatio > 0.5;

      final widget = VirtualPaper(
        isLandscape: isLandscape,
        child: provider.printTwoCopies
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: PhotoStrip(
                      photos: provider.capturedPhotos,
                      frame: provider.selectedFrame,
                      selectedFilter: provider.selectedFilter,
                      filterIntensity: provider.filterIntensity,
                      isMirrored: provider.isMirrored,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    fit: FlexFit.loose,
                    child: PhotoStrip(
                      photos: provider.capturedPhotos,
                      frame: provider.selectedFrame,
                      selectedFilter: provider.selectedFilter,
                      filterIntensity: provider.filterIntensity,
                      isMirrored: provider.isMirrored,
                    ),
                  ),
                ],
              )
            : PhotoStrip(
                photos: provider.capturedPhotos,
                frame: provider.selectedFrame,
                selectedFilter: provider.selectedFilter,
                filterIntensity: provider.filterIntensity,
                isMirrored: provider.isMirrored,
              ),
      );

      // Render ở độ phân giải cao cho giấy in 4x6 (khoảng 1200x1800px)
      final double targetWidth = isLandscape ? 1800 : 1200;
      final double targetHeight = isLandscape ? 1200 : 1800;

      return await _paperController.captureFromWidget(
        Material(color: Colors.white, child: widget),
        targetSize: Size(targetWidth, targetHeight),
        pixelRatio: 1.0,
      );
    } catch (e) {
      debugPrint('Error capturing paper independently: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isMobile = ResponsiveBreakpoints.of(context).smallerThan(DESKTOP);

    return Consumer<EditPhotoProvider>(
      builder: (context, editPhotoProvider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
                  : const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const PhotoboothHeader(),
                  Expanded(
                    child: isMobile
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                PreviewPanel(
                                  stripController: _stripController,
                                  paperController: _paperController,
                                  photos: editPhotoProvider.capturedPhotos,
                                  selectedFrame: editPhotoProvider.selectedFrame,
                                  availableFrames: editPhotoProvider.filteredFrames,
                                  printTwoCopies: editPhotoProvider.printTwoCopies,
                                  showPaperPreview: editPhotoProvider.showPaperPreview,
                                  onTogglePrintTwoCopies:
                                      editPhotoProvider.togglePrintTwoCopies,
                                  onTogglePaperPreview:
                                      editPhotoProvider.togglePaperPreview,
                                  videoRecapFile: editPhotoProvider.videoRecapFile,
                                  photoTimestamps: editPhotoProvider.photoTimestamps,
                                  selectedFilter: editPhotoProvider.selectedFilter,
                                  filterIntensity: editPhotoProvider.filterIntensity,
                                  isMirrored: editPhotoProvider.isMirrored,
                                  isMobile: true,
                                ),
                                const Gap(16),
                                EditorPanel(
                                  availableFrames: editPhotoProvider.filteredFrames,
                                  selectedFrame: editPhotoProvider.selectedFrame.path,
                                  onFrameSelected: editPhotoProvider.setSelectedFrame,
                                  photos: editPhotoProvider.capturedPhotos,
                                  videoRecapFile: editPhotoProvider.videoRecapFile,
                                  photoTimestamps: editPhotoProvider.photoTimestamps,
                                  isProcessing: editPhotoProvider.isProcessing,
                                  filters: editPhotoProvider.filters,
                                  selectedFilter: editPhotoProvider.selectedFilter,
                                  filterIntensity: editPhotoProvider.filterIntensity,
                                  onFilterSelected: editPhotoProvider.setFilter,
                                  onFilterIntensityChanged:
                                      editPhotoProvider.setFilterIntensity,
                                  onQRRequested:
                                      StorageConfig.activeStorage == StorageType.none
                                      ? null
                                      : () => _handleQRRequest(context),
                                  isMobile: true,
                                ),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: PreviewPanel(
                                  stripController: _stripController,
                                  paperController: _paperController,
                                  photos: editPhotoProvider.capturedPhotos,
                                  selectedFrame: editPhotoProvider.selectedFrame,
                                  availableFrames: editPhotoProvider.filteredFrames,
                                  printTwoCopies: editPhotoProvider.printTwoCopies,
                                  showPaperPreview: editPhotoProvider.showPaperPreview,
                                  onTogglePrintTwoCopies:
                                      editPhotoProvider.togglePrintTwoCopies,
                                  onTogglePaperPreview:
                                      editPhotoProvider.togglePaperPreview,
                                  videoRecapFile: editPhotoProvider.videoRecapFile,
                                  photoTimestamps: editPhotoProvider.photoTimestamps,
                                  selectedFilter: editPhotoProvider.selectedFilter,
                                  filterIntensity: editPhotoProvider.filterIntensity,
                                  isMirrored: editPhotoProvider.isMirrored,
                                ),
                              ),
                              const Gap(24),
                              Expanded(
                                flex: 3,
                                child: EditorPanel(
                                  availableFrames: editPhotoProvider.filteredFrames,
                                  selectedFrame: editPhotoProvider.selectedFrame.path,
                                  onFrameSelected: editPhotoProvider.setSelectedFrame,
                                  photos: editPhotoProvider.capturedPhotos,
                                  videoRecapFile: editPhotoProvider.videoRecapFile,
                                  photoTimestamps: editPhotoProvider.photoTimestamps,
                                  isProcessing: editPhotoProvider.isProcessing,
                                  filters: editPhotoProvider.filters,
                                  selectedFilter: editPhotoProvider.selectedFilter,
                                  filterIntensity: editPhotoProvider.filterIntensity,
                                  onFilterSelected: editPhotoProvider.setFilter,
                                  onFilterIntensityChanged:
                                      editPhotoProvider.setFilterIntensity,
                                  onQRRequested:
                                      StorageConfig.activeStorage == StorageType.none
                                      ? null
                                      : () => _handleQRRequest(context),
                                ),
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
