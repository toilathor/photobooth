import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:th_photobooth/components/loading_indicator.dart';
import 'package:th_photobooth/components/photobooth_header.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/features/photobooth/widgets/action_buttons_widget.dart';
import 'package:th_photobooth/features/photobooth/widgets/camera_preview_widget.dart';
import 'package:th_photobooth/features/photobooth/widgets/photo_previews_panel.dart';
import 'package:th_photobooth/features/photobooth/widgets/previews_footer.dart';
import 'package:th_photobooth/features/photobooth/widgets/settings_panel.dart';
import 'package:th_photobooth/features/photobooth/widgets/shortcut_guide_widget.dart';

class PhotoboothScreen extends StatefulWidget {
  const PhotoboothScreen({super.key});

  @override
  State<PhotoboothScreen> createState() => _PhotoboothScreenState();
}

class _PhotoboothScreenState extends State<PhotoboothScreen>
    with WidgetsBindingObserver {
  final GlobalKey _cameraPreviewKey = GlobalKey();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final provider = context.read<PhotoboothProvider>();
    if (state == AppLifecycleState.paused) {
      provider.stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      provider.startCamera();
      // Re-focus node when app resumes
      _keyboardFocusNode.requestFocus();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final provider = context.read<PhotoboothProvider>();
    final logicalKey = event.logicalKey;

    if (logicalKey == LogicalKeyboardKey.space) {
      if (provider.isCapturing) {
        provider.cancelAutoCapture();
      } else {
        provider.startAutoCapture();
      }
    } else if (logicalKey == LogicalKeyboardKey.keyS) {
      provider.toggleCamera();
    } else if (logicalKey == LogicalKeyboardKey.keyM) {
      provider.toggleMirror();
    } else if (logicalKey == LogicalKeyboardKey.keyV) {
      provider.toggleVideoRecap(!provider.isVideoRecap);
    } else if (logicalKey == LogicalKeyboardKey.keyR) {
      provider.resetCapture();
    } else if (logicalKey == LogicalKeyboardKey.keyF) {
      provider.enterFullscreen();
    }
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final bool isLandscape =
            MediaQuery.orientationOf(context) == Orientation.landscape;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.sizeOf(context).height * (isLandscape ? 0.95 : 0.7),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Gap(24),
                        const SettingsPanel(isBottomSheet: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<PhotoboothProvider>();
    final bool isMobile =
        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP) ||
        MediaQuery.sizeOf(context).height < 500;
    final bool isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final Widget screenContent = Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: (!isMobile && !provider.isFullscreen)
          ? FloatingActionButton.small(
              onPressed: () => provider.enterFullscreen(),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 4,
              child: const Icon(Icons.fullscreen_rounded),
            )
          : null,
      bottomNavigationBar: isMobile
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: const PreviewsFooter(),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Hide header in landscape mobile to save vertical space
            if (!(isMobile && isLandscape))
              PhotoboothHeader(
                trailing: isMobile
                    ? IconButton(
                        icon: Icon(
                          Icons.settings_rounded,
                          color: colorScheme.secondary,
                          size: 28,
                        ),
                        onPressed: () => _showSettingsBottomSheet(context),
                      )
                    : null,
              ),
            Expanded(
              child: isMobile
                  ? (provider.cameraController == null
                        ? const Center(child: LoadingIndicator())
                        : isLandscape
                        ? _MobileLandscapePanel(
                            provider.cameraController!,
                            cameraPreviewKey: _cameraPreviewKey,
                            onSettingsTap: () =>
                                _showSettingsBottomSheet(context),
                          )
                        : _MobilePanel(
                            provider.cameraController!,
                            cameraPreviewKey: _cameraPreviewKey,
                          ))
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(flex: 5, child: SettingsPanel()),
                          const Gap(24),
                          Expanded(
                            flex: 12,
                            child: provider.cameraController == null
                                ? const Center(child: LoadingIndicator())
                                : _CenterPanel(
                                    provider.cameraController!,
                                    cameraPreviewKey: _cameraPreviewKey,
                                  ),
                          ),
                          const Gap(24),
                          const Expanded(flex: 4, child: PhotoPreviewsPanel()),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          if (!_keyboardFocusNode.hasFocus) {
            _keyboardFocusNode.requestFocus();
          }
        },
        child: Stack(
          children: [
            screenContent,
            if (kIsWeb && !isMobile) const ShortcutGuideWidget(),
          ],
        ),
      ),
    );
  }
}

class _CenterPanel extends StatelessWidget {
  const _CenterPanel(this.controller, {required this.cameraPreviewKey});

  final CameraController controller;
  final Key cameraPreviewKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: CameraPreviewWidget(controller, key: cameraPreviewKey)),
        const Gap(24),
        const ActionButtonsWidget(),
        const Gap(24),
      ],
    );
  }
}

class _MobilePanel extends StatelessWidget {
  const _MobilePanel(this.controller, {required this.cameraPreviewKey});

  final CameraController controller;
  final Key cameraPreviewKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          CameraPreviewWidget(controller, key: cameraPreviewKey),
          const Gap(16),
          const ActionButtonsWidget(),
          const Gap(16),
          const PhotoPreviewsPanel(isMobile: true),
        ],
      ),
    );
  }
}

/// Landscape-specific mobile layout:
/// Row with Camera on the left (bounded by available height) and
/// scrollable controls + thumbnails on the right.
class _MobileLandscapePanel extends StatelessWidget {
  const _MobileLandscapePanel(
    this.controller, {
    required this.cameraPreviewKey,
    required this.onSettingsTap,
  });

  final CameraController controller;
  final Key cameraPreviewKey;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Left: Camera preview (bounded by height, not scrollable)
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: CameraPreviewWidget(controller, key: cameraPreviewKey),
          ),
        ),
        // Right: Actions + Thumbnails (scrollable vertically)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Settings icon in top-right
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.settings_rounded,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                  onPressed: onSettingsTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Expanded(child: const PhotoPreviewsPanel(isMobile: true)),
              const Gap(16),
              const ActionButtonsWidget(),
              const Gap(8),
            ],
          ),
        ),
      ],
    );
  }
}
