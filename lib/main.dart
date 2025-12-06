import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:toilathor_photobooth/features/photobooth/photobooth_screen.dart';
import 'package:toilathor_photobooth/helper/constants.dart';
import 'package:toilathor_photobooth/helper/design.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const PhotoboothApp());
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photobooth',
      theme: light,
      darkTheme: dark,
      // themeMode: _themeMode,
      themeMode: ThemeMode.light,
      home: const PhotoboothScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
