import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screenshot/screenshot.dart';
import 'package:th_photobooth/components/google_sign_in_button.dart';
import 'package:th_photobooth/components/language_switcher.dart';
import 'package:th_photobooth/components/loading_indicator.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/components/secondary_button.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/storage_config.dart';
import 'package:th_photobooth/core/di/service_locator.dart';
import 'package:th_photobooth/features/edit_photo/providers/edit_photo.provider.dart';
import 'package:th_photobooth/features/edit_photo/widgets/completion_check_animation.dart';
import 'package:th_photobooth/features/edit_photo/widgets/editor_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/photo_strip.dart';
import 'package:th_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/qr_share_panel.dart';
import 'package:th_photobooth/features/edit_photo/widgets/upload_progress_dialog.dart';
import 'package:th_photobooth/helper/web_download_noop.dart'
    if (dart.library.js_interop) 'package:th_photobooth/helper/web_download_web.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/print_service.dart';

class EditPhotoScreen extends StatefulWidget {
  final List<XFile> photos;
  final int photoCount;
  final bool photoIsMirrored;
  final bool videoIsMirrored;
  final XFile? videoFile;
  final List<Duration>? timestamps;

  const EditPhotoScreen({
    super.key,
    required this.photos,
    required this.photoCount,
    required this.photoIsMirrored,
    required this.videoIsMirrored,
    this.videoFile,
    this.timestamps,
  });

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final ScreenshotController _stripController = ScreenshotController();
  final ScreenshotController _paperController = ScreenshotController();
  bool _showCompletionAnimation = false;

  /// True once the guest has saved or printed. Together with an uploaded
  /// section it tells the capture screen to start a fresh session; a plain
  /// Back keeps the photos so a shot can be retaken.
  bool _sessionFinished = false;

  void _showMessage(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }

  void _playCompletionAnimation() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;

