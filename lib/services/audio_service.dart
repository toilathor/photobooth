import 'package:th_photobooth/services/audio_service_native.dart'
    if (dart.library.js_interop) 'package:th_photobooth/services/audio_service_web.dart';

class AudioService {
  final PlatformAudioService _impl = PlatformAudioService();

  /// Warm up and unlock all AudioPlayer instances on Web/Mobile browsers.
  /// This must be called synchronously inside a user gesture handler (e.g. button click)
  /// to unlock each browser Audio element under the iOS/Safari autoplay policy.
  void warmup() {
    _impl.warmup();
  }

  /// Plays a sound asset matching the given [fileName].
  /// Stops any currently playing audio before beginning playback to minimize latency.
  Future<void> playSound(String fileName) async {
    await _impl.playSound(fileName);
  }

  /// Stops current playback.
  Future<void> stop() async {
    await _impl.stop();
  }

  /// Disposes of all cached [AudioPlayer] instances to prevent memory leaks.
  Future<void> dispose() async {
    await _impl.dispose();
  }
}
