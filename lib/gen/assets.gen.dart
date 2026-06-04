// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/branding_commercial.png
  AssetGenImage get brandingCommercial =>
      const AssetGenImage('assets/images/branding_commercial.png');

  /// File path: assets/images/branding_commercial_dark.png
  AssetGenImage get brandingCommercialDark =>
      const AssetGenImage('assets/images/branding_commercial_dark.png');

  /// File path: assets/images/branding_personal.png
  AssetGenImage get brandingPersonal =>
      const AssetGenImage('assets/images/branding_personal.png');

  /// File path: assets/images/branding_personal_dark.png
  AssetGenImage get brandingPersonalDark =>
      const AssetGenImage('assets/images/branding_personal_dark.png');

  /// File path: assets/images/ic_launcher.png
  AssetGenImage get icLauncher =>
      const AssetGenImage('assets/images/ic_launcher.png');

  /// File path: assets/images/ic_launcher_background.png
  AssetGenImage get icLauncherBackground =>
      const AssetGenImage('assets/images/ic_launcher_background.png');

  /// File path: assets/images/ic_launcher_commercial.png
  AssetGenImage get icLauncherCommercial =>
      const AssetGenImage('assets/images/ic_launcher_commercial.png');

  /// File path: assets/images/ic_launcher_commercial_background.png
  AssetGenImage get icLauncherCommercialBackground => const AssetGenImage(
    'assets/images/ic_launcher_commercial_background.png',
  );

  /// File path: assets/images/ic_launcher_commercial_dark.png
  AssetGenImage get icLauncherCommercialDark =>
      const AssetGenImage('assets/images/ic_launcher_commercial_dark.png');

  /// File path: assets/images/ic_launcher_commercial_foreground.png
  AssetGenImage get icLauncherCommercialForeground => const AssetGenImage(
    'assets/images/ic_launcher_commercial_foreground.png',
  );

  /// File path: assets/images/ic_launcher_commercial_monochrome.png
  AssetGenImage get icLauncherCommercialMonochrome => const AssetGenImage(
    'assets/images/ic_launcher_commercial_monochrome.png',
  );

  /// File path: assets/images/ic_launcher_dark.png
  AssetGenImage get icLauncherDark =>
      const AssetGenImage('assets/images/ic_launcher_dark.png');

  /// File path: assets/images/ic_launcher_foreground.png
  AssetGenImage get icLauncherForeground =>
      const AssetGenImage('assets/images/ic_launcher_foreground.png');

  /// File path: assets/images/ic_launcher_monochrome.png
  AssetGenImage get icLauncherMonochrome =>
      const AssetGenImage('assets/images/ic_launcher_monochrome.png');

  /// File path: assets/images/sample_filter.png
  AssetGenImage get sampleFilter =>
      const AssetGenImage('assets/images/sample_filter.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    brandingCommercial,
    brandingCommercialDark,
    brandingPersonal,
    brandingPersonalDark,
    icLauncher,
    icLauncherBackground,
    icLauncherCommercial,
    icLauncherCommercialBackground,
    icLauncherCommercialDark,
    icLauncherCommercialForeground,
    icLauncherCommercialMonochrome,
    icLauncherDark,
    icLauncherForeground,
    icLauncherMonochrome,
    sampleFilter,
  ];
}

class $AssetsSoundsGen {
  const $AssetsSoundsGen();

  /// File path: assets/sounds/ba.mp3
  String get ba => 'assets/sounds/ba.mp3';

  /// File path: assets/sounds/bay.mp3
  String get bay => 'assets/sounds/bay.mp3';

  /// File path: assets/sounds/bon.mp3
  String get bon => 'assets/sounds/bon.mp3';

  /// File path: assets/sounds/camera.mp3
  String get camera => 'assets/sounds/camera.mp3';

  /// File path: assets/sounds/chin.mp3
  String get chin => 'assets/sounds/chin.mp3';

  /// File path: assets/sounds/chuan_bi.mp3
  String get chuanBi => 'assets/sounds/chuan_bi.mp3';

  /// File path: assets/sounds/hai.mp3
  String get hai => 'assets/sounds/hai.mp3';

  /// File path: assets/sounds/mot.mp3
  String get mot => 'assets/sounds/mot.mp3';

  /// File path: assets/sounds/muoi.mp3
  String get muoi => 'assets/sounds/muoi.mp3';

  /// File path: assets/sounds/nam.mp3
  String get nam => 'assets/sounds/nam.mp3';

  /// File path: assets/sounds/sau.mp3
  String get sau => 'assets/sounds/sau.mp3';

  /// File path: assets/sounds/tam.mp3
  String get tam => 'assets/sounds/tam.mp3';

  /// List of all assets
  List<String> get values => [
    ba,
    bay,
    bon,
    camera,
    chin,
    chuanBi,
    hai,
    mot,
    muoi,
    nam,
    sau,
    tam,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsSoundsGen sounds = $AssetsSoundsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
