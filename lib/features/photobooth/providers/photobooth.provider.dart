import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/asset_config.dart';
import 'package:th_photobooth/helper/fullscreen_noop.dart'
    if (dart.library.js_interop) 'package:th_photobooth/helper/fullscreen_web.dart'
    as fullscreen;
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/audio_service.dart';
import 'package:th_photobooth/services/cache_service.dart';
import 'package:th_photobooth/services/video_service.dart';

class PhotoboothProvider extends ChangeNotifier {
  CameraController? cameraController;
  bool isFullscreen = false;
  final AudioService _audioService = AudioService();
  int _currentCameraIndex = 0;
  bool isMirrored = false;
  bool isVeryHighResolution = false;
  bool _isCameraOperationInProgress = false;

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

  bool get requiresFlip {
    if (cameraController == null) return isMirrored;
    final isFrontCamera = cameraController!.description.lensDirection ==
        CameraLensDirection.front;
    return isFrontCamera != isMirrored;
  }

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
    while (_isCameraOperationInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (AppConfig.cameras.isEmpty ||
        AppConfig.cameras.length < 2 ||
        isSwitchingCamera) {
      return;
    }

    _isCameraOperationInProgress = true;
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
      cameraController = null;
    } finally {
      isSwitchingCamera = false;
      _isCameraOperationInProgress = false;
      notifyListeners();
    }
  }

  Future<void> stopCamera() async {
    while (_isCameraOperationInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (cameraController == null) return;

    _isCameraOperationInProgress = true;
    try {
      final oldController = cameraController;
      cameraController = null;
      notifyListeners();
      await oldController?.dispose();
    } finally {
      _isCameraOperationInProgress = false;
    }
  }

  Future<void> startCamera() async {
    while (_isCameraOperationInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (cameraController != null) return;

    _isCameraOperationInProgress = true;
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
        cameraController = null;
      } finally {
        isSwitchingCamera = false;
        _isCameraOperationInProgress = false;
        notifyListeners();
      }
    } else {
      _isCameraOperationInProgress = false;
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
    await _audioService.playSound(fileName);
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
    _audioService.warmup();
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
    int prepCountdown = 2;
    currentCountdownValue = prepCountdown;
    notifyListeners();

    DateTime prepStartTime = DateTime.now();
    int prepLastTriggeredSecond = prepCountdown + 1;

    while (currentCountdownValue > 0) {
      if (_shouldCancelCapture) break;

      DateTime now = DateTime.now();
      double elapsed = now.difference(prepStartTime).inMilliseconds / 1000.0;
      int expectedRemaining = prepCountdown - elapsed.floor();

      if (expectedRemaining < 0) expectedRemaining = 0;

      if (expectedRemaining < prepLastTriggeredSecond) {
        currentCountdownValue = expectedRemaining;
        notifyListeners();
        prepLastTriggeredSecond = expectedRemaining;
      }

      if (currentCountdownValue == 0) break;
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }

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

      // Countdown using target-based DateTime delta loop
      DateTime cdStartTime = DateTime.now();
      int cdLastTriggeredSecond = countdown;

      while (currentCountdownValue > 0) {
        if (_shouldCancelCapture) break;

        DateTime now = DateTime.now();
        double elapsed = now.difference(cdStartTime).inMilliseconds / 1000.0;
        int expectedRemaining = countdown - elapsed.floor();

        if (expectedRemaining < 0) expectedRemaining = 0;

        if (expectedRemaining < cdLastTriggeredSecond) {
          if (expectedRemaining == cdLastTriggeredSecond - 1) {
            currentCountdownValue = expectedRemaining;
            notifyListeners();
            if (currentCountdownValue > 0 &&
                _numberSounds.containsKey(currentCountdownValue)) {
              _playSound(_numberSounds[currentCountdownValue]!);
            }
          } else {
            // Main thread was blocked, update state without stacking audio calls
            currentCountdownValue = expectedRemaining;
            notifyListeners();
          }
          cdLastTriggeredSecond = expectedRemaining;
        }

        if (currentCountdownValue == 0) break;
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }

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
    _audioService.warmup();
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
    _audioService.dispose();
    super.dispose();
  }
}
