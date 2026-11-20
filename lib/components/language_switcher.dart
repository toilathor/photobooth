import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool isMobile;

  const LanguageSwitcher({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.zero,
      child: AnimatedToggleSwitch<AppLocale>.dual(
        current: provider.currentLocale,
        first: AppLocale.vi,
        second: AppLocale.en,
        style: ToggleStyle(
          borderColor: colorScheme.secondary.withValues(alpha: 0.3),
          backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
          indicatorColor: colorScheme.secondary,
          boxShadow: isMobile
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        spacing: 0,
        borderWidth: 1.5,
        height: isMobile ? 32 : 40,
        onChanged: (val) => provider.setLanguage(val),
        styleBuilder: (value) =>
            ToggleStyle(indicatorColor: colorScheme.secondary),
        indicatorSize: const Size.fromWidth(40),
        iconBuilder: (value) => value == AppLocale.vi
            ? Text('🇻🇳', style: TextStyle(fontSize: isMobile ? 12 : 16))
            : Text('🇺🇸', style: TextStyle(fontSize: isMobile ? 12 : 16)),
        // Flag and code both name the current language, so the control
        // never shows one language's flag beside the other's label.
        textBuilder: (value) => Center(
          child: Text(
            value == AppLocale.vi ? 'VI' : 'EN',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
