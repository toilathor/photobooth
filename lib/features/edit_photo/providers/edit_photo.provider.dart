import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/filter_config.dart';
import 'package:th_photobooth/core/configs/frame_config.dart';
import 'package:th_photobooth/core/configs/storage_config.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/models/qr_corner.dart';
import 'package:th_photobooth/services/frame_service.dart';
import 'package:th_photobooth/services/photo_merger_service.dart';
import 'package:th_photobooth/services/storage_factory.dart';
import 'package:th_photobooth/services/storage_section.dart';
import 'package:th_photobooth/services/storage_service_interface.dart';
import 'package:th_photobooth/services/upload_queue.dart';
import 'package:th_photobooth/services/video_recap_service.dart';

Future<Uint8List?> _encodeJpg(Uint8List pngBytes) async {
  try {
    final image = img.decodeImage(pngBytes);
    if (image == null) return null;
    return img.encodeJpg(image, quality: 90);
  } catch (error) {
    debugPrint('Error converting image to JPG: $error');
    return null;
  }
}

class EditPhotoProvider with ChangeNotifier {
  final StorageService _storageService;
  final UploadQueue _uploadQueue;

  EditPhotoProvider({
    StorageService? storageService,
    UploadQueue? uploadQueue,
    this.prepareTimeout = const Duration(minutes: 3),
  }) : _storageService = storageService ?? StorageFactory.instance,
       _uploadQueue = uploadQueue ?? UploadQueue.instance {
    filteredFrames = allFrames;
    selectedFrame = allFrames.isNotEmpty
        ? allFrames.first
        : const FrameData(photoSlots: 0);
  }

  bool isProcessing = false;
  String selectedFilter = 'normal';
  double filterIntensity = 0.5;
  QrCorner qrCorner = QrCorner.fallback;
  final List<String> filters = AppConfig.filters;
  bool _isHandlingQR = false;

  List<FrameData> allFrames = FrameConfig.allFrames;

  List<FrameData> filteredFrames = [];
  late FrameData selectedFrame;
  StorageSection? storageSection;
  String? galleryUrl;

  /// How long the guest waits behind the dialog before being offered a retry.
  final Duration prepareTimeout;

  /// The [_prepareFiles] run in flight. A retry after a timeout waits for it
  /// rather than starting a second run, which would make another Drive folder
  /// and could leave the screen showing a different QR than the print.
  Future<Map<String, Uint8List>>? _preparing;

  bool isSectionReady = false;
  bool get isEditorLocked => isSectionReady;

  /// Uploads finished sessions in the background (see [handleQRRequest]).
  UploadQueue get uploadQueue => _uploadQueue;

  /// Files of the finished session, kept so a later download reuses them
  /// instead of rendering the videos again.
  Map<String, Uint8List>? completedFiles;

  // Photobooth Session Data
  List<XFile> capturedPhotos = [];
  XFile? videoRecapFile;
  List<Duration> photoTimestamps = [];
  String? sessionId;
  bool photoIsMirrored = false;
  bool videoIsMirrored = false;

  // Upload State
  String uploadStatusMessage = '';

  /// Names the session's Drive folder, zip and files, readable by date, e.g.
  /// `thohien-wedding-20261121-143205`.
  @visibleForTesting
  static String sessionIdAt(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${AppConfig.sessionPrefix}-${time.year}${two(time.month)}'
        '${two(time.day)}-${two(time.hour)}${two(time.minute)}'
        '${two(time.second)}';
  }

  void initForPhotoCount(int count) {
    filteredFrames = allFrames.where((f) => f.photoSlots == count).toList();
    if (filteredFrames.isNotEmpty) {
      selectedFrame = filteredFrames.first;
    }
    notifyListeners();
  }

