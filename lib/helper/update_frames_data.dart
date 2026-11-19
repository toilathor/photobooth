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

  // Scan $root/custom/standard
  final standardDir = Directory('$root/custom/standard');
  if (standardDir.existsSync()) {
    final files = standardDir.listSync().whereType<File>().toList();
    for (final file in files) {
      final filename = file.uri.pathSegments.last;
      if (!filename.toLowerCase().endsWith('.png')) continue;

      // Check if already in data.json
      final exists = images.any((img) => img['filename'] == filename);
      if (!exists) {
        currentMaxId++;
        print('Adding custom standard frame: $filename with ID $currentMaxId');
        images.add({
          "id": currentMaxId,
          "filename": filename,
          "name": filename.replaceAll('.png', ''),
          "frame": "square",
          "layout_type": "standard",
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
  }

  // Scan $root/custom/group
  final groupDir = Directory('$root/custom/group');
  if (groupDir.existsSync()) {
    final files = groupDir.listSync().whereType<File>().toList();
    for (final file in files) {
      final filename = file.uri.pathSegments.last;
      if (!filename.toLowerCase().endsWith('.png')) continue;

      // Check if already in data.json
      final exists = images.any((img) => img['filename'] == filename);
      if (!exists) {
        currentMaxId++;
        print('Adding custom group frame: $filename with ID $currentMaxId');
        images.add({
          "id": currentMaxId,
          "filename": filename,
          "name": filename.replaceAll('.png', ''),
          "frame": "group",
          "layout_type": "group",
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
  }

  // Save back to data.json with nice indentation
  final encoder = JsonEncoder.withIndent('    ');
  final prettyJson = encoder.convert({
    "categories": categories,
    "images": images,
  });
  await dataFile.writeAsString(prettyJson);
  print('$root/data.json successfully updated.');
}
