import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_photobooth/components/photobooth_header.dart';
import 'package:my_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:my_photobooth/features/photobooth/widgets/action_buttons_widget.dart';
import 'package:my_photobooth/features/photobooth/widgets/camera_preview_widget.dart';
import 'package:my_photobooth/features/photobooth/widgets/photo_previews_panel.dart';
import 'package:my_photobooth/features/photobooth/widgets/previews_footer.dart';
import 'package:my_photobooth/features/photobooth/widgets/settings_panel.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PhotoboothScreen extends StatefulWidget {
  const PhotoboothScreen({super.key});

  @override
  State<PhotoboothScreen> createState() => _PhotoboothScreenState();
}

class _PhotoboothScreenState extends State<PhotoboothScreen> {
  final GlobalKey _cameraPreviewKey = GlobalKey();

  void _showSettingsBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: colorScheme.secondary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<PhotoboothProvider>();
    final bool isMobile =
        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: (!isMobile && !provider.isFullscreen)
          ? FloatingActionButton.small(
              onPressed: () => provider.enterFullscreen(),
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.primary,
              elevation: 8,
              child: const Icon(Icons.fullscreen_rounded),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
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
                      ? const Center(child: CircularProgressIndicator())
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
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
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
          const PreviewsFooter(),
        ],
      ),
    );
  }
}
