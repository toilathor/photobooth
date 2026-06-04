import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/components/loading_indicator.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget(CameraController cameraController, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final bool isMobile = MediaQuery.sizeOf(context).shortestSide < 600;

    final controller = provider.cameraController;
    double cameraAspectRatio = 1.0;
    double previewWidth = 480;
    if (controller != null && controller.value.isInitialized) {
      cameraAspectRatio = controller.value.aspectRatio;
      if (controller.value.previewSize != null) {
        previewWidth = controller.value.previewSize!.width;
      }
      if (!kIsWeb) {
        final bool isPortrait =
            MediaQuery.orientationOf(context) == Orientation.portrait;
        if (isPortrait && cameraAspectRatio > 1) {
          cameraAspectRatio = 1 / cameraAspectRatio;
        } else if (!isPortrait && cameraAspectRatio < 1) {
          cameraAspectRatio = 1 / cameraAspectRatio;
        }
      }
    }

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child:
              provider.cameraController == null ||
                  provider.cameraController?.value.isInitialized != true ||
                  provider.isSwitchingCamera
              ? Container(
                  color: colorScheme.surfaceContainer,
                  child: const Center(child: LoadingIndicator()),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // Layer 1: Filtered Camera Preview
                    ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: previewWidth,
                          child: AspectRatio(
                            aspectRatio: cameraAspectRatio,
                            child: Transform.scale(
                              scaleX: provider.isMirrored ? -1 : 1,
                              child: CameraPreview(provider.cameraController!),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Layer 2: UI Overlays (Not Filtered, Not Mirrored)
                    Positioned.fill(
                      child: Stack(
                        children: [
                          if (AppConfig.cameras.length > 1)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: _ControlButton(
                                icon: Icons.flip_camera_ios_rounded,
                                onTap:
                                    (provider.isDoneTakingPhotos ||
                                        provider.isCapturing)
                                    ? null
                                    : () => provider.toggleCamera(),
                                colorScheme: colorScheme,
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _ControlButton(
                              icon: Icons.flip_rounded,
                              onTap:
                                  (provider.isDoneTakingPhotos ||
                                      provider.isCapturing)
                                  ? null
                                  : () => provider.toggleMirror(),
                              colorScheme: colorScheme,
                            ),
                          ),
                          if (provider.isCapturing &&
                              provider.currentCountdownValue > 0)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: provider.isPreparing
                                      ? AnimatedTextKit(
                                          animatedTexts: [
                                            ScaleAnimatedText(
                                              t.actions.prepare,
                                              duration: const Duration(
                                                milliseconds: 1000,
                                              ),
                                              textStyle: GoogleFonts.inter(
                                                fontSize: isMobile ? 56 : 96,
                                                fontWeight: FontWeight.w900,
                                                color: colorScheme.secondary,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 20,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.7),
                                                    offset: const Offset(0, 4),
                                                  ),
                                                  Shadow(
                                                    blurRadius: 40,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          isRepeatingAnimation: false,
                                        )
                                      : AnimatedTextKit(
                                          key: ValueKey(
                                            provider.currentCountdownValue,
                                          ),
                                          animatedTexts: [
                                            ScaleAnimatedText(
                                              '${provider.currentCountdownValue}',
                                              textStyle: GoogleFonts.outfit(
                                                fontSize: isMobile ? 80 : 140,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 30,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.7),
                                                    offset: const Offset(0, 6),
                                                  ),
                                                  Shadow(
                                                    blurRadius: 60,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ],
                                              ),
                                              duration: const Duration(
                                                milliseconds: 800,
                                              ),
                                            ),
                                          ],
                                          isRepeatingAnimation: false,
                                        ),
                                ),
                              ),
                            ),
                          if (provider.isAutoCapturing)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: _CancelButton(
                                  onTap: () => provider.cancelAutoCapture(),
                                  colorScheme: colorScheme,
                                ),
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
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _CancelButton({required this.onTap, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.actions.cancel,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  const _ControlButton({
    required this.icon,
    this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: isEnabled ? 1.0 : 0.5),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}
