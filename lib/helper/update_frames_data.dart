// ignore_for_file: avoid_print, avoid_dynamic_calls, prefer_single_quotes

import 'dart:convert';
import 'dart:io';

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

  // Ensure "Frame Custom" category exists
  const customCategoryId = '99';
  bool hasCustomCategory = categories.any(
    (cat) => cat['id'].toString() == customCategoryId,
  );
  if (!hasCustomCategory) {
    print('Adding category "Frame Custom" (ID $customCategoryId)...');
    categories.add({
      "id": 99,
      "name": "Frame Custom",
      "created_at": DateTime.now().toIso8601String(),
      "updated_at": DateTime.now().toIso8601String(),
    });
  }

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

  // Scan custom frame folders: <folder under the flavor root>, data.json "frame" value
  // and "layout_type" value.
  const customLayouts = [
    ('standard', 'square', 'standard'),
    ('group', 'group', 'group'),
  ];

  for (final (folder, frameType, layoutType) in customLayouts) {
    final dir = Directory('$root/$folder');
    if (!dir.existsSync()) continue;

    final files = dir.listSync().whereType<File>().toList();
    for (final file in files) {
      final filename = file.uri.pathSegments.last;
      if (!filename.toLowerCase().endsWith('.png')) continue;

      // Check if already in data.json
      final exists = images.any((img) => img['filename'] == filename);
      if (exists) continue;

      currentMaxId++;
      print('Adding custom $folder frame: $filename with ID $currentMaxId');
      images.add({
        "id": currentMaxId,
        "filename": filename,
        "name": filename.replaceAll('.png', ''),
        "frame": frameType,
        "layout_type": layoutType,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
        "category_id": customCategoryId,
        "visible_locales": ["vn"],
        "category": {
          "id": 99,
          "name": "Frame Custom",
          "created_at": DateTime.now().toIso8601String(),
          "updated_at": DateTime.now().toIso8601String(),
        },
      });
    }
  }

  // Save back to data.json with nice indentation
  final encoder = JsonEncoder.withIndent('    ');
  final prettyJson = encoder.convert({
    "categories": categories,
    "images": images,
  });
  await dataFile.writeAsString(prettyJson);
  print('$root/data.json successfully updated.');

  await _syncPubspecAssets();
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
    if (path.contains('/thumbnails/')) continue;
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
