import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_photobooth/components/photobooth_header.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/features/photobooth/widgets/action_buttons_widget.dart';
import 'package:my_photobooth/features/photobooth/widgets/camera_preview_widget.dart';
import 'package:my_photobooth/features/photobooth/widgets/photo_previews_panel.dart';
import 'package:my_photobooth/features/photobooth/widgets/settings_panel.dart';
import 'package:provider/provider.dart';

class PhotoboothScreen extends StatefulWidget {
  const PhotoboothScreen({super.key});

  @override
  State<PhotoboothScreen> createState() => _PhotoboothScreenState();
}

class _PhotoboothScreenState extends State<PhotoboothScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<PhotoboothProvider>();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: !provider.isFullscreen
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
            const PhotoboothHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 1, child: SettingsPanel()),
                    const Gap(24),
                    Expanded(
                      flex: 3,
                      child: provider.cameraController == null
                          ? const Center(child: CircularProgressIndicator())
                          : _CenterPanel(provider.cameraController!),
                    ),
                    const Gap(24),
                    const Expanded(flex: 1, child: PhotoPreviewsPanel()),
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
  const _CenterPanel(this.controller);

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: CameraPreviewWidget(controller)),
        const Gap(24),
        const ActionButtonsWidget(),
        const Gap(24),
      ],
    );
  }
}
