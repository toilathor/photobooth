import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

Widget testApp({required Widget child, bool withProvider = true}) {
  Widget content = MaterialApp(
    home: ResponsiveBreakpoints.builder(
      child: child,
      breakpoints: const [
        Breakpoint(start: 0, end: 450, name: MOBILE),
        Breakpoint(start: 451, end: 850, name: TABLET),
        Breakpoint(start: 851, end: 1920, name: DESKTOP),
        Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
    ),
  );

  if (withProvider) {
    content = ChangeNotifierProvider(
      create: (_) => PhotoboothProvider(),
      child: content,
    );
  }

  return TranslationProvider(child: content);
}
