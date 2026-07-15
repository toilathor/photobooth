import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:th_photobooth/components/copyright_watermark.dart';
import 'package:th_photobooth/components/language_switcher.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/di/service_locator.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/features/photobooth/screens/photobooth.screen.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/cache_service.dart';
import 'package:th_photobooth/services/storage_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final allCameras = await availableCameras();
  final backCameras = allCameras
      .where((c) => c.lensDirection == CameraLensDirection.back)
      .toList();
  final frontCameras = allCameras
      .where((c) => c.lensDirection == CameraLensDirection.front)
      .toList();

  final List<CameraDescription> selectedCameras = [];
  if (frontCameras.isNotEmpty) {
    selectedCameras.add(
      frontCameras.first,
    ); // OS generally puts 1x Front Camera first
  } else if (allCameras.isNotEmpty) {
    selectedCameras.add(allCameras.first); // Fallback
  }

  if (backCameras.isNotEmpty) {
    if (!selectedCameras.contains(backCameras.first)) {
      selectedCameras.add(backCameras.first);
    }
  }

  AppConfig.cameras = selectedCameras;

  // Dọn dẹp cache khi khởi động
  await CacheService.clearCache();

  // Khởi tạo Storage Service theo cấu hình (Personal: Google Drive, Commercial: None)
  await StorageFactory.instance.init();

  // Khởi tạo Service Locator (GetIt)
  setupServiceLocator();

  runApp(
    TranslationProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => locator<PhotoboothProvider>()),
        ],
        child: const PhotoboothApp(),
      ),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppConfig.theme,
      darkTheme: AppConfig.darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: AppScrollBehavior(),
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final bool isDesktop = MediaQuery.sizeOf(context).width >= 850 &&
            MediaQuery.sizeOf(context).height >= 500;
        return ResponsiveBreakpoints.builder(
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              if (isDesktop)
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: LanguageSwitcher(),
                  ),
                ),
              const CopyrightWatermark(),
            ],
          ),
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 850, name: TABLET),
            const Breakpoint(start: 851, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
      },
      home: const PhotoboothScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
