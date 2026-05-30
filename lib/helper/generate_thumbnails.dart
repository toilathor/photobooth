// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print('Starting thumbnail generation...');
  final collectedDir = Directory('assets/frames/collected');
  final thumbnailsDir = Directory('assets/frames/thumbnails');

  if (!thumbnailsDir.existsSync()) {
    thumbnailsDir.createSync(recursive: true);
  }

  // 1. Process main frame1.png
  final frame1File = File('assets/frames/frame1.png');
  if (frame1File.existsSync()) {
    final destFile = File('${thumbnailsDir.path}/frame1.png');
    if (!destFile.existsSync()) {
      print('Processing frame1.png...');
      _generateThumbnail(frame1File, destFile);
    } else {
      print('frame1.png thumbnail already exists, skipping.');
    }
  }

  // 2. Process collected frames
  if (collectedDir.existsSync()) {
    final files = collectedDir.listSync().whereType<File>().toList();
    int count = 0;
    for (final file in files) {
      final filename = file.uri.pathSegments.last;
      if (!filename.toLowerCase().endsWith('.png')) continue;

      final destFile = File('${thumbnailsDir.path}/$filename');
      if (!destFile.existsSync()) {
        print('Processing $filename (${count + 1}/${files.length})...');
        try {
          _generateThumbnail(file, destFile);
          count++;
        } catch (e) {
          print('Error processing $filename: $e');
        }
      }
    }
    print('Generated $count new thumbnails.');
  }

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