  Future<void> initWithPhotoboothData({
    required List<XFile> photos,
    required int photoCount,
    required bool photoIsMirrored,
    required bool videoIsMirrored,
    XFile? videoFile,
    List<Duration>? timestamps,
  }) async {
    capturedPhotos = photos;
    videoRecapFile = videoFile;
    photoTimestamps = timestamps ?? [];
    sessionId = sessionIdAt(DateTime.now());
    this.photoIsMirrored = photoIsMirrored;
    this.videoIsMirrored = videoIsMirrored;

    allFrames = await FrameService.loadFrames();

    initForPhotoCount(photoCount);
  }

  void setSelectedFrame(FrameData frame) {
    if (isEditorLocked) return;
    selectedFrame = frame;
    notifyListeners();
  }

  void setFilter(String filter) {
    if (isEditorLocked) return;
    selectedFilter = filter;
    filterIntensity = 0.5; // Reset intensity to 50% when filter changes
    notifyListeners();
  }

  void setFilterIntensity(double intensity) {
    if (isEditorLocked) return;
    filterIntensity = intensity;
    notifyListeners();
  }

  void setQrCorner(QrCorner corner) {
    if (isEditorLocked || corner == qrCorner) return;
    qrCorner = corner;
    notifyListeners();
  }

  void setProcessing(bool value) {
    isProcessing = value;
    notifyListeners();
  }

  void setUploadStatus(String message) {
    uploadStatusMessage = message;
    notifyListeners();
  }

  /// Finishes the session: prepares the Drive folder behind the QR, renders
  /// the files once and saves them to the device, then hands the upload to
  /// [uploadQueue] so the guest gets the QR without waiting for Drive.
  Future<void> handleQRRequest({
    required VoidCallback onHideLoading,
    required VoidCallback onShowLogin,
    required VoidCallback onStartUpload,
    required VoidCallback onUploadComplete,
    required void Function(String error) onShowError,
    required Future<Uint8List?> Function() captureStrip,
    required Future<Uint8List?> Function() capturePrintContent,
    required Future<void> Function(Map<String, Uint8List> files) saveToDevice,
  }) async {
    if (StorageConfig.activeStorage == StorageType.none) return;

    if (sessionId == null && capturedPhotos.isEmpty) return;

    if (_isHandlingQR) return;
    _isHandlingQR = true;

    try {
      if (isSectionReady && galleryUrl != null) {
        return;
      }

      if (kIsWeb) {
        final hasLoggedIn = _storageService.currentUser != null;
        final hasScopes = await _storageService.hasRequiredScopes();
        if (!hasLoggedIn || !hasScopes) {
          onShowLogin();
          return;
        }
      }

      onStartUpload();
      // A stalled network must never leave the guest stuck behind the
      // non-dismissible progress dialog: give up and offer a retry.
      final preparing = _preparing ??= _prepareFiles(
        captureStrip: captureStrip,
        capturePrintContent: capturePrintContent,
        saveToDevice: saveToDevice,
      );
      unawaited(
        preparing.then(
          (_) {},
          onError: (Object _) {
            if (identical(_preparing, preparing)) _preparing = null;
          },
        ),
      );
      final files = await preparing.timeout(prepareTimeout);
      _uploadQueue.add(storageSection!.id, files);
      isSectionReady = true;
      notifyListeners();
      onHideLoading();
      onUploadComplete();
    } catch (e) {
      onHideLoading();
      onShowError(e.toString());
    } finally {
      setUploadStatus('');
      _isHandlingQR = false;
    }
  }

