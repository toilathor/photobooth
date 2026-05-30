import 'package:get_it/get_it.dart';
import '../../features/photobooth/providers/photobooth.provider.dart';
import '../../features/edit_photo/providers/edit_photo.provider.dart';

final locator = GetIt.instance;

void setupServiceLocator() {
  // PhotoboothProvider: Singleton (giữ trạng thái camera/session xuyên suốt app)
  locator.registerLazySingleton<PhotoboothProvider>(() => PhotoboothProvider());

  // EditPhotoProvider: Factory (tạo mới mỗi lần chuyển vào màn hình Edit)
  locator.registerFactory<EditPhotoProvider>(() => EditPhotoProvider());
}
