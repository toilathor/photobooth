import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:th_photobooth/components/branded_qr_code.dart';
import 'package:th_photobooth/components/nudge_bounce.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/components/shortcut_keycap.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class QrSharePanel extends StatelessWidget {
  final String url;
  final bool isMobile;

  /// How the background Drive upload is going; the QR works once it is done.
  final String? uploadStatus;

  /// Ends the session and goes back to capture for the next guest.
  final VoidCallback onNextGuest;

  const QrSharePanel({
    super.key,
    required this.url,
    required this.onNextGuest,
    this.uploadStatus,
    this.isMobile = false,
  });

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.editor.linkCopied)));
    }
  }

  // Hops to say this is the next step once the QR is out.
  Widget _nextGuest() => NudgeBounce(
    active: true,
    child: PrimaryButton(
      onTap: onNextGuest,
      label: t.editor.nextGuest,
      shortcut: ShortcutKey.enter,
      icon: Icons.add_a_photo_rounded,
      height: 56,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = isMobile ? 16.0 : 24.0;
          final availableWidth = constraints.maxWidth - padding * 2;
          final stackActions = availableWidth < 480;
          final actionHeight = stackActions ? 140.0 : 72.0;
          final availableHeight =
              constraints.maxHeight -
              padding * 2 -
              (isMobile ? 80 : 88) -
              (uploadStatus == null ? 0 : 28) -
              actionHeight;
          final qrSize = math.min(
            availableWidth,
            math.max(isMobile ? 160.0 : 220.0, availableHeight),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      // Not "cloud done": the upload may still be running.
                      Icons.qr_code_2_rounded,
                      color: colorScheme.secondary,
                      size: isMobile ? 32 : 40,
                    ),
                    const Gap(12),
                    Flexible(
                      child: Text(
                        t.google_drive.qr_title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: colorScheme.secondary,
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  t.google_drive.qr_description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (uploadStatus != null) ...[
                  const Gap(8),
                  Text(
                    uploadStatus!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: colorScheme.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Gap(16),
                BrandedQrCode(
                  data: url,
                  size: qrSize,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
                const Gap(16),
                if (stackActions)
                  Column(
                    children: [
                      SizedBox(width: double.infinity, child: _nextGuest()),
                      const Gap(12),
                      _LinkField(url: url, onCopy: () => _copyLink(context)),
                    ],
                  )
                else
                  Row(
                    children: [
                      SizedBox(width: 220, child: _nextGuest()),
                      const Gap(12),
                      Expanded(
                        child: _LinkField(
                          url: url,
                          onCopy: () => _copyLink(context),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LinkField extends StatelessWidget {
  final String url;
  final VoidCallback onCopy;

  const _LinkField({required this.url, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 16, right: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              url,
              maxLines: 1,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ),
          Tooltip(
            message: t.editor.copyLink,
            child: IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded),
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
