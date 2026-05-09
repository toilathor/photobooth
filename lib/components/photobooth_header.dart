import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoboothHeader extends StatelessWidget {
  const PhotoboothHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            'Thuý Hền ❤️ Quang Tọ',
            style: GoogleFonts.pacifico(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: colorScheme.secondary,
            ).copyWith(
              fontFamilyFallback: [
                'Apple Color Emoji',
                'Segoe UI Emoji',
                'Noto Color Emoji',
              ],
            ),
          ),
          // const Gap(4),
          // Text(
          //   'TRĂM NĂM TÌNH VIÊN MÃN',
          //   style: GoogleFonts.inter(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w600,
          //     color: colorScheme.onSurface,
          //     letterSpacing: 6,
          //   ),
          // ),
        ],
      ),
    );
  }
}
