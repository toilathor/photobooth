import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:provider/provider.dart';

import 'dropdown_setting.dart';
import 'photo_selection_dialog.dart';
import 'package:my_photobooth/i18n/strings.g.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.secondary,
                letterSpacing: 2,
              ),
            ),
            const Gap(16),
            DropdownSetting<int>(
              label: t.settings.photoCount,
              value: provider.selectedPhotoCount,
              items: provider.photoCounts,
              onChanged: provider.isAutoCapturing
                  ? null
                  : (val) {
                      final newCount = val as int;
                      if (provider.capturedPhotos.length > newCount) {
                        // Show selection dialog
                        showDialog<List<XFile>>(
                          context: context,
                          builder: (context) => PhotoSelectionDialog(
                            photos: provider.capturedPhotos,
                            targetCount: newCount,
                            isMirrored: provider.isMirrored,
                          ),
                        ).then((selectedPhotos) {
                          if (selectedPhotos != null) {
                            provider.setPhotoCountWithSelection(
                              newCount,
                              selectedPhotos,
                            );
                          }
                        });
                      } else {
                        provider.setPhotoCount(newCount);
                      }
                    },
            ),
            const Gap(20),
            DropdownSetting<int>(
              label: t.settings.countdown,
              value: provider.countdown,
              items: provider.countdowns,
              onChanged: provider.isAutoCapturing
                  ? null
                  : (val) => provider.setCountdown(val as int),
              suffix: ' ${t.settings.seconds}',
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}
