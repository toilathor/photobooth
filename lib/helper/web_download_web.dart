import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:th_photobooth/core/js/video_exporter_js.dart' as js_bridge;
import 'package:web/web.dart' as web;

Future<String> saveFilesToDeviceWeb(Map<String, Uint8List> files) async {
  try {
    final jsFiles = JSObject();
    for (final entry in files.entries) {
      final bytes = entry.value;
      final isPng = entry.key.endsWith('.png');
      final blob = web.Blob(
        [bytes.toJS].toJS,
        web.BlobPropertyBag(type: isPng ? 'image/png' : 'video/mp4'),
      );
      jsFiles.setProperty(entry.key.toJS, blob);
    }

    final JSPromise promise = js_bridge.saveFilesToDevice(jsFiles);
    final JSAny? result = await promise.toDart;
    if (result == null) return 'failed';
    return (result as JSString).toDart;
  } catch (e) {
    return 'failed';
  }
}
