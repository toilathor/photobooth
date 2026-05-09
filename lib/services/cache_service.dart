import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service quản lý cache và dọn dẹp file tạm cho ứng dụng.
class CacheService {
  /// Xóa toàn bộ file trong thư mục tạm.
  /// Hỗ trợ đa nền tảng: Mobile, Desktop và Web.
  static Future<void> clearCache() async {
    try {
      if (kIsWeb) {
        // Trên Web, các blob URL thường được quản lý bởi trình duyệt.
        // Hiện tại chưa có cơ chế xóa file vật lý trên Web như Mobile.
        debugPrint('CacheService: Xóa cache trên Web (không thực hiện gì).');
        return;
      }

      final Directory tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final List<FileSystemEntity> entities = tempDir.listSync();
        for (final FileSystemEntity entity in entities) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            debugPrint('CacheService: Không thể xóa ${entity.path}: $e');
          }
        }
        debugPrint('CacheService: Đã dọn dẹp thư mục tạm: ${tempDir.path}');
      }
    } catch (e) {
      debugPrint('CacheService: Lỗi khi xóa cache: $e');
    }
  }

  /// Tính toán dung lượng cache hiện tại (theo bytes).
  static Future<int> getCacheSize() async {
    if (kIsWeb) return 0;

    int totalSize = 0;
    try {
      final Directory tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final List<FileSystemEntity> entities = tempDir.listSync(recursive: true);
        for (final FileSystemEntity entity in entities) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('CacheService: Lỗi khi tính dung lượng cache: $e');
    }
    return totalSize;
  }

  /// Định dạng dung lượng sang chuỗi đọc được (KB, MB, GB).
  static String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const List<String> suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
}
