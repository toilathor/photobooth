import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/core/configs/asset_config.dart';

class PlatformAudioService {
  final Map<String, AudioPlayer> _players = {};
  bool _isWarmedUp = false;

  AudioPlayer _getPlayer(String fileName) {
    var player = _players[fileName];
    if (player == null) {
      player = AudioPlayer();
      player.setSource(AssetSource(AssetConfig.getSoundPath(fileName)));
      _players[fileName] = player;
    }
    return player;
  }

  void warmup() {
    if (_isWarmedUp) return;
    _isWarmedUp = true;

    final filesToWarmup = [
      AssetConfig.soundCamera,
      AssetConfig.soundPrepare,
      ...AppConfig.numberSounds.values,
    ];

    for (final file in filesToWarmup) {
      try {
        final player = _getPlayer(file);
        player.setVolume(0.0);
        player.play(AssetSource(AssetConfig.getSoundPath(file)));
      } catch (e) {
        debugPrint('AudioService Native Error warming up sound $file: $e');
      }
    }
  }

  Future<void> playSound(String fileName) async {
    try {
      final player = _getPlayer(fileName);
      player.stop();
      player.setVolume(1.0);
      player.seek(Duration.zero);
      player.play(AssetSource(AssetConfig.getSoundPath(fileName)));
    } catch (e) {
      debugPrint('AudioService Native Error playing sound $fileName: $e');
    }
  }

  Future<void> stop() async {
    try {
      for (final player in _players.values) {
        player.stop();
      }
    } catch (e) {
      debugPrint('AudioService Native Error stopping sound: $e');
    }
  }

  Future<void> dispose() async {
    try {
      for (final player in _players.values) {
        player.dispose();
      }
      _players.clear();
    } catch (e) {
      debugPrint('AudioService Native Error disposing player: $e');
    }
  }
}
