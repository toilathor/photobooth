import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/asset_config.dart';
import 'package:th_photobooth/helper/fullscreen_noop.dart'
    if (dart.library.js_interop) 'package:th_photobooth/helper/fullscreen_web.dart'
    as fullscreen;
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/cache_service.dart';
import 'package:th_photobooth/services/video_service.dart';

class PhotoboothProvider extends ChangeNotifier {
  CameraController? cameraController;
  bool isFullscreen = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentCameraIndex = 0;
  bool isMirrored = false;
  bool isVeryHighResolution = false;

  int selectedPhotoCount = 4;
  int countdown = 3;
  List<XFile> capturedPhotos = [];
  bool isVideoRecap = true;

  bool isCapturing = false;
  bool isAutoCapturing = false;
  bool isPreparing = false;
  bool isSwitchingCamera = false;
  int currentCountdownValue = 0;
  int currentPhotoIndex = 0;

  AppLocale currentLocale = LocaleSettings.currentLocale;

  bool get isDoneTakingPhotos => capturedPhotos.length >= selectedPhotoCount;

  final VideoService _videoService = VideoService();
  XFile? get videoRecapFile => _videoService.videoRecapFile;
  List<Duration> get photoTimestamps => _videoService.photoTimestamps;

  final List<int> photoCounts = AppConfig.photoCounts;
  final List<int> countdowns = AppConfig.countdowns;

  PhotoboothProvider() {
    startCamera();

    // Listen for fullscreen changes (e.g. Esc key)
    fullscreen.onFullscreenChangeWeb((dynamic value) {
      isFullscreen = value as bool;
      notifyListeners();
    });
  }

  void setPhotoCount(int count) {
    selectedPhotoCount = count;
    // Default truncation logic (taking first N)
    if (capturedPhotos.length > selectedPhotoCount) {
      capturedPhotos = capturedPhotos.sublist(0, selectedPhotoCount);
    }
    notifyListeners();
  }

  void setPhotoCountWithSelection(int count, List<XFile> selection) {
    selectedPhotoCount = count;
    capturedPhotos = List.from(selection);
    notifyListeners();
  }

  void setCountdown(int value) {
    countdown = value;
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    if (AppConfig.cameras.isEmpty ||
        AppConfig.cameras.length < 2 ||
        isSwitchingCamera) {
      return;
    }

    isSwitchingCamera = true;
    notifyListeners();

    _currentCameraIndex = (_currentCameraIndex + 1) % AppConfig.cameras.length;
    final camera = AppConfig.cameras[_currentCameraIndex];

    if (cameraController != null) {
      final oldController = cameraController;
      cameraController = null;
      await oldController?.dispose();
    }

    cameraController = CameraController(
      camera,
      isVeryHighResolution ? ResolutionPreset.veryHigh : ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await cameraController?.initialize();
    } catch (e) {
      debugPrint('Error switching camera: $e');
    } finally {
      isSwitchingCamera = false;
      notifyListeners();
    }
  }

  Future<void> stopCamera() async {
    if (cameraController != null) {
      final oldController = cameraController;
      cameraController = null;
      notifyListeners();
      await oldController?.dispose();
    }
  }

