import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:th_photobooth/components/branded_qr_code.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class QrSharePanel extends StatelessWidget {
  final String url;
  final bool isMobile;
  final VoidCallback onDownload;

  const QrSharePanel({
    super.key,
    required this.url,
    required this.onDownload,
    this.isMobile = false,
  });

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.editor.linkCopied)));
    }
  }

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
                      Icons.cloud_done_rounded,
                      color: colorScheme.secondary,
                      size: isMobile ? 32 : 40,
                    ),
                    const Gap(12),
                    Flexible(
                      child: Text(
                        t.google_drive.qr_title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: colorScheme.secondary,
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  t.google_drive.qr_description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          onTap: onDownload,
                          label: t.editor.saveToDevice,
                          icon: Icons.download_rounded,
                          height: 56,
                        ),
                      ),
                      const Gap(12),
                      _LinkField(url: url, onCopy: () => _copyLink(context)),
                    ],
                  )
                else
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: PrimaryButton(
                          onTap: onDownload,
                          label: t.editor.saveToDevice,
                          icon: Icons.download_rounded,
                          height: 56,
                        ),
                      ),
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
