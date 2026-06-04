import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:th_photobooth/services/frame_service.dart';

import 'video_recap_service.dart';

class VideoRecapService {
  /// Xuất video recap đã được gắn vào khung (frame)
  static Future<FramedVideoResult?> exportFramedVideo({
    required String videoUrl,
    required FrameData frame,
    required List<Duration> timestamps,
    required double recapDurationSeconds,
    String? preferredMimeType,
    bool isMirrored = false,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String outputPath =
          '${tempDir.path}/recap_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String frameImagePath =
          '${tempDir.path}/frame_${DateTime.now().millisecondsSinceEpoch}.png';

      // 1. Tải ảnh frame từ assets hoặc mạng và lưu vào file tạm để FFmpeg có thể đọc
      final ByteData frameByteData = await FrameService.loadFrameBytes(
        frame.path,
      );
      final File frameFile = File(frameImagePath);
      await frameFile.writeAsBytes(frameByteData.buffer.asUint8List());

      // Làm sạch đường dẫn videoUrl (loại bỏ file:// nếu có)
      String cleanVideoUrl = videoUrl;
      if (cleanVideoUrl.startsWith('file://')) {
        cleanVideoUrl = cleanVideoUrl.substring(7);
      }

      // 2. Lấy độ phân giải và thông tin video gốc bằng FFprobe
      final mediaInformation = await FFprobeKit.getMediaInformation(
        cleanVideoUrl,
      );
      final info = mediaInformation.getMediaInformation();
      if (info == null) {
        if (kDebugMode) {
          debugPrint('FFprobe failed to get media info for: $cleanVideoUrl');
          final returnCode = await mediaInformation.getReturnCode();
          final stackTrace = await mediaInformation.getFailStackTrace();
          debugPrint('FFprobe Return Code: $returnCode');
          debugPrint('FFprobe Stack Trace: $stackTrace');
          final logs = await mediaInformation.getLogs();
          for (var log in logs) {
            debugPrint('FFprobe Log: ${log.getMessage()}');
          }
        }
        // Dọn dẹp frame tạm
        if (await frameFile.exists()) {
          await frameFile.delete();
        }
        return null;
      }

      final streams = info.getStreams();
      if (streams.isEmpty) {
        // Dọn dẹp frame tạm
        if (await frameFile.exists()) {
          await frameFile.delete();
        }
        return null;
      }

      int videoWidth = 0;
      int videoHeight = 0;
      int rotation = 0;

      // Phương pháp 1: Quét nhật ký (logs) của phiên FFprobe vừa chạy
      try {
        final mediaLogs = await mediaInformation.getLogs();
        for (final log in mediaLogs) {
          final message = log.getMessage();
          if (message.contains('rotation of')) {
            final match = RegExp(
              r'rotation of (-?\d+(?:\.\d+)?)',
            ).firstMatch(message);
            if (match != null) {
              final val = double.tryParse(match.group(1) ?? '');
              if (val != null) {
                rotation = val.round().abs();
                break;
              }
            }
          }
          if (rotation == 0 &&
              (message.contains('rotate') || message.contains('rotation'))) {
            final match = RegExp(
              r'(?:rotate|rotation)[^0-9-]*(-?\d+)',
            ).firstMatch(message);
            if (match != null) {
              rotation = (int.tryParse(match.group(1) ?? '') ?? 0).abs();
              break;
            }
          }
        }
        if (kDebugMode && rotation != 0) {
          debugPrint('Detected rotation from FFprobe logs: $rotation');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error getting rotation from FFprobe logs: $e');
        }
      }

      // Phương pháp 2: Thực thi lệnh ffprobe thô xuất JSON để lấy rotate/rotation
      if (rotation == 0) {
        try {
          final rotationSession = await FFprobeKit.execute(
            '-v error -select_streams v:0 -show_entries stream=tags:side_data -of json "$cleanVideoUrl"',
          );
          final rawJsonOutput = await rotationSession.getOutput();
          if (rawJsonOutput != null && rawJsonOutput.trim().isNotEmpty) {
            final parsed = jsonDecode(rawJsonOutput);
            if (parsed is Map<String, dynamic>) {
              final streamsList = parsed['streams'];
              if (streamsList is List && streamsList.isNotEmpty) {
                final stream = streamsList[0];
                if (stream is Map<String, dynamic>) {
                  final tags = stream['tags'];
                  if (tags is Map) {
                    final rotateVal = tags['rotate'];
                    if (rotateVal != null) {
                      rotation = (double.tryParse(rotateVal.toString()) ?? 0.0)
                          .round()
                          .abs();
                    }
                  }
                  if (rotation == 0) {
                    final sideDataList = stream['side_data_list'];
                    if (sideDataList is List) {
                      for (final sideData in sideDataList) {
                        if (sideData is Map &&
                            sideData['side_data_type'] == 'Display Matrix') {
                          final rotationVal = sideData['rotation'];
                          if (rotationVal != null) {
                            rotation =
                                (double.tryParse(rotationVal.toString()) ?? 0.0)
                                    .round()
                                    .abs();
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          if (kDebugMode && rotation != 0) {
            debugPrint('Detected rotation via raw JSON FFprobe: $rotation');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error getting rotation via raw JSON FFprobe: $e');
          }
        }
      }

      // Phương pháp 3: Thực thi chạy thử FFmpeg chỉ để lấy log format
      if (rotation == 0) {
        try {
          final dummySession = await FFmpegKit.execute('-i "$cleanVideoUrl"');
          final dummyLogs = await dummySession.getLogs();
          for (final log in dummyLogs) {
            final message = log.getMessage();
            if (message.contains('rotation of')) {
              final match = RegExp(
                r'rotation of (-?\d+(?:\.\d+)?)',
              ).firstMatch(message);
              if (match != null) {
                final val = double.tryParse(match.group(1) ?? '');
                if (val != null) {
                  rotation = val.round().abs();
                  break;
                }
              }
            }
          }
          if (kDebugMode && rotation != 0) {
            debugPrint('Detected rotation from dummy FFmpeg logs: $rotation');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error getting rotation from dummy FFmpeg logs: $e');
          }
        }
      }

      // Phương pháp 4: Dự phòng cuối cùng dựa trên thực tế thiết bị di động quay video dọc
      if (rotation == 0) {
        for (final stream in streams) {
          if (stream.getType() == 'video') {
            videoWidth = stream.getWidth() ?? 0;
            videoHeight = stream.getHeight() ?? 0;

            // Nếu tệp có chiều rộng ngang (width > height) nhưng ứng dụng chạy dọc,
            // camera mặc định ghi dọc luôn có metadata xoay 90 hoặc 270.
            if (videoWidth > videoHeight) {
              rotation = 90;
              if (kDebugMode) {
                debugPrint(
                  'Fallback: no rotation metadata found, but file is landscape. Assuming portrait rotation 90.',
                );
              }
            }
            break;
          }
        }
      }

      for (final stream in streams) {
        if (stream.getType() == 'video') {
          videoWidth = stream.getWidth() ?? 0;
          videoHeight = stream.getHeight() ?? 0;

          // Phương pháp 5: Dự phòng cuối cùng nếu quét các nơi không tìm thấy
          if (rotation == 0) {
            final properties = stream.getAllProperties();
            final tags = properties?['tags'];
            if (tags is Map) {
              final rotateVal = tags['rotate'];
              if (rotateVal != null) {
                rotation = int.tryParse(rotateVal.toString()) ?? 0;
              }
            }
            final sideDataList = properties?['side_data_list'];
            if (sideDataList is List) {
              for (final sideData in sideDataList) {
                if (sideData is Map &&
                    sideData['side_data_type'] == 'Display Matrix') {
                  final rotationVal = sideData['rotation'];
                  if (rotationVal != null) {
                    final parsedRotation =
                        (double.tryParse(rotationVal.toString()) ?? 0.0)
                            .round();
                    rotation = parsedRotation.abs();
                  }
                }
              }
            }
          }
          break;
        }
      }

      if (videoWidth == 0 || videoHeight == 0) {
        // Dọn dẹp frame tạm
        if (await frameFile.exists()) {
          await frameFile.delete();
        }
        return null;
      }

      // Xử lý xoay video: Nếu video bị xoay dọc (90 hoặc 270 độ), tráo đổi width và height
      if (rotation == 90 || rotation == 270) {
        final temp = videoWidth;
        videoWidth = videoHeight;
        videoHeight = temp;
      }

      double videoDuration = 0.0;
      final durationStr = info.getDuration();
      if (durationStr != null) {
        videoDuration = double.tryParse(durationStr) ?? 0.0;
      }
      if (videoDuration <= 0) {
        videoDuration = recapDurationSeconds * frame.slots.length;
      }

      // 3. Khởi tạo filter graph
      final filterGraph = _generateFilterGraph(
        videoWidth: videoWidth,
        videoHeight: videoHeight,
        videoDuration: videoDuration,
        frame: frame,
        timestamps: timestamps,
        recapDurationSeconds: recapDurationSeconds,
        isMirrored: isMirrored,
      );

      // 4. Gọi FFmpeg sử dụng libx264 encoder (được hỗ trợ hoàn toàn bởi gói full-gpl của dự án) để đảm bảo khả năng chạy được trên mọi thiết bị
      final command =
          '-y -i "$cleanVideoUrl" -i "$frameImagePath" -filter_complex "$filterGraph" -map "[outv]" -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      // Dọn dẹp frame tạm
      if (await frameFile.exists()) {
        await frameFile.delete();
      }

      if (ReturnCode.isSuccess(returnCode)) {
        final File outputFile = File(outputPath);
        final bytes = await outputFile.readAsBytes();

        // Dọn dẹp video xuất
        await outputFile.delete();

        return FramedVideoResult(bytes: bytes, mimeType: 'video/mp4');
      } else {
        if (kDebugMode) {
          final logs = await session.getLogs();
          debugPrint('FFmpeg Error Logs:');
          for (var log in logs) {
            debugPrint(log.getMessage());
          }
          final failStackTrace = await session.getFailStackTrace();
          debugPrint('FFmpeg Fail Stack Trace: $failStackTrace');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error exporting framed video recap: $e');
      }
      return null;
    }
  }

  /// Lật video (flip) theo chiều ngang
  static Future<FramedVideoResult?> flipVideo({
    required String videoUrl,
    required bool isMirrored,
    String? preferredMimeType,
  }) async {
    if (!isMirrored) {
      final file = File(videoUrl);
      if (await file.exists()) {
        return FramedVideoResult(
          bytes: await file.readAsBytes(),
          mimeType: 'video/mp4',
        );
      }
      return null;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final String outputPath =
          '${tempDir.path}/flipped_${DateTime.now().millisecondsSinceEpoch}.mp4';

      String cleanVideoUrl = videoUrl;
      if (cleanVideoUrl.startsWith('file://')) {
        cleanVideoUrl = cleanVideoUrl.substring(7);
      }

      // Tắt audio (-an) và sử dụng libx264 encoder để đảm bảo khả năng tương thích cao nhất và tránh lỗi không có audio stream
      final command =
          '-y -i "$cleanVideoUrl" -vf hflip -c:v libx264 -preset ultrafast -pix_fmt yuv420p -an "$outputPath"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final File outputFile = File(outputPath);
        final bytes = await outputFile.readAsBytes();
        await outputFile.delete();

        return FramedVideoResult(bytes: bytes, mimeType: 'video/mp4');
      } else {
        if (kDebugMode) {
          final logs = await session.getLogs();
          debugPrint('FFmpeg flipVideo Error Logs:');
          for (var log in logs) {
            debugPrint(log.getMessage());
          }
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error flipping raw video: $e');
      }
      return null;
    }
  }

  static String _generateFilterGraph({
    required int videoWidth,
    required int videoHeight,
    required double videoDuration,
    required FrameData frame,
    required List<Duration> timestamps,
    required double recapDurationSeconds,
    required bool isMirrored,
  }) {
    final StringBuffer filter = StringBuffer();
    final double videoAspect = videoWidth / videoHeight;

    // Đảm bảo kích thước canvas luôn là số chẵn để tương thích yuv420p
    final int canvasWidth = (frame.size.width.toInt() ~/ 2) * 2;
    final int canvasHeight = (frame.size.height.toInt() ~/ 2) * 2;

    final int slotCount = frame.slots.length;
    if (slotCount == 0) return '';

    // Phân tách luồng video đầu vào thành nhiều luồng để dùng cho từng slot
    String splitOut = '';
    for (int i = 0; i < slotCount; i++) {
      splitOut += '[in$i]';
    }
    filter.write('[0:v]split=$slotCount$splitOut;');

    // Tạo 1 base video nền đen với thời lượng bằng `recapDurationSeconds`
    filter.write(
      'color=c=black:s=${canvasWidth}x$canvasHeight:d=$recapDurationSeconds:rate=30[base];',
    );

    for (int i = 0; i < slotCount; i++) {
      final slot = frame.slots[i];

      double photoTime;
      if (timestamps.length > i) {
        photoTime = (timestamps[i].inMilliseconds / 1000.0).clamp(
          0.0,
          videoDuration,
        );
      } else {
        if (slotCount > 1) {
          photoTime = ((i + 1) / slotCount) * videoDuration;
        } else {
          photoTime = videoDuration;
        }
      }

      double startTime = (photoTime - recapDurationSeconds).clamp(
        0.0,
        videoDuration,
      );
      if (photoTime - startTime < 0.5) {
        if (photoTime >= 0.5) {
          startTime = photoTime - 0.5;
        } else {
          photoTime = (startTime + 0.5).clamp(0.0, videoDuration);
        }
      }

      final slotAspect = slot.width / slot.height;

      // 1. Cắt video theo thời lượng slot
      filter.write(
        '[in$i]trim=start=$startTime:end=$photoTime,setpts=PTS-STARTPTS[v$i];',
      );

      // 2. Tính toán Crop (Cắt ảnh theo tỉ lệ slot giống object-fit: cover)
      double cropWidth, cropHeight, cropX, cropY;
      if (videoAspect > slotAspect) {
        cropHeight = videoHeight.toDouble();
        cropWidth = cropHeight * slotAspect;
        cropX = (videoWidth - cropWidth) / 2;
        cropY = 0;
      } else {
        cropWidth = videoWidth.toDouble();
        cropHeight = cropWidth / slotAspect;
        cropX = 0;
        cropY = (videoHeight - cropHeight) / 2;
      }

      // Đảm bảo các tham số crop luôn là số chẵn
      final int cropWidthEven = (cropWidth.toInt() ~/ 2) * 2;
      final int cropHeightEven = (cropHeight.toInt() ~/ 2) * 2;
      final int cropXEven = (cropX.toInt() ~/ 2) * 2;
      final int cropYEven = (cropY.toInt() ~/ 2) * 2;

      // 3. Crop
      filter.write(
        '[v$i]crop=$cropWidthEven:$cropHeightEven:$cropXEven:$cropYEven[vcrop$i];',
      );

      // Đảm bảo kích thước scale luôn là số chẵn
      final int scaleWidthEven = (slot.width.toInt() ~/ 2) * 2;
      final int scaleHeightEven = (slot.height.toInt() ~/ 2) * 2;

      // 4. Scale
      filter.write(
        '[vcrop$i]scale=$scaleWidthEven:$scaleHeightEven[vscale$i];',
      );

      // 5. Flip (nếu có)P
      String finalSeg = 'vscale$i';
      if (isMirrored) {
        filter.write('[$finalSeg]hflip[vflip$i];');
        finalSeg = 'vflip$i';
      }

      // 6. Overlay lên background
      final String bgIn = i == 0 ? 'base' : 'bg${i - 1}';
      final String bgOut = 'bg$i';
      filter.write(
        '[$bgIn][$finalSeg]overlay=${slot.left.toInt()}:${slot.top.toInt()}:eof_action=repeat[$bgOut];',
      );
    }

    final int lastIdx = slotCount - 1;
    final String finalBg = 'bg$lastIdx';

    // 7. Overlay frame image lên trên cùng
    filter.write('[$finalBg][1:v]overlay=0:0:eof_action=repeat[outv]');

    return filter.toString();
  }
}
