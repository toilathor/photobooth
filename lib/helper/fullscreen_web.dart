import 'dart:js_interop';
import 'package:web/web.dart' as web;

void enterFullscreenWeb() {
  web.document.documentElement?.requestFullscreen();
}

bool isFullscreenWeb() {
  return web.document.fullscreenElement != null;
}

void onFullscreenChangeWeb(void Function(bool) callback) {
  web.document.addEventListener(
    'fullscreenchange',
    (web.Event _) {
      callback(isFullscreenWeb());
    }.toJS,
  );
}
