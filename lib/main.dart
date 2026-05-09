import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_photobooth/core/configs/app_config.dart';
import 'package:my_photobooth/core/configs/theme_config.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.screen.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:my_photobooth/components/language_switcher.dart';
import 'package:my_photobooth/services/cache_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.cameras = await availableCameras();

  // Dọn dẹp cache khi khởi động
  await CacheService.clearCache();

  runApp(
    TranslationProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PhotoboothProvider()),
          ChangeNotifierProvider(create: (_) => EditPhotoProvider()),
        ],
        child: const PhotoboothApp(),
      ),
    ),
  );
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photobooth',
      theme: ThemeConfig.weddingTheme,
      themeMode: ThemeMode.light,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(
              top: 0,
              left: 0,
              child: Material(
                color: Colors.transparent,
                child: LanguageSwitcher(),
              ),
            ),
          ],
        );
      },
      home: const PhotoboothScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
