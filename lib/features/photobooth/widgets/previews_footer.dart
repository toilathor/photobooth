import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/features/edit_photo/screens/edit_photo.screen.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class PreviewsFooter extends StatelessWidget {
  const PreviewsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final bool isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLandscape) ...[
          const Gap(16),
          Text(
            t.preview.captured(
              current: provider.capturedPhotos.length,
              total: provider.selectedPhotoCount,
            ),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const Gap(24),
        ] else
          const Gap(8),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onTap:
                (provider.capturedPhotos.length >=
                        provider.selectedPhotoCount &&
                    !provider.isCapturing)
                ? () async {
                    final bool photoRequiresFlip = provider.photoRequiresFlip;
                    final bool videoRequiresFlip = provider.videoRequiresFlip;

                    try {
                      await provider.stopCamera();
                    } catch (_) {}
                    if (!context.mounted) return;

                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => EditPhotoScreen(
                          photos: provider.capturedPhotos,
                          photoCount: provider.selectedPhotoCount,
                          photoIsMirrored: photoRequiresFlip,
                          videoIsMirrored: videoRequiresFlip,
                          videoFile: provider.videoRecapFile,
                          timestamps: provider.photoTimestamps,
                        ),
                      ),
                    );

                    if (context.mounted) {
                      try {
                        await provider.clearSession();
                        provider.startCamera();
                      } catch (_) {}
                    }
                  }
                : null,
            height: isLandscape ? 48 : 56,
            label: provider.capturedPhotos.length >= provider.selectedPhotoCount
                ? t.preview.continue_btn
                : t.preview.not_enough_photos,
            icon: Icons.arrow_forward_ios_rounded,
          ),
        ),
      ],
    );
  }
}
