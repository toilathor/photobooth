// ignore_for_file: avoid_print, avoid_dynamic_calls, prefer_single_quotes

import 'dart:io';

import 'package:image/image.dart' as img;

// Usage: dart run lib/helper/FILE.dart [personal|commercial] (default: commercial)
void main(List<String> args) async {
  final flavor = args.isNotEmpty ? args.first : 'commercial';
  final root = 'assets/frames/$flavor';
  print('Starting thumbnail generation...');
  final collectedDir = Directory('$root/collected');
  final customStandardDir = Directory('$root/custom/standard');
  final customGroupDir = Directory('$root/custom/group');
  final thumbnailsDir = Directory('$root/thumbnails');

  if (!thumbnailsDir.existsSync()) {
    thumbnailsDir.createSync(recursive: true);
  }

  // Helper function to process a list of files in a directory
  void processDirectory(Directory dir, String label) {
    if (!dir.existsSync()) {
      print('$label directory does not exist, skipping.');
      return;
    }
    final files = dir.listSync(recursive: true).whereType<File>().toList();
    int count = 0;
    for (final file in files) {
      // Keep the sub-folder (e.g. category) so thumbnails mirror the source.
      final filename = file.path.substring(dir.path.length + 1);
      if (!filename.toLowerCase().endsWith('.png')) continue;

      final destFile = File('${thumbnailsDir.path}/$filename');
      if (!destFile.existsSync()) {
        destFile.parent.createSync(recursive: true);
        print(
          'Processing $filename in $label (${count + 1}/${files.length})...',
        );
        try {
          _generateThumbnail(file, destFile);
          count++;
        } catch (e) {
          print('Error processing $filename in $label: $e');
        }
      }
    }
    if (count > 0) {
      print('Generated $count new thumbnails for $label.');
    } else {
      print('No new thumbnails generated for $label.');
    }
  }

  // 2. Process collected frames
  processDirectory(collectedDir, 'collected');

  // 3. Process custom standard frames
  processDirectory(customStandardDir, 'custom/standard');

  // 4. Process custom group frames
  processDirectory(customGroupDir, 'custom/group');

  print('Thumbnail generation completed.');
}

void _generateThumbnail(File src, File dest) {
  final bytes = src.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Failed to decode: ${src.path}');
    return;
  }

  // Resize keeping aspect ratio, width = 200px
  final resized = img.copyResize(image, width: 200);

  // Encode to png
  final pngBytes = img.encodePng(resized);
  dest.writeAsBytesSync(pngBytes);
}