  /// The part of [handleQRRequest] the guest waits for. The Drive folder comes
  /// first because its link is the QR drawn into the files.
  Future<Map<String, Uint8List>> _prepareFiles({
    required Future<Uint8List?> Function() captureStrip,
    required Future<Uint8List?> Function() capturePrintContent,
    required Future<void> Function(Map<String, Uint8List> files) saveToDevice,
  }) async {
    storageSection ??= await _storageService.prepareSection(sessionId!);
    if (storageSection == null) {
      throw StateError('Unable to prepare Google Drive section');
    }
    galleryUrl = AppConfig.galleryUrl(storageSection!.id);
    debugPrint('Gallery URL: $galleryUrl');
    if (kDebugMode && kIsWeb) {
      final localGalleryUrl = Uri.base.replace(
        fragment: '/gallery/${Uri.encodeComponent(storageSection!.id)}',
      );
      debugPrint('Local gallery URL: $localGalleryUrl');
    }
    notifyListeners();

    final files = await generateAllFiles(
      captureStrip: captureStrip,
      capturePrintContent: capturePrintContent,
    );
    if (files == null || files.isEmpty) {
      throw StateError('No files generated');
    }

    setUploadStatus(t.editor.savingToDevice);
    await saveToDevice(files);
    return completedFiles = files;
  }

  /// Thực hiện quy trình upload bộ sưu tập
  /// Cần truyền vào function capture để lấy dữ liệu từ UI (vì UI quản lý RepaintBoundary)
  Future<Map<String, Uint8List>?> generateAllFiles({
    required Future<Uint8List?> Function() captureStrip,
    required Future<Uint8List?> Function() capturePrintContent,
  }) async {
    if (sessionId == null && capturedPhotos.isNotEmpty) {
      sessionId = sessionIdAt(DateTime.now());
    }

    if (sessionId == null) return null;

    setUploadStatus(t.google_drive.preparing_data);

    try {
      final Map<String, Uint8List> filesToUpload = {};

      // 1. Giữ nguyên các ảnh gốc dùng để fill khung
      for (var index = 0; index < capturedPhotos.length; index++) {
        final photo = capturedPhotos[index];
        final number = (index + 1).toString().padLeft(2, '0');
        filesToUpload['${sessionId}_anh_goc_$number${_getImageExtension(photo)}'] =
            await photo.readAsBytes();
      }

      // 2. Chụp ảnh đem đi in (không có viền/perforation/indicator)
      final Uint8List? printContentCapture = await capturePrintContent();
      if (printContentCapture != null) {
        filesToUpload['${sessionId}_anh_dem_di_in.png'] = printContentCapture;
      }
      // 3. Chụp Ảnh đã ghép vào frame
      try {
        final Uint8List framedCapture = await PhotoMergerService.mergePhotos(
          photos: capturedPhotos,
          frameData: selectedFrame,
          colorFilterMatrix: FilterConfig.getFilterMatrix(
            selectedFilter,
            filterIntensity,
          ),
          isMirrored: photoIsMirrored,
          galleryUrl: galleryUrl,
          qrCorner: qrCorner,
        );
        final jpgBytes = await _convertToJpg(framedCapture);
        if (jpgBytes != null) {
          filesToUpload['${sessionId}_anh_da_ghep_khung.jpg'] = jpgBytes;
        }
      } catch (e) {
        debugPrint('Error merging photos with PhotoMergerService: $e');
        // Fallback to UI capture if something goes wrong
        final Uint8List? fallbackCapture = await captureStrip();
        if (fallbackCapture != null) {
          final jpgBytes = await _convertToJpg(fallbackCapture);
          if (jpgBytes != null) {
            filesToUpload['${sessionId}_anh_da_ghep_khung.jpg'] = jpgBytes;
          }
        }
      }
      // 4. Xử lý video recap
      if (videoRecapFile != null) {
        setUploadStatus(t.google_drive.creating_recap);

        var originalExt = _getVideoExtension(videoRecapFile!);
        Uint8List finalOriginalBytes;

        // 4.1. Xử lý video gốc (flip nếu cần)
        try {
          final flippedResult = await VideoRecapService.flipVideo(
            videoUrl: videoRecapFile?.path ?? '',
            isMirrored: videoIsMirrored,
            preferredMimeType: _getVideoMimeType(videoRecapFile!),
          );

          if (flippedResult != null) {
            finalOriginalBytes = flippedResult.bytes;
            originalExt = _getExtensionFromMimeType(flippedResult.mimeType);
          } else {
            finalOriginalBytes =
                await videoRecapFile?.readAsBytes() ?? Uint8List.fromList([]);
          }
        } catch (e) {
          debugPrint('Error flipping original video: $e');
          finalOriginalBytes =
              await videoRecapFile?.readAsBytes() ?? Uint8List.fromList([]);
        }

        filesToUpload['${sessionId}_video_recap_goc$originalExt'] =
            finalOriginalBytes;

        try {
          final result = await VideoRecapService.exportFramedVideo(
            videoUrl: videoRecapFile?.path ?? '',
            frame: selectedFrame,
            timestamps: photoTimestamps,
            recapDurationSeconds:
                AppConfig.recapClipDuration.inMilliseconds / 1000.0,
            preferredMimeType: _getVideoMimeType(videoRecapFile),
            isMirrored: videoIsMirrored,
          );

          if (result != null) {
            final extension = _getExtensionFromMimeType(result.mimeType);
            filesToUpload['${sessionId}_video_recap_gan_khung$extension'] =
                result.bytes;
          } else {
            filesToUpload['${sessionId}_video_recap_gan_khung$originalExt'] =
                finalOriginalBytes;
          }
        } catch (e) {
          debugPrint('Error generating framed video: $e');
          filesToUpload['${sessionId}_video_recap_gan_khung$originalExt'] =
              finalOriginalBytes;
        }
      }

      return filesToUpload;
    } catch (e) {
      debugPrint('Generation error: $e');
      rethrow;
    } finally {
      setUploadStatus('');
    }
  }

