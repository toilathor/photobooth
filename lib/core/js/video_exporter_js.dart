import 'dart:js_interop';

@JS()
external JSPromise exportRecapVideo(
  JSString videoUrl,
  JSString frameUrl,
  JSString layoutDataJson,
);
