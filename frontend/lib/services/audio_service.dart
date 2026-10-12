import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> playAsset(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() => _player.resume();

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}