  Future<void> startCamera() async {
    if (cameraController != null) return;

    if (AppConfig.cameras.isNotEmpty) {
      isSwitchingCamera = true;
      notifyListeners();

      final camera = AppConfig.cameras[_currentCameraIndex];
      cameraController = CameraController(
        camera,
        isVeryHighResolution
            ? ResolutionPreset.veryHigh
            : ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await cameraController?.initialize();
        if (!kIsWeb) {
          try {
            await cameraController?.setZoomLevel(1.0);
          } catch (e) {
            debugPrint('Warning: Could not set zoom level: $e');
          }
        }
      } catch (e) {
        debugPrint('Error starting camera: $e');
      } finally {
        isSwitchingCamera = false;
        notifyListeners();
      }
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

  Future<void> toggleResolution(bool value) async {
    if (isVeryHighResolution == value) return;
    isVeryHighResolution = value;
    notifyListeners();

    if (cameraController != null) {
      await stopCamera();
      await startCamera();
    }
  }

  void setLanguage(AppLocale locale) {
    LocaleSettings.setLocale(locale);
    currentLocale = locale;
    notifyListeners();
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(AssetConfig.getSoundPath(fileName)));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  final Map<int, String> _numberSounds = AppConfig.numberSounds;

  bool _shouldCancelCapture = false;

  void cancelAutoCapture() {
    if (isCapturing) {
      _shouldCancelCapture = true;
      notifyListeners();
    }
  }

  Future<void> startAutoCapture() async {
    if (isCapturing ||
        cameraController == null ||
        cameraController?.value.isInitialized != true) {
      return;
    }

    isCapturing = true;
    isAutoCapturing = true;
    isPreparing = true;
    _shouldCancelCapture = false;
    capturedPhotos.clear();
    _videoService.reset();
    currentPhotoIndex = 0;
    currentCountdownValue = 2; // 2 seconds to prepare
    notifyListeners();
    _playSound(AssetConfig.soundPrepare);

    // Start Video Recap if enabled
    if (isVideoRecap &&
        cameraController != null &&
        cameraController?.value.isInitialized == true) {
      try {
        await _videoService.startRecording(cameraController!);
      } catch (e) {
        debugPrint('Error starting video recording: $e');
      }
    }

    // Preparation Countdown
    Completer<void> prepCompleter = Completer<void>();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_shouldCancelCapture) {
        timer.cancel();
        prepCompleter.complete();
        return;
      }
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

    if (_shouldCancelCapture) {
      await _cleanupAfterCancellation();
      return;
    }

    isPreparing = false;
    notifyListeners();

    for (int i = 0; i < selectedPhotoCount; i++) {
      if (_shouldCancelCapture) break;

      currentPhotoIndex = i + 1;
      currentCountdownValue = countdown;
      notifyListeners();
      if (_numberSounds.containsKey(currentCountdownValue)) {
        _playSound(_numberSounds[currentCountdownValue]!);
      }

      // Countdown
      Completer<void> countdownCompleter = Completer<void>();
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_shouldCancelCapture) {
          timer.cancel();
          countdownCompleter.complete();
          return;
        }
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

      if (_shouldCancelCapture) break;

      // Capture
      try {
        _playSound(AssetConfig.soundCamera);

        // Record timestamp relative to video start
        _videoService.recordTimestamp();

        XFile? photo = await cameraController?.takePicture();
        if (photo != null) {
          capturedPhotos.add(photo);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error taking photo: $e');
      }

      // Small delay between shots
      if (i < selectedPhotoCount - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    if (_shouldCancelCapture) {
      await _cleanupAfterCancellation();
      return;
    }

    // Stop Video Recap if it was recording
    if (isVideoRecap &&
        cameraController != null &&
        cameraController?.value.isRecordingVideo == true) {
      try {
        await _videoService.stopRecording(cameraController!);
      } catch (e) {
        debugPrint('Error stopping video recording: $e');
      }
    }

    isCapturing = false;
    isAutoCapturing = false;
    notifyListeners();
  }

  Future<void> _cleanupAfterCancellation() async {
    // Stop recording if active
    if (cameraController != null &&
        cameraController?.value.isRecordingVideo == true) {
      try {
        await _videoService.stopRecording(cameraController!);
      } catch (e) {
        debugPrint('Error stopping video recording on cancel: $e');
      }
    }

    isCapturing = false;
    isAutoCapturing = false;
    isPreparing = false;
    _shouldCancelCapture = false;
    capturedPhotos.clear();
    _videoService.reset();
    currentCountdownValue = 0;
    currentPhotoIndex = 0;
    notifyListeners();
  }

  Future<void> takeManualPhoto() async {
    if (isCapturing ||
        cameraController == null ||
        cameraController?.value.isInitialized == false ||
        capturedPhotos.length >= selectedPhotoCount) {
      return;
    }

    isCapturing = true;
    notifyListeners();
    _playSound(AssetConfig.soundCamera);

    try {
      XFile? photo = await cameraController?.takePicture();
      if (photo != null) {
        capturedPhotos.add(photo);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }

    isCapturing = false;
    notifyListeners();
  }

  void removePhoto(int index) {
    if (index >= 0 && index < capturedPhotos.length) {
      capturedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void resetCapture() {
    capturedPhotos.clear();
    _videoService.reset();
    currentPhotoIndex = 0;
    isCapturing = false;
    notifyListeners();
  }

  /// Hoàn thành phiên hiện tại và dọn dẹp toàn bộ cache.
  /// Gọi khi người dùng quay lại màn hình chính hoặc bắt đầu phiên mới hoàn toàn.
  Future<void> clearSession() async {
    resetCapture();
    await CacheService.clearCache();
    notifyListeners();
  }

  void enterFullscreen() {
    fullscreen.enterFullscreenWeb();
    // State will be updated by the listener
  }

  @override
  void dispose() {
    final oldController = cameraController;
    cameraController = null;
    oldController?.dispose();
    super.dispose();
  }
}
