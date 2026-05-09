import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.provider.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.screen.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';

class PreviewsFooter extends StatelessWidget {
  const PreviewsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
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
                      MaterialPageRoute<void>(
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
