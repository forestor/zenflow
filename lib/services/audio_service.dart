import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  
  AudioService._() {
    // ── Listen for signal completion to start ambient sound ──
    _player.onPlayerComplete.listen((_) {
      if (_isWaitingForAmbient && _pendingAmbientId != null) {
        _isWaitingForAmbient = false;
        final nextId = _pendingAmbientId;
        _pendingAmbientId = null; // Clear pending id before starting
        playAmbient(nextId!);
      }
    });
  }

  // Use a SINGLE player for maximum stability on web
  final AudioPlayer _player = AudioPlayer();

  String? _currentSound;
  bool _isPlaying = false;
  
  // To handle the sequence: Signal -> Ambient
  bool _isWaitingForAmbient = false;
  String? _pendingAmbientId;

  // Actual filenames found in assets/sounds/
  static const String bowlSignalPath = 'sounds/singing_bowl_1.mp3';

  static const Map<String, String> ambientPaths = {
    'rain': 'sounds/rain_loop.mp3',
    'wave': 'sounds/ocean-wave.mp3',
    'bowl': 'sounds/singing_bowl_2.mp3',
  };

  String? get currentSound => _currentSound;
  bool get isPlaying => _isPlaying;

  // 🔔 1. Play Start Signal (Bowl) then chain to Ambient
  Future<void> startMeditation(String ambientId) async {
    // 🔥 Reset states BEFORE starting a new session
    _isWaitingForAmbient = (ambientId != 'silence');
    _pendingAmbientId = (ambientId == 'silence') ? null : ambientId;

    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release); // One shot for signal
      await _player.setVolume(0.8);
      
      // Ensure audio context is ready (required for some browsers after stop)
      await _player.play(AssetSource(bowlSignalPath));
      _currentSound = 'signal';
      _isPlaying = true;
    } catch (e) {
      print('Start Meditation Error: $e');
      // If signal fails, jump to ambient immediately
      if (_pendingAmbientId != null) {
        _isWaitingForAmbient = false;
        playAmbient(_pendingAmbientId!);
      }
    }
  }

  // 🌧️ 2. Play Ambient Loop
  Future<void> playAmbient(String soundId) async {
    final path = ambientPaths[soundId];
    if (path == null) return;

    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.5);
      await _player.play(AssetSource(path));
      _currentSound = soundId;
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }

  // 🔔 3. Play End Signal (Bowl)
  Future<void> stopAndPlayEndSignal() async {
    _isWaitingForAmbient = false;
    _pendingAmbientId = null;
    
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.setVolume(0.8);
      // 안드로이드/모바일 브라우저에서 stop() 후 바로 play() 호출 시 설류가 발생할 수 있어
      // 영상체 예를 주어 플레이어가 준비될 시간을 확보합니다
      await Future.delayed(const Duration(milliseconds: 100));
      await _player.play(AssetSource(bowlSignalPath));
      _currentSound = 'end_signal';
    } catch (e) {
      print('End Signal Error: $e');
    }
    _isPlaying = false;
  }


  // 🔥 COMPLETELY stop and reset EVERYTHING
  Future<void> stopAll() async {
    _isWaitingForAmbient = false;
    _pendingAmbientId = null;
    try {
      await _player.stop();
      // release()는 안드로이드에서 플레이어 재사용을 방해해 제거합니다
    } catch (_) {}
    _isPlaying = false;
    _currentSound = null;
  }


  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  void dispose() {
    stopAll(); // Ensure clean exit
    _player.dispose();
  }
}
