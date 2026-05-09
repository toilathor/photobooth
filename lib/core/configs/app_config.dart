import 'package:camera/camera.dart';
import 'package:my_photobooth/core/configs/filter_config.dart';

class AppConfig {
  static late List<CameraDescription> cameras;
  static const String appName = 'Photobooth';

  // Photo settings
  static const List<int> photoCounts = [1, 3, 4];
  static const List<int> countdowns = [3, 5, 10];
  static const Duration recapClipDuration = Duration(seconds: 2);

  // Filter settings
  static List<String> get filters => FilterConfig.availableFilters;

  // Voice countdown sounds
  static const Map<int, String> numberSounds = {
    1: 'mot.mp3',
    2: 'hai.mp3',
    3: 'ba.mp3',
    4: 'bon.mp3',
    5: 'nam.mp3',
    6: 'sau.mp3',
    7: 'bay.mp3',
    8: 'tam.mp3',
    9: 'chin.mp3',
    10: 'muoi.mp3',
  };
}
