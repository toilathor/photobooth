import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/core/configs/app_config.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget(CameraController cameraController, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: provider.cameraController == null ||
                !provider.cameraController!.value.isInitialized ||
                provider.isSwitchingCamera
            ? Container(
                color: colorScheme.surfaceContainer,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ),
                ),
              )
            : SizedBox(
                width: provider.cameraController!.value.previewSize!.height,
                height: provider.cameraController!.value.previewSize!.width,
                child: Transform(
                  alignment: Alignment.center,
                  transform: provider.isMirrored
                      ? Matrix4.rotationY(3.14159)
                      : Matrix4.identity(),
                  child: CameraPreview(
                    provider.cameraController!,
                    child: Stack(
                      children: [
                        // Important: Reverse the transform for children so they are not mirrored
                        Transform(
                          alignment: Alignment.center,
                          transform: provider.isMirrored
                              ? Matrix4.rotationY(3.14159)
                              : Matrix4.identity(),
                          child: Stack(
                            children: [
                              if (AppConfig.cameras.length > 1)
                                Positioned(
                                  top: 24,
                                  left: 24,
                                  child: _ControlButton(
                                    icon: Icons.flip_camera_ios_rounded,
                                    onTap: () => provider.toggleCamera(),
                                    colorScheme: colorScheme,
                                  ),
                                ),
                              Positioned(
                                top: 24,
                                right: 24,
                                child: _ControlButton(
                                  icon: Icons.flip_rounded,
                                  onTap: () => provider.toggleMirror(),
                                  colorScheme: colorScheme,
                                  isActive: provider.isMirrored,
                                ),
                              ),
                              if (provider.isCapturing &&
                                  provider.currentCountdownValue > 0)
                                Center(
                                  child: provider.isPreparing
                                      ? AnimatedTextKit(
                                          animatedTexts: [
                                            ScaleAnimatedText(
                                              t.actions.prepare,
                                              duration: const Duration(
                                                milliseconds: 1000,
                                              ),
                                              textStyle: GoogleFonts.inter(
                                                fontSize: 140,
                                                fontWeight: FontWeight.w900,
                                                color: colorScheme.secondary,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 20,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.5),
                                                    offset: const Offset(0, 4),
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
                                                fontSize: 140,
                                                fontWeight: FontWeight.w900,
                                                color: colorScheme.onSurface,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 30,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.4),
                                                    offset: const Offset(0, 10),
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
                            ],
                          ),
                        ),
                      ],
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
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.secondary.withValues(alpha: 0.9)
                : colorScheme.secondary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border:
                isActive ? Border.all(color: Colors.white, width: 1.5) : null,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              color: isActive ? colorScheme.primary : Colors.white,
              size: 28,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ),
    );
  }
}
