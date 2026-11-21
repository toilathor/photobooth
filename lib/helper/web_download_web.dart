import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:th_photobooth/core/js/video_exporter_js.dart' as js_bridge;
import 'package:web/web.dart' as web;

/// Downloads every file of a session as one zip into the browser's download
/// folder, with no prompt.
Future<String> saveFilesToDeviceWeb(
  Map<String, Uint8List> files,
  String zipName,
) async {
  try {
    final archive = Archive();
    for (final entry in files.entries) {
      // Photos and videos are already compressed; deflating ~50MB would only
      // freeze the page.
      archive.addFile(
        ArchiveFile(entry.key, entry.value.length, entry.value)
          ..compression = CompressionType.none,
      );
    }
    final zipBlob = web.Blob(
      [ZipEncoder().encodeBytes(archive).toJS].toJS,
      web.BlobPropertyBag(type: 'application/zip'),
    );

    final jsFiles = JSObject()..setProperty(zipName.toJS, zipBlob);
    final JSAny? result = await js_bridge.saveFilesToDevice(jsFiles).toDart;
    if (result == null) return 'failed';
    return (result as JSString).toDart;
  } catch (e) {
    return 'failed';
  }
}
