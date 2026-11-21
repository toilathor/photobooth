import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class PhotoboothHeader extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;

  const PhotoboothHeader({super.key, this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isMobile =
        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP) ||
        MediaQuery.sizeOf(context).height < 500;
    final double sideWidth = (leading != null || trailing != null)
        ? (isMobile ? 80.0 : 112.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 8.0 : 16.0,
        horizontal: isMobile ? 12.0 : 24.0,
      ),
      child: Row(
        children: [
          SizedBox(
            width: sideWidth,
            child: leading != null
                ? Align(alignment: Alignment.centerLeft, child: leading)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppConfig.flavor == AppFlavor.personal
                      ? t.header.titlePersonal
                      : t.header.titleCommercial,
                  style:
                      (AppConfig.flavor == AppFlavor.personal
                              // The script of the names on the invitation; it
                              // is thin, so it runs larger than Pacifico.
                              ? TextStyle(
                                  fontFamily: 'PinyonScript',
                                  fontSize: isMobile ? 34 : 52,
                                  height: 1.2,
                                  color: colorScheme.secondary,
                                )
                              : GoogleFonts.pacifico(
                                  fontSize: isMobile ? 24 : 36,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ))
                          .copyWith(
                            fontFamilyFallback: [
                              'Apple Color Emoji',
                              'Segoe UI Emoji',
                              'Noto Color Emoji',
                            ],
                          ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: sideWidth,
            child: trailing != null
                ? Align(alignment: Alignment.centerRight, child: trailing)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
