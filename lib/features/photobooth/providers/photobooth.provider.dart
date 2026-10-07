import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/asset_config.dart';
import 'package:th_photobooth/core/async/cancellation_token.dart';
import 'package:th_photobooth/core/async/countdown_runner.dart';
import 'package:th_photobooth/helper/fullscreen_noop.dart'
    if (dart.library.js_interop) 'package:th_photobooth/helper/fullscreen_web.dart'
    as fullscreen;
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/audio_service.dart';
import 'package:th_photobooth/services/camera_service.dart';
import 'package:th_photobooth/services/cache_service.dart';
import 'package:th_photobooth/services/video_service.dart';

class PhotoboothProvider extends ChangeNotifier {
  bool _isDisposed = false;
  final CameraService _cameraService = CameraService();
  CameraController? get cameraController => _cameraService.controller;
  set cameraController(CameraController? value) {
    _cameraService.controller = value;
  }

  bool isFullscreen = false;
  final AudioService _audioService = AudioService();
  final CountdownRunner _countdownRunner = CountdownRunner();
  int _currentCameraIndex = 0;
  bool isMirrored = false;
  bool isVeryHighResolution = false;
  bool _isCameraOperationInProgress = false;
  CameraLensDirection? _lastLensDirection;

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

  bool get isFrontCamera {
    final direction =
        cameraController?.description.lensDirection ?? _lastLensDirection;
    return direction == CameraLensDirection.front ||
        direction == CameraLensDirection.external;
  }

  bool get photoRequiresFlip {
    if (kIsWeb) {
      return isMirrored;
    } else {
      return isFrontCamera != isMirrored;
    }
  }

  bool get videoRequiresFlip {
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
    fullscreen.onFullscreenChangeWeb((bool value) {
      isFullscreen = value;
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
    if (_isDisposed) {
      isSwitchingCamera = false;
      _isCameraOperationInProgress = false;
      return;
    }
    while (_isCameraOperationInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_isDisposed) {
        isSwitchingCamera = false;
        _isCameraOperationInProgress = false;
        return;
      }
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
      await _cameraService.disposeController(oldController);
    }

    if (_isDisposed) {
      isSwitchingCamera = false;
      _isCameraOperationInProgress = false;
      return;
    }

    cameraController = _cameraService.createController(
      description: camera,
      resolution: isVeryHighResolution
          ? ResolutionPreset.veryHigh
          : ResolutionPreset.high,
    );

    try {
      await cameraController?.initialize();
      _lastLensDirection = camera.lensDirection;
      isMirrored = false; // Reset mirror when switching cameras
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
    if (_isDisposed) return;
    while (_isCameraOperationInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_isDisposed) {
        isSwitchingCamera = false;
        _isCameraOperationInProgress = false;
        return;
      }
    }
    if (cameraController == null) return;

    _isCameraOperationInProgress = true;
    try {
      final oldController = cameraController;
      cameraController = null;
      notifyListeners();
      await _cameraService.disposeController(oldController);
    } finally {
      _isCameraOperationInProgress = false;
    }
  }

  Future<void> startCamera() async {
    if (_isDisposed) return;
    while (_isCameraOperationInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_isDisposed) return;
    }
    if (cameraController != null) return;

    _isCameraOperationInProgress = true;
    if (AppConfig.cameras.isNotEmpty) {
      isSwitchingCamera = true;
      notifyListeners();

      final camera = AppConfig.cameras[_currentCameraIndex];
      if (_isDisposed) {
        isSwitchingCamera = false;
        _isCameraOperationInProgress = false;
        return;
      }
      cameraController = _cameraService.createController(
        description: camera,
        resolution: isVeryHighResolution
            ? ResolutionPreset.veryHigh
            : ResolutionPreset.high,
      );

      try {
        await cameraController?.initialize();
        _lastLensDirection = camera.lensDirection;
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

  final CancellationToken _captureCancellation = CancellationToken();

  void cancelAutoCapture() {
    if (isCapturing) {
      _captureCancellation.cancel();
      notifyListeners();
    }
  }

  Future<void> startAutoCapture() async {
    if (_isDisposed) return;
    _audioService.warmup();
    if (isCapturing ||
        cameraController == null ||
        cameraController?.value.isInitialized != true) {
      return;
    }

    isCapturing = true;
    isAutoCapturing = true;
    isPreparing = true;
    _captureCancellation.reset();
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

    // Preparation countdown
    final preparationCompleted = await _countdownRunner.run(
      seconds: 2,
      cancellation: _captureCancellation,
      onTick: (remaining) {
        currentCountdownValue = remaining;
        notifyListeners();
      },
    );

    if (!preparationCompleted || _isDisposed) {
      await _cleanupAfterCancellation();
      return;
    }

    isPreparing = false;
    notifyListeners();

    for (int i = 0; i < selectedPhotoCount; i++) {
      if (_captureCancellation.isCancelled || _isDisposed) break;

      currentPhotoIndex = i + 1;
      final countdownCompleted = await _countdownRunner.run(
        seconds: countdown,
        cancellation: _captureCancellation,
        onTick: (remaining) {
          currentCountdownValue = remaining;
          notifyListeners();
          if (remaining > 0 && _numberSounds.containsKey(remaining)) {
            _playSound(_numberSounds[remaining]!);
          }
        },
      );

      if (!countdownCompleted || _isDisposed) break;

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

    if (_captureCancellation.isCancelled || _isDisposed) {
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
    _captureCancellation.reset();
    capturedPhotos.clear();
    _videoService.reset();
    currentCountdownValue = 0;
    currentPhotoIndex = 0;
    notifyListeners();
  }

  Future<void> takeManualPhoto() async {
    if (_isDisposed) return;
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
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _captureCancellation.cancel();
    final oldController = cameraController;
    cameraController = null;
    _cameraService.disposeController(oldController);
    _audioService.dispose();
    super.dispose();
  }
}
