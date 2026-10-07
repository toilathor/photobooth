import 'storage_service_interface.dart';
import 'google_drive_service.dart';
import 'no_op_storage_service.dart';
import '../core/configs/storage_config.dart';

class StorageFactory {
  static StorageService? _instance;
  static Future<void>? _initialization;

  static StorageService get instance {
    if (_instance != null) return _instance!;

    switch (StorageConfig.activeStorage) {
      case StorageType.googleDrive:
        _instance = GoogleDriveService();
        break;
      case StorageType.none:
        _instance = NoOpStorageService();
        break;
    }
    return _instance!;
  }

  /// Kiểm tra storage có được kích hoạt hay không
  static bool get isEnabled => StorageConfig.activeStorage != StorageType.none;

  /// Initializes storage once, even when multiple screens request it.
  static Future<void> init() async {
    final initialization = _initialization ??= instance.init();
    try {
      await initialization;
    } catch (_) {
      if (identical(_initialization, initialization)) {
        _initialization = null;
      }
      rethrow;
    }
  }
}
