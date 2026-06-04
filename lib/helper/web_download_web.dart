import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:th_photobooth/core/js/video_exporter_js.dart' as js_bridge;
import 'package:web/web.dart' as web;

Future<String> saveFilesToDeviceWeb(Map<String, Uint8List> files) async {
  try {
    final jsFiles = JSObject();

    // Check if window.showDirectoryPicker is supported
    final hasDirectoryPicker = web.window
        .hasProperty('showDirectoryPicker'.toJS)
        .toDart;

    if (hasDirectoryPicker) {
      // If supported (typically Desktop Chrome/Edge), save files individually in the selected directory
      for (final entry in files.entries) {
        final bytes = entry.value;
        final String mimeType;
        if (entry.key.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (entry.key.endsWith('.jpg') || entry.key.endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        } else {
          mimeType = 'video/mp4';
        }
        final blob = web.Blob(
          [bytes.toJS].toJS,
          web.BlobPropertyBag(type: mimeType),
        );
        jsFiles.setProperty(entry.key.toJS, blob);
      }
    } else {
      // If not supported (Mobile browsers, Firefox, Safari), package all files into a single ZIP archive
      final archive = Archive();
      for (final entry in files.entries) {
        final bytes = entry.value;
        final archiveFile = ArchiveFile(entry.key, bytes.length, bytes);
        archive.addFile(archiveFile);
      }

      final zipData = ZipEncoder().encode(archive);

      final zipUint8List = Uint8List.fromList(zipData);
      final zipBlob = web.Blob(
        [zipUint8List.toJS].toJS,
        web.BlobPropertyBag(type: 'application/zip'),
      );

      jsFiles.setProperty('photobooth_recap.zip'.toJS, zipBlob);
    }

    final JSPromise promise = js_bridge.saveFilesToDevice(jsFiles);
    final JSAny? result = await promise.toDart;
    if (result == null) return 'failed';
    return (result as JSString).toDart;
  } catch (e) {
    return 'failed';
  }
}
