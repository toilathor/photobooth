import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:my_photobooth/helper/constants.dart';
import 'package:my_photobooth/helper/fullscreen_noop.dart'
    if (dart.library.js) 'package:my_photobooth/helper/fullscreen_web.dart'
    as fullscreen;

class PhotoboothProvider extends ChangeNotifier {
  CameraController? cameraController;
  bool isFullscreen = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentCameraIndex = 0;

  int selectedPhotoCount = 4;
  int countdown = 3;
  List<XFile> capturedPhotos = [];
  bool isVideoRecap = false;
  String selectedFilter = '';

  bool isCapturing = false;
  bool isPreparing = false;
  bool isSwitchingCamera = false;
  bool isMirrored = false;
  int currentCountdownValue = 0;
  int currentPhotoIndex = 0;

  final List<int> photoCounts = [1, 3, 4];
  final List<int> countdowns = [3, 5, 10];
  final List<String> filters = [
    'Bình Thường',
    'Mono (Retro Effect)',
    'Đen Trắng',
    'Mềm Mại',
    'Dazz Classic',
    'Dazz Instant',
  ];
  final List<Map<String, dynamic>> effects = [
    {'name': 'TimeStamp', 'icon': Icons.timer},
    {'name': 'Light Leak', 'icon': Icons.wb_sunny},
    {'name': 'Vignette', 'icon': Icons.adjust},
    {'name': 'Grain', 'icon': Icons.grain},
    {'name': 'Chromatic', 'icon': Icons.color_lens},
  ];

  PhotoboothProvider() {
    if (cameras.isNotEmpty) {
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );
    }
    cameraController?.initialize().then((_) {
      notifyListeners();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });

    // Listen for fullscreen changes (e.g. Esc key)
    fullscreen.onFullscreenChangeWeb((value) {
      isFullscreen = value;
      notifyListeners();
    });
  }

  void setPhotoCount(int count) {
    selectedPhotoCount = count;
    notifyListeners();
  }

  void setCountdown(int value) {
    countdown = value;
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    if (cameras.isEmpty || cameras.length < 2 || isSwitchingCamera) return;

    isSwitchingCamera = true;
    notifyListeners();

    _currentCameraIndex = (_currentCameraIndex + 1) % cameras.length;
    final camera = cameras[_currentCameraIndex];

    if (cameraController != null) {
      await cameraController!.dispose();
    }

    cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await cameraController!.initialize();
    } catch (e) {
      debugPrint('Error switching camera: $e');
    } finally {
      isSwitchingCamera = false;
      notifyListeners();
    }
  }

  void toggleVideoRecap(bool value) {
    isVideoRecap = value;
    notifyListeners();
  }

  void toggleMirror() {
    isMirrored = !isMirrored;
    notifyListeners();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  final Map<int, String> _numberSounds = {
    1: 'mot.mp3',
    2: 'hai.mp3',
    3: 'ba.mp3',
    4: 'bon.mp3',
    5: 'nam.mp3',
    6: 'sau.mp3',
    7: 'bay.mp3',
    8: 'tam.mp3',
    9: 'chin.mp3',
    10: 'muoi.mp3',
  };

  Future<void> startAutoCapture() async {
    if (isCapturing ||
        cameraController == null ||
        !cameraController!.value.isInitialized) {
      return;
    }

    isCapturing = true;
    isPreparing = true;
    capturedPhotos.clear();
    currentPhotoIndex = 0;
    currentCountdownValue = 2; // 2 seconds to prepare
    notifyListeners();
    _playSound('chuan_bi.mp3');

    // Preparation Countdown
    Completer<void> prepCompleter = Completer<void>();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentCountdownValue > 1) {
        currentCountdownValue--;
        notifyListeners();
      } else {
        currentCountdownValue = 0;
        timer.cancel();
        prepCompleter.complete();
      }
    });
    await prepCompleter.future;

    isPreparing = false;
    notifyListeners();

    for (int i = 0; i < selectedPhotoCount; i++) {
      currentPhotoIndex = i + 1;
      currentCountdownValue = countdown;
      notifyListeners();
      if (_numberSounds.containsKey(currentCountdownValue)) {
        _playSound(_numberSounds[currentCountdownValue]!);
      }

      // Countdown
      Completer<void> countdownCompleter = Completer<void>();
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (currentCountdownValue > 1) {
          currentCountdownValue--;
          notifyListeners();
          if (_numberSounds.containsKey(currentCountdownValue)) {
            _playSound(_numberSounds[currentCountdownValue]!);
          }
        } else {
          currentCountdownValue = 0;
          timer.cancel();
          countdownCompleter.complete();
        }
      });
      await countdownCompleter.future;

      // Capture
      try {
        _playSound('camera.mp3');
        XFile photo = await cameraController!.takePicture();

        if (isMirrored) {
          photo = await _processMirrorImage(photo);
        }

        capturedPhotos.add(photo);
        notifyListeners();
      } catch (e) {
        debugPrint('Error taking photo: $e');
      }

      // Small delay between shots
      if (i < selectedPhotoCount - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    isCapturing = false;
    notifyListeners();
  }

  Future<void> takeManualPhoto() async {
    if (isCapturing ||
        cameraController == null ||
        !cameraController!.value.isInitialized ||
        capturedPhotos.length >= selectedPhotoCount) {
      return;
    }

    isCapturing = true;
    notifyListeners();
    _playSound('camera.mp3');

    try {
      XFile photo = await cameraController!.takePicture();
      if (isMirrored) {
        photo = await _processMirrorImage(photo);
      }
      capturedPhotos.add(photo);
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }

    isCapturing = false;
    notifyListeners();
  }

  Future<XFile> _processMirrorImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return file;

      final flipped = img.flipHorizontal(image);
      final flippedBytes = img.encodeJpg(flipped);

      return XFile.fromData(
        Uint8List.fromList(flippedBytes),
        name: file.name,
        mimeType: 'image/jpeg',
      );
    } catch (e) {
      debugPrint('Error processing mirror image: $e');
      return file;
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < capturedPhotos.length) {
      capturedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void resetCapture() {
    capturedPhotos.clear();
    currentPhotoIndex = 0;
    isCapturing = false;
    notifyListeners();
  }

  void enterFullscreen() {
    fullscreen.enterFullscreenWeb();
    // State will be updated by the listener
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
