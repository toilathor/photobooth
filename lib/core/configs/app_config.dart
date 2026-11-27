import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
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

  /// Start of every session name (Drive folder, zip, files): the wedding's
  /// own name on the personal build.
  static String get sessionPrefix =>
      flavor == AppFlavor.personal ? 'thohien-wedding' : 'photobooth';

  static String get appName =>
      flavor == AppFlavor.personal ? 'TH PhotoBooth' : 'PhotoBooth';
  static ThemeData get theme => flavor == AppFlavor.personal
      ? ThemeConfig.weddingTheme
      : ThemeConfig.commercialLightTheme;

  static ThemeData get darkTheme => flavor == AppFlavor.personal
      ? ThemeConfig.weddingTheme
      : ThemeConfig.commercialDarkTheme;

  // Photo settings
  /// Photo count of the "standard" mode: the 2-photo layout for personal and
  /// the 4-photo strip for commercial. It is also the default selection.
  static int get standardPhotoCount => flavor == AppFlavor.personal ? 2 : 4;

  static int get defaultPhotoCount => standardPhotoCount;

  /// Photo counts the flavor can offer (group shot and standard).
  static List<int> get photoCounts => [1, standardPhotoCount];
  static const List<int> countdowns = [3, 5, 10];
  static const Duration recapClipDuration = Duration(seconds: 3);
  static const Size printPixelSize = Size(2480, 3688);

  /// Frame folder under `assets/frames/`, one per flavor so that frames of
  /// different builds never mix.
  static String get framesFolder => flavor.name;

  /// Asset root of this flavor's frames (contains `data.json`, `collected/`,
  /// `standard/`, `group/`). Frames are bundled with the app, see the `frames` block in
  /// pubspec.yaml (maintained by `lib/helper/update_frames_data.dart`).
  static String get framesAssetRoot => 'assets/frames/$framesFolder/';
  static const String galleryBaseUrl =
      'https://toilathor.github.io/photobooth/';

  static String galleryUrl(String sectionId) =>
      '$galleryBaseUrl#/gallery/${Uri.encodeComponent(sectionId)}';

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
