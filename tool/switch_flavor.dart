// ignore_for_file: avoid_print, avoid_dynamic_calls, prefer_single_quotes
import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty || (args[0] != 'personal' && args[0] != 'commercial')) {
    print('Usage: dart run tool/switch_flavor.dart [personal|commercial]');
    exit(1);
  }

  final String flavor = args[0];
  print('Switching to flavor: $flavor...');

  final Map<String, dynamic> config = {
    'bundleId': flavor == 'personal' ? 'vn.thphotobooth' : 'vn.photobooth',
    'appNameShort': flavor == 'personal' ? 'TH PhotoBooth' : 'PhotoBooth',
    'appNameFull': flavor == 'personal' ? 'TH PhotoBooth - Lưu giữ mọi khoảnh khắc' : 'PhotoBooth - Lưu giữ mọi khoảnh khắc',
    'headerTitleVi': flavor == 'personal' ? 'Thuý Hền ❤️ Quang Tọ' : 'PhotoBooth',
    'headerTitleEn': flavor == 'personal' ? 'Thuy Hen ❤️ Quang To' : 'PhotoBooth',
    'theme': flavor == 'personal' ? 'ThemeConfig.weddingTheme' : 'ThemeConfig.lightTheme',
    'activeStorage': flavor == 'personal' ? 'StorageType.googleDrive' : 'StorageType.none',
    'binaryName': flavor == 'personal' ? 'th_photobooth' : 'photobooth',
  };

  // Helper to replace content in file
  void replaceInFile(String path, Pattern from, String to) {
    final file = File(path);
    if (!file.existsSync()) {
      print('Warning: File not found: $path');
      return;
    }
    String content = file.readAsStringSync();
    if (content.contains(from)) {
      content = content.replaceAll(from, to);
      file.writeAsStringSync(content);
      print('Updated: $path');
    }
  }

  // 1. AppConfig
  replaceInFile(
    'lib/core/configs/app_config.dart',
    RegExp(r"static const String appName = '.*?';"),
    "static const String appName = '${config['appNameShort']}';",
  );
  replaceInFile(
    'lib/core/configs/app_config.dart',
    RegExp(r"static ThemeData get theme => ThemeConfig\..*?;"),
    "static ThemeData get theme => ${config['theme']};",
  );

  // 2. StorageConfig
  replaceInFile(
    'lib/core/configs/storage_config.dart',
    RegExp(r"static const StorageType activeStorage = StorageType\..*?;"),
    "static const StorageType activeStorage = ${config['activeStorage']};",
  );

  // 3. Translations (JSON Decode/Encode to be safe)
  final viFile = File('lib/i18n/vi.i18n.json');
  if (viFile.existsSync()) {
    final Map<String, dynamic> viJson = jsonDecode(viFile.readAsStringSync()) as Map<String, dynamic>;
    if (viJson['header'] != null) {
      viJson['header']['title'] = config['headerTitleVi'];
      viFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(viJson));
      print('Updated: lib/i18n/vi.i18n.json');
    }
  }

  final enFile = File('lib/i18n/en.i18n.json');
  if (enFile.existsSync()) {
    final Map<String, dynamic> enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
    if (enJson['header'] != null) {
      enJson['header']['title'] = config['headerTitleEn'];
      enFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(enJson));
      print('Updated: lib/i18n/en.i18n.json');
    }
  }

  // Run slang to update strings
  print('Regenerating translations via slang...');
  final slangRes = Process.runSync('dart', ['run', 'slang']);
  print(slangRes.stdout);
  if (slangRes.stderr.toString().isNotEmpty) {
    print(slangRes.stderr);
  }

  // 4. Android
  replaceInFile(
    'android/app/build.gradle.kts',
    RegExp(r'applicationId = ".*?"'),
    'applicationId = "${config['bundleId']}"',
  );
  replaceInFile(
    'android/app/src/main/AndroidManifest.xml',
    RegExp(r'android:label=".*?"'),
    'android:label="${config['appNameShort']}"',
  );

  // 5. iOS & macOS project.pbxproj
  replaceInFile(
    'ios/Runner.xcodeproj/project.pbxproj',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = vn\..*?;'),
    'PRODUCT_BUNDLE_IDENTIFIER = ${config['bundleId']};',
  );
  replaceInFile(
    'ios/Runner.xcodeproj/project.pbxproj',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = vn\..*?\.RunnerTests;'),
    'PRODUCT_BUNDLE_IDENTIFIER = ${config['bundleId']}.RunnerTests;',
  );
  replaceInFile(
    'ios/Runner.xcodeproj/project.pbxproj',
    RegExp(r'PRODUCT_NAME = ".*?";'),
    'PRODUCT_NAME = "${config['appNameShort']}";',
  );

  replaceInFile(
    'macos/Runner.xcodeproj/project.pbxproj',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = vn\..*?;'),
    'PRODUCT_BUNDLE_IDENTIFIER = ${config['bundleId']};',
  );
  replaceInFile(
    'macos/Runner.xcodeproj/project.pbxproj',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = vn\..*?\.RunnerTests;'),
    'PRODUCT_BUNDLE_IDENTIFIER = ${config['bundleId']}.RunnerTests;',
  );
  replaceInFile(
    'macos/Runner.xcodeproj/project.pbxproj',
    RegExp(r'PRODUCT_NAME = ".*?";'),
    'PRODUCT_NAME = "${config['appNameShort']}";',
  );

  replaceInFile(
    'macos/Runner/Configs/AppInfo.xcconfig',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = vn\..*'),
    'PRODUCT_BUNDLE_IDENTIFIER = ${config['bundleId']}',
  );
  replaceInFile(
    'macos/Runner/Configs/AppInfo.xcconfig',
    RegExp(r'PRODUCT_NAME = .*'),
    'PRODUCT_NAME = ${config['appNameShort']}',
  );
  replaceInFile(
    'macos/Runner/Configs/AppInfo.xcconfig',
    RegExp(r'PRODUCT_COPYRIGHT = .*'),
    'PRODUCT_COPYRIGHT = Copyright © 2025 ${config['bundleId']}. All rights reserved.',
  );

  // 6. Linux
  replaceInFile(
    'linux/CMakeLists.txt',
    RegExp(r'set\(BINARY_NAME ".*?"\)'),
    'set(BINARY_NAME "${config['appNameShort']}")',
  );
  replaceInFile(
    'linux/CMakeLists.txt',
    RegExp(r'set\(APPLICATION_ID ".*?"\)'),
    'set(APPLICATION_ID "${config['bundleId']}")',
  );
  replaceInFile(
    'linux/runner/my_application.cc',
    RegExp(r'gtk_header_bar_set_title\(header_bar, ".*?"\)'),
    'gtk_header_bar_set_title(header_bar, "${config['appNameFull']}")',
  );
  replaceInFile(
    'linux/runner/my_application.cc',
    RegExp(r'gtk_window_set_title\(window, ".*?"\)'),
    'gtk_window_set_title(window, "${config['appNameFull']}")',
  );

  // 7. Windows
  replaceInFile(
    'windows/CMakeLists.txt',
    RegExp(r'project\(.*? LANGUAGES CXX\)'),
    'project(${config['binaryName']} LANGUAGES CXX)',
  );
  replaceInFile(
    'windows/CMakeLists.txt',
    RegExp(r'set\(BINARY_NAME ".*?"\)'),
    'set(BINARY_NAME "${config['binaryName']}")',
  );

  replaceInFile(
    'windows/runner/Runner.rc',
    RegExp(r'VALUE "CompanyName", ".*?"'),
    'VALUE "CompanyName", "${config['bundleId']}"',
  );
  replaceInFile(
    'windows/runner/Runner.rc',
    RegExp(r'VALUE "FileDescription", ".*?"'),
    'VALUE "FileDescription", "${config['appNameShort']}"',
  );
  replaceInFile(
    'windows/runner/Runner.rc',
    RegExp(r'VALUE "InternalName", ".*?"'),
    'VALUE "InternalName", "${config['bundleId']}"',
  );
  replaceInFile(
    'windows/runner/Runner.rc',
    RegExp(r'VALUE "LegalCopyright", ".*?"'),
    'VALUE "LegalCopyright", "Copyright (C) 2025 ${config['bundleId']}. All rights reserved."',
  );
  replaceInFile(
    'windows/runner/Runner.rc',
    RegExp(r'VALUE "OriginalFilename", ".*?"'),
    'VALUE "OriginalFilename", "${config['binaryName']}.exe"',
  );
  replaceInFile(
    'windows/runner/Runner.rc',
    RegExp(r'VALUE "ProductName", ".*?"'),
    'VALUE "ProductName", "${config['appNameFull']}"',
  );
  
  replaceInFile(
    'windows/runner/main.cpp',
    RegExp(r'window\.Create\(L".*?",'),
    'window.Create(L"${config['appNameShort']}",',
  );

  // 8. Web
  replaceInFile(
    'web/index.html',
    RegExp(r'<meta name="apple-mobile-web-app-title" content=".*?">'),
    '<meta name="apple-mobile-web-app-title" content="${config['appNameShort']}">',
  );
  replaceInFile(
    'web/index.html',
    RegExp(r'<title>.*?</title>'),
    '<title>${config['appNameFull']}</title>',
  );
  
  final manifestFile = File('web/manifest.json');
  if (manifestFile.existsSync()) {
    final Map<String, dynamic> manifest = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    manifest['name'] = config['appNameFull'];
    manifest['short_name'] = config['appNameShort'];
    manifestFile.writeAsStringSync(const JsonEncoder.withIndent('    ').convert(manifest));
    print('Updated: web/manifest.json');
  }

  // 9. Launcher Icons
  final String iconConfigFile = 'flutter_launcher_icons-$flavor.yaml';
  final iconFile = File(iconConfigFile);
  if (iconFile.existsSync()) {
    File('flutter_launcher_icons.yaml').writeAsStringSync(iconFile.readAsStringSync());
    print('Copied $iconConfigFile to flutter_launcher_icons.yaml');
    
    print('Generating launcher icons...');
    final iconGenRes = Process.runSync('flutter', ['pub', 'run', 'flutter_launcher_icons']);
    print(iconGenRes.stdout);
    if (iconGenRes.stderr.toString().isNotEmpty) {
      print(iconGenRes.stderr);
    }
  } else {
    print('Warning: Icon config not found: $iconConfigFile');
  }

  print('Flavor switch completed successfully!');
}
