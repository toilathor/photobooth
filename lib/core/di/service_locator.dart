import 'package:get_it/get_it.dart';
import '../../features/photobooth/providers/photobooth.provider.dart';
import '../../features/edit_photo/providers/edit_photo.provider.dart';
import '../../services/storage_factory.dart';
import '../../services/storage_service_interface.dart';

final locator = GetIt.instance;

void setupServiceLocator() {
  // PhotoboothProvider: Singleton (giữ trạng thái camera/session xuyên suốt app)
  if (!locator.isRegistered<PhotoboothProvider>()) {
    locator.registerLazySingleton<PhotoboothProvider>(
      () => PhotoboothProvider(),
    );
  }

  if (!locator.isRegistered<StorageService>()) {
    locator.registerLazySingleton<StorageService>(
      () => StorageFactory.instance,
    );
  }

  // EditPhotoProvider: Factory (tạo mới mỗi lần chuyển vào màn hình Edit)
  if (!locator.isRegistered<EditPhotoProvider>()) {
    locator.registerFactory<EditPhotoProvider>(
      () => EditPhotoProvider(storageService: locator<StorageService>()),
    );
  }
}
