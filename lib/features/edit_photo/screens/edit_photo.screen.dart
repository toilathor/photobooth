import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screenshot/screenshot.dart';
import 'package:th_photobooth/components/google_sign_in_button.dart';
import 'package:th_photobooth/components/loading_indicator.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/components/secondary_button.dart';
import 'package:th_photobooth/core/configs/storage_config.dart';
import 'package:th_photobooth/core/di/service_locator.dart';
import 'package:th_photobooth/features/edit_photo/providers/edit_photo.provider.dart';
import 'package:th_photobooth/features/edit_photo/widgets/editor_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/photo_strip.dart';
import 'package:th_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/qr_share_dialog.dart';
import 'package:th_photobooth/features/edit_photo/widgets/upload_progress_dialog.dart';
import 'package:th_photobooth/features/edit_photo/widgets/virtual_paper.dart';
import 'package:th_photobooth/helper/web_download_noop.dart'
    if (dart.library.js_interop) 'package:th_photobooth/helper/web_download_web.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/storage_factory.dart';

class EditPhotoScreen extends StatefulWidget {
  final List<XFile> photos;
  final int photoCount;
  final bool isMirrored;
  final XFile? videoFile;
  final List<Duration>? timestamps;

  const EditPhotoScreen({
    super.key,
    required this.photos,
    required this.photoCount,
    required this.isMirrored,
    this.videoFile,
    this.timestamps,
  });

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
      onStartUpload: () => UploadProgressDialog.show(context, provider),
      onShowError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.google_drive.error(error: error))),
        );
      },
      capturePaper: () => _capturePaperIndependent(provider),
      captureStrip: () => _captureStripIndependent(provider),
    );
  }

  Future<void> _handleSaveRequest(BuildContext context) async {
    final provider = context.read<EditPhotoProvider>();
    _showSimpleLoading(context);
    bool dialogPopped = false;

    try {
      final files = await provider.generateAllFiles(
        capturePaper: () => _capturePaperIndependent(provider),
        captureStrip: () => _captureStripIndependent(provider),
      );

      if (files != null && files.isNotEmpty) {
        if (kIsWeb) {
          final result = await saveFilesToDeviceWeb(files);
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
            dialogPopped = true;
          }
          if (context.mounted) {
            if (result == 'success' || result == 'downloaded') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.editor.saveToDeviceSuccess)),
              );
            } else if (result == 'aborted') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.editor.saveToDeviceCancel)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    t.editor.saveError(error: 'Failed to save files'),
                  ),
                ),
              );
            }
          }
          return;
        }

        final tempDir = await getTemporaryDirectory();

        for (final entry in files.entries) {
          final fileName = entry.key;
          final bytes = entry.value;

          if (fileName.endsWith('.mp4') || fileName.endsWith('.webm')) {
            final file = File('${tempDir.path}/$fileName');
            await file.writeAsBytes(bytes);
            await Gal.putVideo(file.path);
          } else {
            // Assume it's an image
            await Gal.putImageBytes(bytes);
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.editor.saveSuccess),
              action: SnackBarAction(
                label: t.editor.viewNow,
                onPressed: () async {
                  await Gal.open();
                },
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.editor.saveError(error: 'No files generated')),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.editor.saveError(error: e.toString()))),
        );
      }
    } finally {
      if (!dialogPopped && context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
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
                children: [const LoadingIndicator()],
              ),
            ),
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
      final bool paperIsLandscape = isLandscape && !provider.printTwoCopies;

      final strip = PhotoStrip(
        photos: provider.capturedPhotos,
        frame: provider.selectedFrame,
        selectedFilter: provider.selectedFilter,
        filterIntensity: provider.filterIntensity,
        isMirrored: provider.isMirrored,
      );

      final Widget content;
      if (provider.printTwoCopies) {
        if (isLandscape) {
          content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(fit: FlexFit.loose, child: strip),
              const SizedBox(height: 4),
              Flexible(fit: FlexFit.loose, child: strip),
            ],
          );
        } else {
          content = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(fit: FlexFit.loose, child: strip),
              const SizedBox(width: 4),
              Flexible(fit: FlexFit.loose, child: strip),
            ],
          );
        }
      } else {
        content = strip;
      }

      final widget = VirtualPaper(
        isLandscape: paperIsLandscape,
        child: content,
      );

      // Render ở độ phân giải cao cho giấy in 4x6 (khoảng 1200x1800px)
      final double targetWidth = paperIsLandscape ? 1800 : 1200;
      final double targetHeight = paperIsLandscape ? 1200 : 1800;

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

  Widget _buildPreviewPanel({
    required EditPhotoProvider provider,
    required bool isMobile,
  }) {
    return PreviewPanel(
      stripController: _stripController,
      paperController: _paperController,
      photos: provider.capturedPhotos,
      selectedFrame: provider.selectedFrame,
      availableFrames: provider.filteredFrames,
      printTwoCopies: provider.printTwoCopies,
      showPaperPreview: provider.showPaperPreview,
      onTogglePrintTwoCopies: provider.togglePrintTwoCopies,
      onTogglePaperPreview: provider.togglePaperPreview,
      videoRecapFile: provider.videoRecapFile,
      photoTimestamps: provider.photoTimestamps,
      selectedFilter: provider.selectedFilter,
      filterIntensity: provider.filterIntensity,
      isMirrored: provider.isMirrored,
      isMobile: isMobile,
    );
  }

  Widget _buildEditorPanel({
    required BuildContext context,
    required EditPhotoProvider provider,
    required bool isMobile,
  }) {
    return EditorPanel(
      availableFrames: provider.filteredFrames,
      selectedFrame: provider.selectedFrame.path,
      onFrameSelected: provider.setSelectedFrame,
      photos: provider.capturedPhotos,
      videoRecapFile: provider.videoRecapFile,
      photoTimestamps: provider.photoTimestamps,
      isProcessing: provider.isProcessing,
      filters: provider.filters,
      selectedFilter: provider.selectedFilter,
      filterIntensity: provider.filterIntensity,
      onFilterSelected: provider.setFilter,
      onFilterIntensityChanged: provider.setFilterIntensity,
      onQRRequested: StorageConfig.activeStorage == StorageType.none
          ? null
          : () => _handleQRRequest(context),
      onSaveRequested: () => _handleSaveRequest(context),
      isMobile: isMobile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditPhotoProvider>(
      create: (_) => locator<EditPhotoProvider>()
        ..initWithPhotoboothData(
          photos: widget.photos,
          photoCount: widget.photoCount,
          isMirrored: widget.isMirrored,
          videoFile: widget.videoFile,
          timestamps: widget.timestamps,
        ),
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          final bool isMobile =
              ResponsiveBreakpoints.of(context).smallerThan(DESKTOP) ||
              MediaQuery.sizeOf(context).height < 500;

          final bool isLandscape =
              MediaQuery.orientationOf(context) == Orientation.landscape;

          return Consumer<EditPhotoProvider>(
            builder: (context, editPhotoProvider, child) {
              return Scaffold(
                backgroundColor: colorScheme.surface,
                bottomNavigationBar: isMobile
                    ? SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: isLandscape ? 0 : 0,
                          ),
                          child: SizedBox(
                            height: isLandscape ? 48 : null,
                            child: Row(
                              children: [
                                if (kIsWeb) ...[
                                  if (StorageConfig.activeStorage !=
                                      StorageType.none) ...[
                                    Expanded(
                                      flex: 1,
                                      child: SecondaryButton(
                                        onTap: () => _handleQRRequest(context),
                                        icon: Icons.qr_code_2_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  Expanded(
                                    flex: 1,
                                    child: SecondaryButton(
                                      onTap: () => _handleSaveRequest(context),
                                      icon: Icons.save_alt_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ] else ...[
                                  Expanded(
                                    flex: 1,
                                    child: SecondaryButton(
                                      onTap: () => _handleSaveRequest(context),
                                      icon: Icons.save_alt_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                // Print Button
                                Expanded(
                                  flex: 3,
                                  child: PrimaryButton(
                                    onTap: () {
                                      // TODO: Implement print logic
                                    },
                                    label: t.editor.printPhoto,
                                    icon: Icons.local_printshop_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : null,
                body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar.medium(
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        leading: Center(
                          child: IconButton.filledTonal(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.secondary.withValues(
                                alpha: 0.08,
                              ),
                              foregroundColor: colorScheme.secondary,
                            ),
                          ),
                        ),
                        title: Text(
                          t.editor.title,
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        centerTitle: true,
                      ),
                    ];
                  },
                  body: SafeArea(
                    top: false,
                    child: Padding(
                      padding: isMobile
                          ? EdgeInsets.symmetric(
                              horizontal: isLandscape ? 8.0 : 12.0,
                              vertical: isLandscape ? 4.0 : 8.0,
                            )
                          : const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: isMobile
                                ? (isLandscape
                                      // Landscape mobile: Row layout
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Left: Preview (scrollable)
                                            Expanded(
                                              flex: 2,
                                              child: SingleChildScrollView(
                                                child: _buildPreviewPanel(
                                                  provider: editPhotoProvider,
                                                  isMobile: true,
                                                ),
                                              ),
                                            ),
                                            const Gap(8),
                                            // Right: Editor (scrollable)
                                            Expanded(
                                              flex: 3,
                                              child: SingleChildScrollView(
                                                child: _buildEditorPanel(
                                                  context: context,
                                                  provider: editPhotoProvider,
                                                  isMobile: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      // Portrait mobile: vertical scroll
                                      : SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              _buildPreviewPanel(
                                                provider: editPhotoProvider,
                                                isMobile: true,
                                              ),
                                              const Gap(16),
                                              _buildEditorPanel(
                                                context: context,
                                                provider: editPhotoProvider,
                                                isMobile: true,
                                              ),
                                            ],
                                          ),
                                        ))
                                : Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildPreviewPanel(
                                          provider: editPhotoProvider,
                                          isMobile: false,
                                        ),
                                      ),
                                      const Gap(24),
                                      Expanded(
                                        flex: 3,
                                        child: _buildEditorPanel(
                                          context: context,
                                          provider: editPhotoProvider,
                                          isMobile: false,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
