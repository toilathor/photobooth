import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:image/image.dart' as img;
import 'package:my_photobooth/components/google_sign_in_button.dart';
import 'package:my_photobooth/components/photobooth_header.dart';
import 'package:my_photobooth/core/configs/app_config.dart';
import 'package:my_photobooth/core/configs/storage_config.dart';
import 'package:my_photobooth/features/edit_photo/edit_photo.provider.dart';
import 'package:my_photobooth/features/edit_photo/widgets/editor_panel.dart';
import 'package:my_photobooth/features/edit_photo/widgets/preview_panel.dart';
import 'package:my_photobooth/features/edit_photo/widgets/qr_share_dialog.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:my_photobooth/services/storage_factory.dart';
import 'package:my_photobooth/services/video_recap_service.dart';
import 'package:provider/provider.dart';

class EditPhotoScreen extends StatefulWidget {
  const EditPhotoScreen({super.key});

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final GlobalKey _stripKey = GlobalKey();
  final GlobalKey _paperKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Khởi tạo storage service được chọn
    StorageFactory.instance.init();

    // Lắng nghe thay đổi đăng nhập
    StorageFactory.instance.onCurrentUserChanged.listen((account) {
      if (account != null && mounted) {
        // Xử lý đồng bộ nếu cần
      }
    });
  }

  Future<void> _handleQRRequest(BuildContext context) async {
    // Nếu không cấu hình storage thì không làm gì
    if (StorageConfig.activeStorage == StorageType.none) return;

    final photoboothProvider = context.read<PhotoboothProvider>();
    String? sessionId = photoboothProvider.sessionId;

    // Fallback nếu sessionId bị null
    if (sessionId == null && photoboothProvider.capturedPhotos.isNotEmpty) {
      sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      photoboothProvider.sessionId = sessionId;
    }

    if (sessionId == null) return;

    try {
      // 1. Kiểm tra xem bộ ảnh này đã được upload chưa
      // Hiển thị loading trong khi kiểm tra
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );

      final existingUrl = await StorageFactory.instance.getFolderLink(
        sessionId,
      );

      // Đóng loading kiểm tra
      if (context.mounted) Navigator.pop(context);

      if (existingUrl != null) {
        if (context.mounted) {
          showDialog<void>(
            context: context,
            builder: (context) => QRShareDialog(url: existingUrl),
          );
        }
        return;
      }

      // 2. Kiểm tra đăng nhập (đối với Web)
      if (kIsWeb && StorageFactory.instance.currentUser == null) {
        if (context.mounted) {
          bool isProcessingLogin = false;
          late StreamSubscription<dynamic> subscription;
          subscription = StorageFactory.instance.onCurrentUserChanged.listen((
            account,
          ) {
            if (account != null && !isProcessingLogin) {
              isProcessingLogin = true;
              subscription.cancel();

              if (context.mounted) {
                Navigator.of(context).pop(); // Đóng Login Dialog
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    _executeUpload(context);
                  }
                });
              }
            }
          });

          showWebLoginDialog(context, onLoginSuccess: () {});
        }
        return;
      }

      // 3. Nếu đã đăng nhập và chưa upload, thực hiện upload
      if (context.mounted) {
        _executeUpload(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.google_drive.error(error: e.toString()))),
        );
      }
    }
  }

  Future<Uint8List?> _captureFromKey(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      // Pixel ratio cực cao (6.0) để đảm bảo "siêu nét" trên mọi thiết bị
      final image = await boundary.toImage(pixelRatio: 6.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing from key: $e');
      return null;
    }
  }

  // Logic upload bộ sưu tập - Tối ưu hóa mượt mà và tin cậy hơn
  Future<void> _executeUpload(BuildContext context) async {
    final photoboothProvider = context.read<PhotoboothProvider>();
    final editPhotoProvider = context.read<EditPhotoProvider>();
    final sessionId = photoboothProvider.sessionId!;

    // Sử dụng ValueNotifier để cập nhật Progress ổn định hơn
    final uploadProgressNotifier = ValueNotifier<_UploadProgressData>(
      _UploadProgressData(
        statusMessage: 'Đang chuẩn bị dữ liệu...',
        isPreparing: true,
      ),
    );

    try {
      // Hiển thị loading premium dùng ValueListenableBuilder
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ValueListenableBuilder<_UploadProgressData>(
            valueListenable: uploadProgressNotifier,
            builder: (context, data, _) {
              double progress = data.total > 0 ? data.current / data.total : 0;
              final colorScheme = Theme.of(context).colorScheme;

              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: data.isPreparing ? null : progress,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              backgroundColor: colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.secondary,
                              ),
                            ),
                            if (!data.isPreparing)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(progress * 100).toInt()}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.secondary,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.secondary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: colorScheme.secondary,
                                size: 40,
                              ),
                          ],
                        ),
                      ),
                      const Gap(32),
                      Text(
                        data.isPreparing
                            ? 'ĐANG CHUẨN BỊ'
                            : t.google_drive.uploading.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        data.statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      final Map<String, Uint8List> filesToUpload = {};

      // Đợi một chút để đảm bảo các thành phần UI đã ổn định trước khi bắt đầu chụp
      await Future<dynamic>.delayed(const Duration(milliseconds: 600));

      // 1. Chụp "Ảnh bản in dạng final trên giấy in"
      final originalPaperMode = editPhotoProvider.showPaperPreview;
      if (!originalPaperMode) {
        editPhotoProvider.togglePaperPreview(true);
      }
      // Luôn delay một chút để UI render chắc chắn, tránh việc bị thiếu tệp
      await Future<dynamic>.delayed(const Duration(milliseconds: 600));

      final printBytes = await _captureFromKey(_paperKey);
      if (printBytes != null) {
        // Chuyển đổi PNG sang JPG để tiết kiệm dung lượng và đúng yêu cầu
        final image = img.decodePng(printBytes);
        if (image != null) {
          filesToUpload['anh_ban_in_final.jpg'] = Uint8List.fromList(
            img.encodeJpg(image, quality: 90),
          );
        }
      }

      // 2. Chụp "Ảnh đã ghép vào frame" (Luôn là bản đơn - 1 dải)
      final originalPrintTwoCopies = editPhotoProvider.printTwoCopies;
      editPhotoProvider.togglePaperPreview(false);
      if (originalPrintTwoCopies) {
        editPhotoProvider.togglePrintTwoCopies(false);
      }
      // Đợi UI render lại trạng thái 1 dải ảnh
      await Future<dynamic>.delayed(const Duration(milliseconds: 500));

      final framedBytes = await _captureFromKey(_stripKey);
      if (framedBytes != null) {
        // Chuyển đổi PNG sang JPG
        final image = img.decodePng(framedBytes);
        if (image != null) {
          filesToUpload['anh_da_ghep_khung.jpg'] = Uint8List.fromList(
            img.encodeJpg(image, quality: 90),
          );
        }
      }

      // Khôi phục trạng thái cũ (cả Paper Mode và Print Two Copies)
      if (originalPaperMode) {
        editPhotoProvider.togglePaperPreview(true);
      }
      if (originalPrintTwoCopies) {
        editPhotoProvider.togglePrintTwoCopies(true);
      }
      // Đợi UI ổn định sau khi khôi phục trạng thái
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));

      // 3. Đính kèm video nếu có
      if (photoboothProvider.videoRecapFile != null) {
        // Thông báo đang xử lý video
        uploadProgressNotifier.value = _UploadProgressData(
          isPreparing: true,
          statusMessage: t.google_drive.creating_recap,
        );

        final videoBytes =
            await photoboothProvider.videoRecapFile!.readAsBytes();
        final videoUrl = photoboothProvider.videoRecapFile!.path;

        // Lưu video recap gốc
        filesToUpload['video_recap_goc.mp4'] = videoBytes;

        try {
          // Tạo video recap gắn khung bằng JS Canvas Engine
          final framedVideoBytes = await VideoRecapService.exportFramedVideo(
            videoUrl: videoUrl,
            frame: editPhotoProvider.selectedFrame,
            timestamps: photoboothProvider.photoTimestamps,
            recapDurationSeconds:
                AppConfig.recapClipDuration.inMilliseconds / 1000.0,
          );

          if (framedVideoBytes != null) {
            filesToUpload['video_recap_gan_khung.mp4'] = framedVideoBytes;
          } else {
            // Nếu lỗi, sử dụng video gốc làm fallback
            filesToUpload['video_recap_gan_khung.mp4'] = videoBytes;
          }
        } catch (e) {
          debugPrint('Error generating framed video: $e');
          filesToUpload['video_recap_gan_khung.mp4'] = videoBytes;
        }
      }

      // Thực hiện upload collection
      final url = await StorageFactory.instance.uploadCollection(
        files: filesToUpload,
        folderName: sessionId,
        onProgress: (c, t) {
          uploadProgressNotifier.value = _UploadProgressData(
            current: c,
            total: t,
            isPreparing: false,
            statusMessage: 'Đang tải tệp $c/$t...',
          );
        },
      );

      // Đóng loading
      if (context.mounted) Navigator.pop(context);

      if (url != null) {
        if (context.mounted) {
          showDialog<void>(
            context: context,
            builder: (context) => QRShareDialog(url: url),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.google_drive.error(error: 'Upload failed')),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Đóng loading nếu lỗi
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.google_drive.error(error: e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<PhotoboothProvider, EditPhotoProvider>(
      builder: (context, photoboothProvider, editPhotoProvider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const PhotoboothHeader(),
                  Expanded(
                    child: Row(
                      children: [
                        PreviewPanel(
                          stripKey: _stripKey,
                          paperKey: _paperKey,
                          photos: photoboothProvider.capturedPhotos,
                          selectedFrame: editPhotoProvider.selectedFrame,
                          availableFrames: editPhotoProvider.filteredFrames,
                          printTwoCopies: editPhotoProvider.printTwoCopies,
                          showPaperPreview: editPhotoProvider.showPaperPreview,
                          onTogglePrintTwoCopies:
                              editPhotoProvider.togglePrintTwoCopies,
                          onTogglePaperPreview:
                              editPhotoProvider.togglePaperPreview,
                          videoRecapFile: photoboothProvider.videoRecapFile,
                          photoTimestamps: photoboothProvider.photoTimestamps,
                          selectedFilter: editPhotoProvider.selectedFilter,
                          filterIntensity: editPhotoProvider.filterIntensity,
                        ),
                        const Gap(24),
                        EditorPanel(
                          availableFrames: editPhotoProvider.filteredFrames,
                          selectedFrame: editPhotoProvider.selectedFrame.path,
                          onFrameSelected: editPhotoProvider.setSelectedFrame,
                          photos: photoboothProvider.capturedPhotos,
                          videoRecapFile: photoboothProvider.videoRecapFile,
                          photoTimestamps: photoboothProvider.photoTimestamps,
                          isProcessing: editPhotoProvider.isProcessing,
                          filters: editPhotoProvider.filters,
                          selectedFilter: editPhotoProvider.selectedFilter,
                          filterIntensity: editPhotoProvider.filterIntensity,
                          onFilterSelected: editPhotoProvider.setFilter,
                          onFilterIntensityChanged:
                              editPhotoProvider.setFilterIntensity,
                          onQRRequested:
                              StorageConfig.activeStorage == StorageType.none
                                  ? null
                                  : () => _handleQRRequest(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UploadProgressData {
  final int current;
  final int total;
  final bool isPreparing;
  final String statusMessage;

  _UploadProgressData({
    this.current = 0,
    this.total = 0,
    this.isPreparing = false,
    this.statusMessage = '',
  });
}
