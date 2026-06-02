import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:web/web.dart' as web;
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/asset_config.dart';

class PlatformAudioService {
  web.AudioContext? _audioContext;
  final Map<String, web.AudioBuffer> _buffers = {};
  bool _isWarmedUp = false;

  void warmup() {
    if (_isWarmedUp) return;
    _isWarmedUp = true;

    try {
      _audioContext = web.AudioContext();
      if (_audioContext!.state == 'suspended') {
        _audioContext!.resume();
      }

      final filesToWarmup = [
        AssetConfig.soundCamera,
        AssetConfig.soundPrepare,
        ...AppConfig.numberSounds.values,
      ];

      for (final file in filesToWarmup) {
        _preloadSound(file);
      }
    } catch (e) {
      debugPrint('AudioService Web Error warming up: $e');
    }
  }

  Future<void> _preloadSound(String fileName) async {
    if (_buffers.containsKey(fileName)) return;
    try {
      final path = 'assets/sounds/$fileName';
      final byteData = await rootBundle.load(path);
      final u8list = byteData.buffer.asUint8List();
      
      final audioContext = _audioContext ??= web.AudioContext();
      if (audioContext.state == 'suspended') {
        await audioContext.resume().toDart;
      }
      
      final jsArrayBuffer = u8list.buffer.toJS;
      final audioBuffer = await audioContext.decodeAudioData(jsArrayBuffer).toDart;
      _buffers[fileName] = audioBuffer;
    } catch (e) {
      debugPrint('AudioService Web Error loading sound $fileName: $e');
    }
  }

  Future<void> playSound(String fileName) async {
    try {
      final audioContext = _audioContext ??= web.AudioContext();
      if (audioContext.state == 'suspended') {
        await audioContext.resume().toDart;
      }

      var buffer = _buffers[fileName];
      if (buffer == null) {
        await _preloadSound(fileName);
        buffer = _buffers[fileName];
      }

      if (buffer != null) {
        final source = audioContext.createBufferSource();
        source.buffer = buffer;
        source.connect(audioContext.destination as web.AudioNode);
        source.start(0);
      }
    } catch (e) {
      debugPrint('AudioService Web Error playing sound $fileName: $e');
    }
  }

  Future<void> stop() async {
    // Web Audio API playing sources are fire-and-forget for short beeps/clips,
    // so no stop action is needed for this use case.
  }

  Future<void> dispose() async {
    try {
      if (_audioContext != null) {
        await _audioContext!.close().toDart;
        _audioContext = null;
      }
      _buffers.clear();
    } catch (e) {
      debugPrint('AudioService Web Error disposing: $e');
    }
  }
}
