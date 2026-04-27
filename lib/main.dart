import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/features/photobooth/photobooth.screen.dart';
import 'package:my_photobooth/helper/constants.dart';
import 'package:my_photobooth/helper/design.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoboothProvider()),
        ChangeNotifierProvider(create: (_) => EditPhotoProvider()),
      ],
      child: const PhotoboothApp(),
    ),
  );
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photobooth',
      theme: weddingTheme,
      themeMode: ThemeMode.light,
      home: const PhotoboothScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
