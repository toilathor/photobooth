import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/components/nudge_bounce.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/components/shortcut_keycap.dart';
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
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 14,
              letterSpacing: 0.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Gap(24),
        ] else
          const Gap(8),
        NudgeBounce(
          active: canOpenEditor(provider),
          child: SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onTap: canOpenEditor(provider)
                  ? () => openEditor(context, provider)
                  : null,
              shortcut: ShortcutKey.enter,
              height: isLandscape ? 48 : 56,
              // Say how far there is to go instead of a bare "not enough".
              label:
                  provider.capturedPhotos.length >= provider.selectedPhotoCount
                  ? t.preview.continue_btn
                  : t.preview.remaining(
                      count:
                          provider.selectedPhotoCount -
                          provider.capturedPhotos.length,
                    ),
              trailingIcon:
                  provider.capturedPhotos.length >= provider.selectedPhotoCount
                  ? Icons.arrow_forward_rounded
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Whether every photo is taken, so the guest can move on to editing.
bool canOpenEditor(PhotoboothProvider provider) =>
    provider.capturedPhotos.length >= provider.selectedPhotoCount &&
    !provider.isCapturing;

bool _openingEditor = false;

/// Opens the editor with the captured photos ("Tiếp tục" or Enter).
Future<void> openEditor(
  BuildContext context,
  PhotoboothProvider provider,
) async {
  // A double Enter must not open the editor twice.
  if (_openingEditor || !canOpenEditor(provider)) return;
  _openingEditor = true;
  try {
    final bool photoRequiresFlip = provider.photoRequiresFlip;
    final bool videoRequiresFlip = provider.videoRequiresFlip;

    try {
      await provider.stopCamera();
    } catch (_) {}
    if (!context.mounted) return;

    // The editor pops with `true` only once the session is
    // finished (shared, saved or printed). A plain Back keeps
    // the photos so the guest can retake a shot.
    final bool? finished = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
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
        if (finished == true) await provider.clearSession();
        provider.startCamera();
      } catch (_) {}
    }
  } finally {
    _openingEditor = false;
  }
}
