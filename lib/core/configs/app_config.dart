import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:th_photobooth/core/configs/filter_config.dart';
import 'package:th_photobooth/core/configs/flavor_detector.dart';
import 'package:th_photobooth/core/configs/theme_config.dart';

enum AppFlavor { personal, commercial }

class AppConfig {
  static late List<CameraDescription> cameras;

  static final AppFlavor flavor = _getFlavor();

  static AppFlavor _getFlavor() {
    final webFlavor = getWebFlavor();
    if (webFlavor != null) {
      return webFlavor == 'personal'
          ? AppFlavor.personal
          : AppFlavor.commercial;
    }
    final flavorString = appFlavor;
    if (flavorString != null) {
      for (final flavor in AppFlavor.values) {
        if (flavor.name == flavorString) {
          return flavor;
        }
      }
    }
    return AppFlavor.personal;
  }

  static String get appName =>
      flavor == AppFlavor.personal ? 'TH PhotoBooth' : 'PhotoBooth';
  static ThemeData get theme => flavor == AppFlavor.personal
      ? ThemeConfig.weddingTheme
      : ThemeConfig.commercialLightTheme;

  static ThemeData get darkTheme => flavor == AppFlavor.personal
      ? ThemeConfig.weddingTheme
      : ThemeConfig.commercialDarkTheme;

  // Photo settings
  static const List<int> photoCounts = [1, 4];
  static const List<int> countdowns = [3, 5, 10];
  static const Duration recapClipDuration = Duration(seconds: 3);
  static const String githubFramesBaseUrl =
      'https://raw.githubusercontent.com/toilathor/photobooth/master/assets/frames/collected/';

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
