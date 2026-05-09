import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.provider.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.screen.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:provider/provider.dart';

class PhotoPreviewsPanel extends StatelessWidget {
  const PhotoPreviewsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Column(
            children: List.generate(
              provider.selectedPhotoCount,
              (index) => Flexible(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: provider.capturedPhotos.length > index
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: kIsWeb
                                        ? Image.network(
                                            provider.capturedPhotos[index].path,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              if (progress == null) {
                                                return child;
                                              }
                                              return const _SkeletonLoader();
                                            },
                                          )
                                        : Image.file(
                                            File(
                                              provider
                                                  .capturedPhotos[index].path,
                                            ),
                                            fit: BoxFit.cover,
                                            frameBuilder: (
                                              context,
                                              child,
                                              frame,
                                              wasSync,
                                            ) {
                                              if (wasSync) return child;
                                              return frame != null
                                                  ? child
                                                  : const _SkeletonLoader();
                                            },
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: provider.isCapturing
                                        ? null
                                        : () => provider.removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha:
                                              provider.isCapturing ? 0.2 : 0.5,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: provider.isCapturing
                                            ? Colors.white
                                                .withValues(alpha: 0.5)
                                            : Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : (provider.isCapturing &&
                                  provider.capturedPhotos.length == index)
                              ? const _SkeletonLoader()
                              : Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: colorScheme.secondary.withValues(
                                      alpha: 0.2,
                                    ),
                                    size: 48,
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(16),
        Text(
          'ĐÃ CHỤP ${provider.capturedPhotos.length}/${provider.selectedPhotoCount}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        const Gap(24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (provider.capturedPhotos.length >=
                        provider.selectedPhotoCount &&
                    !provider.isCapturing)
                ? () {
                    context.read<EditPhotoProvider>().initForPhotoCount(
                          provider.selectedPhotoCount,
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditPhotoScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              fixedSize: const Size(double.infinity, 60),
              elevation: 12,
              shadowColor: colorScheme.secondary.withValues(alpha: 0.4),
            ),
            label: Text(
              provider.capturedPhotos.length >= provider.selectedPhotoCount
                  ? 'TIẾP TỤC'
                  : 'CHỤP ĐỦ ẢNH ĐỂ TIẾP TỤC',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          ),
        ),
        const Gap(16),
      ],
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  const _SkeletonLoader();

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    _controller.value - 0.4,
                    _controller.value,
                    _controller.value + 0.4,
                  ],
                  colors: [
                    colorScheme.secondary.withValues(alpha: 0.05),
                    colorScheme.secondary.withValues(alpha: 0.4),
                    colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            );
          },
        ),
        Center(child: _PulseIcon(colorScheme: colorScheme)),
      ],
    );
  }
}

class _PulseIcon extends StatefulWidget {
  final ColorScheme colorScheme;
  const _PulseIcon({required this.colorScheme});

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(
        Icons.camera_alt_outlined,
        color: widget.colorScheme.secondary.withValues(alpha: 0.4),
        size: 32,
      ),
    );
  }
}
