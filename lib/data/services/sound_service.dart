import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  // Звуковые эффекты - в реальном проекте добавьте файлы в assets
  static const String _successSound = 'sounds/success.mp3';
  static const String _xpSound = 'sounds/xp.mp3';
  static const String _completeSound = 'sounds/complete.mp3';
  static const String _clickSound = 'sounds/click.mp3';

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('Sound muted: $_isMuted');
  }

  Future<void> playSuccess() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource(_successSound));
    } catch (e) {
      debugPrint('Sound not found (optional): $e');
    }
  }

  Future<void> playXP() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource(_xpSound));
    } catch (e) {
      debugPrint('Sound not found (optional): $e');
    }
  }

  Future<void> playComplete() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource(_completeSound));
    } catch (e) {
      debugPrint('Sound not found (optional): $e');
    }
  }

  Future<void> playClick() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource(_clickSound));
    } catch (e) {
      debugPrint('Sound not found (optional): $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