    setState(() => _showCompletionAnimation = true);
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showCompletionAnimation = false);
    });
  }

  Future<void> _handleQRRequest(BuildContext context) async {
    final provider = context.read<EditPhotoProvider>();

    await provider.handleQRRequest(
      onHideLoading: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      onShowLogin: () {
        showWebLoginDialog(
          context,
          onLoginSuccess: () => _handleQRRequest(context),
        );
      },
      onStartUpload: () => UploadProgressDialog.show(context, provider),
      onUploadComplete: _playCompletionAnimation,
      onShowError: (error) {
        debugPrint('QR upload failed: $error');
        if (!context.mounted) return;
        _showMessage(
          context,
          t.google_drive.failed,
          actionLabel: t.editor.retry,
          onAction: () => _handleQRRequest(context),
        );
      },
      captureStrip: () => _captureStripIndependent(provider),
      capturePrintContent: () => _capturePrintContentIndependent(provider),
    );
  }

  Future<void> _handleSaveRequest(BuildContext context) async {
    final provider = context.read<EditPhotoProvider>();
    _showSimpleLoading(context);
    bool dialogPopped = false;

    try {
      final files = await provider.generateAllFiles(
        captureStrip: () => _captureStripIndependent(provider),
        capturePrintContent: () => _capturePrintContentIndependent(provider),
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
              _sessionFinished = true;
              _showMessage(context, t.editor.saveToDeviceSuccess);
            } else if (result == 'aborted') {
              _showMessage(context, t.editor.saveToDeviceCancel);
            } else {
              debugPrint('Web save failed: $result');
              _showMessage(
                context,
                t.editor.genericError,
                actionLabel: t.editor.retry,
                onAction: () => _handleSaveRequest(context),
              );
            }
          }
          return;
        }

        final tempDir = await getTemporaryDirectory();

        for (final entry in files.entries) {
          final fileName = entry.key;
          final bytes = entry.value;

          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);

          if (fileName.endsWith('.mp4') || fileName.endsWith('.webm')) {
            await Gal.putVideo(file.path);
          } else {
            await Gal.putImage(file.path);
          }
        }

        _sessionFinished = true;
        if (context.mounted) {
          _showMessage(
            context,
            t.editor.saveSuccess,
            actionLabel: t.editor.viewNow,
            onAction: () => Gal.open(),
          );
        }
      } else {
        debugPrint('Save failed: no files generated');
        if (context.mounted) {
          _showMessage(
            context,
            t.editor.genericError,
            actionLabel: t.editor.retry,
            onAction: () => _handleSaveRequest(context),
          );
        }
      }
    } catch (e) {
      debugPrint('Save failed: $e');
      if (context.mounted) {
        _showMessage(
          context,
          t.editor.genericError,
          actionLabel: t.editor.retry,
          onAction: () => _handleSaveRequest(context),
        );
      }
    } finally {
      if (!dialogPopped && context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handlePrintRequest(BuildContext context) async {
    final provider = context.read<EditPhotoProvider>();
    _showSimpleLoading(context);
    bool dialogPopped = false;

    try {
      final files = await provider.generateAllFiles(
        captureStrip: () => _captureStripIndependent(provider),
        capturePrintContent: () => _capturePrintContentIndependent(provider),
      );

      if (files != null && files.isNotEmpty) {
        final printBytes =
            _findFileBytes(files, 'anh_dem_di_in.png') ??
            _findFileBytes(files, 'anh_dem_di_in.jpg') ??
            _findFileBytes(files, 'anh_da_ghep_khung.jpg');

        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
          dialogPopped = true;
        }

        if (context.mounted && printBytes != null) {
          final printSuccess = await PrintService.printImage(
            printBytes,
            name: 'photobooth_${provider.sessionId ?? 'photo'}',
          );

          if (printSuccess) _sessionFinished = true;
          if (context.mounted) {
            if (printSuccess) {
              _showMessage(context, t.editor.printSuccess);
            } else {
              _showMessage(
                context,
                t.editor.printFailed,
                actionLabel: t.editor.retry,
                onAction: () => _handlePrintRequest(context),
              );
            }
          }
        }
      } else {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
          dialogPopped = true;
        }
        debugPrint('Print failed: no files generated');
        if (context.mounted) {
          _showMessage(
            context,
            t.editor.printFailed,
            actionLabel: t.editor.retry,
            onAction: () => _handlePrintRequest(context),
          );
        }
      }
    } catch (e) {
      debugPrint('Print failed: $e');
      if (!dialogPopped && context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        dialogPopped = true;
      }
      if (context.mounted) {
        _showMessage(
          context,
          t.editor.printFailed,
          actionLabel: t.editor.retry,
          onAction: () => _handlePrintRequest(context),
        );
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
            child: Material(
              type: MaterialType.transparency,
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
                    const LoadingIndicator(),
                    const Gap(20),
                    Text(
                      t.editor.processing,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
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
        isMirrored: provider.photoIsMirrored,
        galleryUrl: provider.galleryUrl,
        qrCorner: provider.qrCorner,
      );

      return await _stripController.captureFromWidget(
        Material(color: Colors.transparent, child: widget),
        targetSize: provider.selectedFrame.size,
        pixelRatio: 1.0,
      );
    } catch (e) {
      debugPrint('Error capturing strip independently: $e');
      return null;
    }
  }

  Uint8List? _findFileBytes(Map<String, Uint8List> files, String suffix) {
    for (final entry in files.entries) {
      if (entry.key.endsWith(suffix)) return entry.value;
    }
    return null;
  }

  Future<Uint8List?> _capturePrintContentIndependent(
    EditPhotoProvider provider,
  ) async {
    try {
      final widget = PhotoPrintPreview(
        photos: provider.capturedPhotos,
        selectedFrame: provider.selectedFrame,
        selectedFilter: provider.selectedFilter,
        filterIntensity: provider.filterIntensity,
        photoIsMirrored: provider.photoIsMirrored,
        galleryUrl: provider.galleryUrl,
        qrCorner: provider.qrCorner,
        showQrPlaceholder: StorageConfig.activeStorage != StorageType.none,
      );

      return await _paperController.captureFromWidget(
        Material(color: Colors.white, child: widget),
        targetSize: AppConfig.printPixelSize,
        pixelRatio: 1.0,
      );
    } catch (e) {
      debugPrint('Error capturing print content independently: $e');
      return null;
    }
  }

  Widget _buildPreviewPanel({
    required EditPhotoProvider provider,
    required bool isMobile,
  }) {
    return PreviewPanel(
      paperController: _paperController,
      photos: provider.capturedPhotos,
      selectedFrame: provider.selectedFrame,
      availableFrames: provider.filteredFrames,
      videoRecapFile: provider.videoRecapFile,
      photoTimestamps: provider.photoTimestamps,
      selectedFilter: provider.selectedFilter,
      filterIntensity: provider.filterIntensity,
      photoIsMirrored: provider.photoIsMirrored,
      videoIsMirrored: provider.videoIsMirrored,
      isMobile: isMobile,
      galleryUrl: provider.galleryUrl,
      qrCorner: provider.qrCorner,
      showQrPlaceholder: StorageConfig.activeStorage != StorageType.none,
    );
  }

  Widget _buildRightPanel({
    required BuildContext context,
    required EditPhotoProvider provider,
    required bool isMobile,
  }) {
    final requiresQr =
        kIsWeb && StorageConfig.activeStorage != StorageType.none;
    final isReady = provider.isSectionReady && provider.galleryUrl != null;
    final panel = _showCompletionAnimation
        ? const CompletionCheckAnimation(
            key: ValueKey('completion-check-animation'),
          )
        : isReady
        ? QrSharePanel(
            key: const ValueKey('qr-share-panel'),
            url: provider.galleryUrl!,
            onDownload: () => _handleSaveRequest(context),
            isMobile: isMobile,
          )
        : EditorPanel(
            key: const ValueKey('editor-panel'),
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
            onSaveRequested: !requiresQr || provider.isSectionReady
                ? () => _handleSaveRequest(context)
                : null,
            onCompleteRequested: requiresQr
                ? () => _handleQRRequest(context)
                : () => _handlePrintRequest(context),
            completeLabel: requiresQr ? t.editor.createQr : t.editor.printPhoto,
            requiresQr: requiresQr,
            photoIsMirrored: provider.photoIsMirrored,
            qrCorner: provider.qrCorner,
            onQrCornerChanged: StorageConfig.activeStorage != StorageType.none
                ? provider.setQrCorner
                : null,
            isMobile: isMobile,
          );

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 550);
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) => ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [...previousChildren, ?currentChild],
        ),
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: panel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditPhotoProvider>(
      create: (_) => locator<EditPhotoProvider>()
        ..initWithPhotoboothData(
          photos: widget.photos,
          photoCount: widget.photoCount,
          photoIsMirrored: widget.photoIsMirrored,
          videoIsMirrored: widget.videoIsMirrored,
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
              final requiresQr =
                  kIsWeb && StorageConfig.activeStorage != StorageType.none;
              final completeLabel = requiresQr
                  ? t.editor.createQr
                  : t.editor.printPhoto;
              final backButton = IconButton.filledTonal(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.maybePop(context),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.secondary.withValues(
                    alpha: 0.08,
                  ),
                  foregroundColor: colorScheme.secondary,
                ),
              );

              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (didPop) return;
                  Navigator.pop(
                    context,
                    _sessionFinished || editPhotoProvider.isSectionReady,
                  );
                },
                child: Scaffold(
                  backgroundColor: colorScheme.surface,
                  appBar: (isMobile && isLandscape)
                      ? null
                      : AppBar(
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          backgroundColor: Colors.transparent,
                          leadingWidth: isMobile ? null : 64,
                          leading: isMobile
                              ? Center(child: backButton)
                              : Row(children: [const Gap(16), backButton]),
                          actions: [
                            const LanguageSwitcher(isMobile: true),
                            const Gap(16),
                          ],
                        ),
                  bottomNavigationBar:
                      (isMobile &&
                          !isLandscape &&
                          !editPhotoProvider.isSectionReady)
                      ? SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Row(
                              children: [
                                if (kIsWeb) ...[
                                  Expanded(
                                    flex: 1,
                                    child: Tooltip(
                                      message: editPhotoProvider.isSectionReady
                                          ? t.editor.saveToDevice
                                          : t.editor.completeBeforeDownload,
                                      child: SecondaryButton(
                                        onTap: editPhotoProvider.isSectionReady
                                            ? () => _handleSaveRequest(context)
                                            : null,
                                        semanticLabel: t.editor.saveToDevice,
                                        icon: Icons.save_alt_rounded,
                                        height: 56,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ] else ...[
                                  Expanded(
                                    flex: 1,
                                    child: Tooltip(
                                      message: t.editor.saveToDevice,
                                      child: SecondaryButton(
                                        onTap: () =>
                                            _handleSaveRequest(context),
                                        semanticLabel: t.editor.saveToDevice,
                                        icon: Icons.save_alt_rounded,
                                        height: 56,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                Expanded(
                                  flex: 3,
                                  child: PrimaryButton(
                                    onTap: requiresQr
                                        ? () => _handleQRRequest(context)
                                        : () => _handlePrintRequest(context),
                                    label: completeLabel,
                                    height: 56,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                  body: SafeArea(
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
                                              flex: 3,
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: _buildPreviewPanel(
                                                      provider:
                                                          editPhotoProvider,
                                                      isMobile: true,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: IconButton.filledTonal(
                                                      tooltip:
                                                          MaterialLocalizations.of(
                                                            context,
                                                          ).backButtonTooltip,
                                                      icon: const Icon(
                                                        Icons
                                                            .arrow_back_ios_new_rounded,
                                                        size: 16,
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.maybePop(
                                                            context,
                                                          ),
                                                      style: IconButton.styleFrom(
                                                        backgroundColor:
                                                            colorScheme.surface
                                                                .withValues(
                                                                  alpha: 0.8,
                                                                ),
                                                        foregroundColor:
                                                            colorScheme
                                                                .secondary,
                                                        minimumSize:
                                                            const Size.square(
                                                              44,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Gap(8),
                                            // Right: Editor
                                            Expanded(
                                              flex: 3,
                                              child: _buildRightPanel(
                                                context: context,
                                                provider: editPhotoProvider,
                                                isMobile: true,
                                              ),
                                            ),
                                          ],
                                        )
                                      // Portrait mobile: Column layout (no page scroll)
                                      : Column(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: _buildPreviewPanel(
                                                provider: editPhotoProvider,
                                                isMobile: true,
                                              ),
                                            ),
                                            const Gap(12),
                                            Expanded(
                                              flex: 3,
                                              child: _buildRightPanel(
                                                context: context,
                                                provider: editPhotoProvider,
                                                isMobile: true,
                                              ),
                                            ),
                                          ],
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
                                        child: _buildRightPanel(
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
