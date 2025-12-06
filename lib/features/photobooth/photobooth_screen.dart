import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:toilathor_photobooth/features/photobooth/photobooth_provider.dart';

class PhotoboothScreen extends StatefulWidget {
  const PhotoboothScreen({super.key});

  @override
  State<PhotoboothScreen> createState() => _PhotoboothScreenState();
}

class _PhotoboothScreenState extends State<PhotoboothScreen>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhotoboothProvider(),
      builder: (_, child) => Consumer<PhotoboothProvider>(
        builder: (_, provider, __) {
          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: !provider.isFullscreen
                ? FloatingActionButton(
                    child: const Icon(Icons.fullscreen),
                    onPressed: () => provider.enterFullscreen(),
                  )
                : null,
            body: Padding(
              padding: const EdgeInsets.all(64),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Toilathor",
                      style: TextStyle(fontSize: 100),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: provider.cameraController == null
                            ? const SizedBox()
                            : CameraPreview(provider.cameraController!),
                      ),
                    ),
                    const Gap(16),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

// @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   final CameraController? cameraController = controller;
//
//   // App state changed before we got the chance to initialize.
//   if (cameraController == null || !cameraController.value.isInitialized) {
//     return;
//   }
//
//   if (state == AppLifecycleState.inactive) {
//     cameraController.dispose();
//   } else if (state == AppLifecycleState.resumed) {
//     _initializeCameraController(cameraController.description);
//   }
// }
}
