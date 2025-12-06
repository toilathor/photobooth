// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:toilathor_photobooth/helper/constants.dart';

class PhotoboothProvider extends ChangeNotifier {
  late final CameraController? cameraController;
  bool isFullscreen = false;

  PhotoboothProvider() {
    if (cameras.isNotEmpty) {
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.low,
         enableAudio: false,
      );
    }
    cameraController?.initialize().then((_) {
      notifyListeners();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  void enterFullscreen() {
    js.context.callMethod('enterFullscreen');
    isFullscreen = true;
    notifyListeners();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
