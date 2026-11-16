import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

Widget testApp({required Widget child}) {
  LocaleSettings.setLocaleSync(AppLocale.vi);

  return TranslationProvider(
    child: MaterialApp(
      home: ResponsiveBreakpoints.builder(
        child: child,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 850, name: TABLET),
          Breakpoint(start: 851, end: 1920, name: DESKTOP),
          Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    ),
  );
}
