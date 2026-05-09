class AssetConfig {
  // Base paths
  static const String soundPath = 'sounds/';
  static const String framePath = 'assets/frames/';
  static const String sampleFilter = 'assets/images/sample_filter.png';

  // Specific sounds
  static const String soundCamera = 'camera.mp3';
  static const String soundPrepare = 'chuan_bi.mp3';

  // Helper to get sound path
  static String getSoundPath(String fileName) => 'sounds/$fileName';
}
