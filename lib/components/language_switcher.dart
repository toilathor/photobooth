import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      child: AnimatedToggleSwitch<AppLocale>.dual(
        current: provider.currentLocale,
        first: AppLocale.vi,
        second: AppLocale.en,
        style: ToggleStyle(
          borderColor: colorScheme.secondary.withValues(alpha: 0.3),
          backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
          indicatorColor: colorScheme.secondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        spacing: 0,
        borderWidth: 1.5,
        height: 40,
        onChanged: (val) => provider.setLanguage(val),
        styleBuilder: (value) =>
            ToggleStyle(indicatorColor: colorScheme.secondary),
        iconBuilder: (value) => value == AppLocale.vi
            ? const Text('🇻🇳', style: TextStyle(fontSize: 16))
            : const Text('🇺🇸', style: TextStyle(fontSize: 16)),
        textBuilder: (value) => value == AppLocale.vi
            ? const Center(
                child: Text(
                  'EN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              )
            : const Center(
                child: Text(
                  'VI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
      ),
    );
  }
}