  String _getImageExtension(XFile file) {
    final sources = [
      file.name.toLowerCase(),
      file.path.toLowerCase().split('?').first,
    ];
    for (final extension in const [
      '.jpg',
      '.jpeg',
      '.png',
      '.heic',
      '.heif',
      '.webp',
      '.dng',
    ]) {
      if (sources.any((source) => source.endsWith(extension))) return extension;
    }

    return switch (file.mimeType?.toLowerCase()) {
      'image/png' => '.png',
      'image/heic' => '.heic',
      'image/heif' => '.heif',
      'image/webp' => '.webp',
      'image/dng' => '.dng',
      _ => '.jpg',
    };
  }

  String _getVideoExtension(XFile file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.webm')) return '.webm';
    if (path.endsWith('.mp4')) return '.mp4';
    if (path.endsWith('.mov')) return '.mov';
    if (path.endsWith('.avi')) return '.avi';
    if (path.endsWith('.3gp')) return '.3gp';

    final mimeType = file.mimeType;
    if (mimeType != null) {
      return _getExtensionFromMimeType(mimeType);
    }
    return '.mp4';
  }

  String _getExtensionFromMimeType(String mimeType) {
    final cleanMime = mimeType.toLowerCase();
    if (cleanMime.contains('webm')) return '.webm';
    if (cleanMime.contains('mp4')) return '.mp4';
    if (cleanMime.contains('quicktime') || cleanMime.contains('mov')) {
      return '.mov';
    }
    if (cleanMime.contains('3gpp')) return '.3gp';
    if (cleanMime.contains('ogg')) return '.ogv';
    if (cleanMime.contains('avi')) return '.avi';
    final parts = cleanMime.split('/');
    if (parts.length == 2) {
      final subtype = parts[1].split(';')[0].trim();
      return '.$subtype';
    }
    return '.mp4';
  }

  String? _getVideoMimeType(XFile? file) {
    if (file == null) return null;
    if (file.mimeType != null) return file.mimeType;
    final path = file.path.toLowerCase();
    if (path.endsWith('.webm')) return 'video/webm';
    if (path.endsWith('.mp4')) return 'video/mp4';
    if (path.endsWith('.mov')) return 'video/quicktime';
    return null;
  }

  Future<Uint8List?> _convertToJpg(Uint8List pngBytes) {
    return compute(_encodeJpg, pngBytes);
  }
}
