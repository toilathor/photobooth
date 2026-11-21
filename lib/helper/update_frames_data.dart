// ignore_for_file: avoid_print, avoid_dynamic_calls, prefer_single_quotes

import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

// Usage: dart run lib/helper/FILE.dart [personal|commercial] (default: commercial)
void main(List<String> args) async {
  final flavor = args.isNotEmpty ? args.first : 'commercial';
  final root = 'assets/frames/$flavor';
  print('Starting frames data update...');

  final dataFile = File('$root/data.json');
  if (!dataFile.existsSync()) {
    print('Error: $root/data.json does not exist.');
    return;
  }

  final jsonString = await dataFile.readAsString();
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final categories = data['categories'] as List<dynamic>? ?? [];
  final images = data['images'] as List<dynamic>? ?? [];

  // Helper to find max ID in images list
  int getMaxId() {
    int maxId = 0;
    for (var img in images) {
      final id = img['id'];
      if (id is int && id > maxId) {
        maxId = id;
      }
    }
    return maxId;
  }

  int currentMaxId = getMaxId();

  // Scan the frame folders of the flavor: <folder under the flavor root>,
  // data.json "frame" value and "layout_type" value. "filename" is relative to
  // the flavor root (e.g. standard/standard_1.png). New frames have no
  // category; set "category_id" and "category" in data.json to group them.
  const layouts = [
    ('standard', 'square', 'standard'),
    ('group', 'group', 'group'),
  ];

  for (final (folder, frameType, layoutType) in layouts) {
    final dir = Directory('$root/$folder');
    if (!dir.existsSync()) continue;

    final files = dir.listSync().whereType<File>().toList();
    for (final file in files) {
      final name = file.uri.pathSegments.last;
      if (!name.toLowerCase().endsWith('.png')) continue;

      final filename = '$folder/$name';
      final exists = images.any((img) => img['filename'] == filename);
      if (exists) continue;

      currentMaxId++;
      print('Adding $layoutType frame: $filename with ID $currentMaxId');
      images.add({
        "id": currentMaxId,
        "filename": filename,
        "name": name.replaceAll('.png', ''),
        "frame": frameType,
        "layout_type": layoutType,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
        "category_id": '',
        "visible_locales": ["vn"],
      });
    }
  }

  // Save back to data.json with nice indentation
  final encoder = JsonEncoder.withIndent('    ');
  final prettyJson = encoder.convert({
    "categories": categories,
    "images": images,
  });
  await dataFile.writeAsString('$prettyJson\n');
  print('$root/data.json successfully updated.');

  _syncThumbnails(root, images);
  await _syncPubspecAssets();
}

/// The frame picker shows small tiles: decoding every full frame (~1.5MB,
/// 880×2650) for them is slow, so each frame gets a 200px-wide copy at
/// `thumbnails/<filename>`, redone when the frame file is newer.
void _syncThumbnails(String root, List<dynamic> images) {
  var count = 0;
  for (final image in images) {
    final filename = image['filename'] as String;
    final source = File('$root/$filename');
    final thumbnail = File('$root/thumbnails/$filename');
    if (!source.existsSync()) continue;
    if (thumbnail.existsSync() &&
        !source.lastModifiedSync().isAfter(thumbnail.lastModifiedSync())) {
      continue;
    }
    final decoded = img.decodeImage(source.readAsBytesSync());
    if (decoded == null) {
      print('Failed to decode $filename, no thumbnail.');
      continue;
    }
    thumbnail.parent.createSync(recursive: true);
    thumbnail.writeAsBytesSync(
      img.encodePng(img.copyResize(decoded, width: 200)),
    );
    count++;
  }
  print('Thumbnails: $count generated or refreshed.');
}

/// Flutter does not bundle assets recursively, so every frame folder of every
/// flavor must be listed in pubspec.yaml. Regenerates the block between the
/// `# frames:begin` and `# frames:end` markers.
Future<void> _syncPubspecAssets() async {
  final framesDir = Directory('assets/frames');
  final dirs = <String>[];
  for (final entity in framesDir.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (!path.endsWith('.png') && !path.endsWith('.json')) continue;
    final dir = '${entity.parent.path}/';
    if (!dirs.contains(dir)) dirs.add(dir);
  }
  dirs.sort();

  final pubspec = File('pubspec.yaml');
  final content = await pubspec.readAsString();
  final pattern = RegExp(r'( *# frames:begin[^\n]*\n)[\s\S]*?( *# frames:end)');
  final match = pattern.firstMatch(content);
  if (match == null) {
    print('Warning: frames markers not found in pubspec.yaml, skipped.');
    return;
  }
  final block = dirs.map((d) => '    - $d\n').join();
  await pubspec.writeAsString(
    content.replaceFirst(pattern, '${match.group(1)}$block${match.group(2)}'),
  );
  print('pubspec.yaml frame assets synced (${dirs.length} folders).');
}
