import 'package:th_photobooth/gen/assets.gen.dart';

class AssetConfig {
  // Base paths
  static const String soundPath = 'sounds/';
  static const String framePath = 'assets/frames/';

  // Specific sounds (extract relative filename from type-safe Assets path)
  static final String soundCamera = Assets.sounds.camera.replaceFirst('assets/sounds/', '');
  static final String soundPrepare = Assets.sounds.chuanBi.replaceFirst('assets/sounds/', '');

  // Helper to get sound path
  static String getSoundPath(String fileName) => 'sounds/$fileName';
}
