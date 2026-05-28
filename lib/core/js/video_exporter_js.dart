import 'dart:js_interop';

@JS()
external JSPromise exportRecapVideo(
  JSString videoUrl,
  JSString frameUrl,
  JSString layoutDataJson, [
  JSString? preferredMimeType,
  JSBoolean? isMirrored,
]);

@JS()
external JSPromise flipVideo(
  JSString videoUrl,
  JSBoolean isMirrored, [
  JSString? preferredMimeType,
]);

@JS()
external JSPromise saveFilesToDevice(JSObject filesMap);
