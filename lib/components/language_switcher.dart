import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:my_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool isMobile;

  const LanguageSwitcher({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(16),
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
        iconBuilder: (value) => value == AppLocale.vi
            ? Text('🇻🇳', style: TextStyle(fontSize: isMobile ? 12 : 16))
            : Text('🇺🇸', style: TextStyle(fontSize: isMobile ? 12 : 16)),
        textBuilder: (value) => value == AppLocale.vi
            ? Center(
                child: Text(
                  'EN',
                  style: TextStyle(
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              )
            : Center(
                child: Text(
                  'VI',
                  style: TextStyle(
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
      ),
    );
  }
}
