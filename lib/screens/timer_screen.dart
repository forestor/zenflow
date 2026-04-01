import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/meditation_record.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../widgets/sound_selector.dart';

class TimerScreen extends StatefulWidget {
  final bool showCloseButton;
  const TimerScreen({super.key, this.showCloseButton = true});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}


class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  int _selectedMinutes = 10;
  int _remainingSeconds = 600;
  bool _isRunning = false;
  bool _isComplete = false;
  String? _selectedSound = 'silence';
  bool _useNotification = true;
  final AudioService _audioService = AudioService();
  late AnimationController _timerController;
  late AnimationController _pulseController;

  final List<int> _durations = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(minutes: _selectedMinutes),
    )..addListener(_onTimerTick);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _onTimerTick() {
    final elapsed = _timerController.value * _selectedMinutes * 60;
    final remaining = (_selectedMinutes * 60 - elapsed).round();
    if (mounted) {
      setState(() {
        _remainingSeconds = remaining.clamp(0, _selectedMinutes * 60);
      });
    }
    if (_timerController.isCompleted) {
      _onComplete();
    }
  }

  void _onComplete() async {
    if (_useNotification) {
      await _audioService.stopAndPlayEndSignal();
    } else {
      await _audioService.stopAll();
    }
    setState(() {
      _isRunning = false;
      _isComplete = true;
    });
    await StorageService.saveRecord(MeditationRecord(
      date: DateTime.now(),
      durationMinutes: _selectedMinutes,
      type: 'timer',
    ));
  }

  void _startTimer() async {
    setState(() {
      _isRunning = true;
      _isComplete = false;
    });
    _timerController.duration = Duration(minutes: _selectedMinutes);
    _timerController.forward(from: _timerController.value);

    // Start combined sequence: Signal (if used) -> Ambient (if selected)
    if (_useNotification && _timerController.value == 0) {
      await _audioService.startMeditation(_selectedSound ?? 'silence');
    } else if (_selectedSound != null && _selectedSound != 'silence') {
      await _audioService.playAmbient(_selectedSound!);
    }
  }

  void _pauseTimer() {
    _timerController.stop();
    _audioService.stopAll();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timerController.reset();
    _audioService.stopAll();
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _selectDuration(int minutes) {
    if (_isRunning) return;
    _timerController.reset();
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _isComplete = false;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioService.stopAll();
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = MediaQuery.of(context).size.height;
                    // Responsive size for the circle: min 180, max 260
                    final circleSize = (screenHeight * 0.35).clamp(180.0, 260.0);

                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              const SizedBox(height: 48),
                              Text('명상 타이머',
                                  style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 8),
                              Text('마음을 고요하게 가라앉히세요',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const Spacer(flex: 1),
                              // ── Timer Circle with Responsive Size ──
                              _buildTimerCircle(circleSize),
                              const Spacer(flex: 1),
                              // ── Duration Chips ──
                              if (!_isRunning) _buildDurationChips(),
                              if (!_isRunning) const SizedBox(height: 16),
                              // ── Sound Selector ──
                              if (!_isRunning)
                                SoundSelector(
                                  selected: _selectedSound,
                                  onChanged: (v) => setState(() => _selectedSound = v),
                                ),
                              const SizedBox(height: 16),
                              // ── Notification Option ──
                              if (!_isRunning) _buildNotificationToggle(),
                              const SizedBox(height: 16),
                              // ── Controls ──
                              _buildControls(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // ── Close Button (Placed LAST to be on top) ──
              if (widget.showCloseButton)
                Positioned(
                  top: 0,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      _audioService.stopAll();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 28,
                    color: Colors.white70,
                    tooltip: '홈으로 돌아가기',
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return InkWell(
      onTap: () => setState(() => _useNotification = !_useNotification),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _useNotification
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              size: 20,
              color: _useNotification ? AppTheme.primaryLight : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              '시작/종료 알림',
              style: TextStyle(
                fontSize: 13,
                color: _useNotification ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _useNotification,
              onChanged: (v) => setState(() => _useNotification = v),
              activeColor: AppTheme.primaryLight,
              activeTrackColor: AppTheme.primary.withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_timerController, _pulseController]),
        builder: (context, child) {
          return CustomPaint(
            painter: _TimerPainter(
              progress: _timerController.value,
              pulseValue: _pulseController.value,
              isRunning: _isRunning,
              isComplete: _isComplete,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isComplete)
                    const Icon(Icons.check_circle_outline,
                        color: AppTheme.success, size: 48)
                  else
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _isComplete
                        ? '수고하셨습니다 🙏'
                        : _isRunning
                            ? '명상 중...'
                            : '준비',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          _isComplete ? AppTheme.success : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _durations.map((m) {
        final isSelected = m == _selectedMinutes;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text('$m분'),
            selected: isSelected,
            onSelected: (_) => _selectDuration(m),
            selectedColor: AppTheme.primary,
            backgroundColor: AppTheme.surfaceLight,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControls() {
    if (_isComplete) {
      return ElevatedButton.icon(
        onPressed: _resetTimer,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('다시 시작'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isRunning || _timerController.value > 0)
          IconButton(
            onPressed: _resetTimer,
            icon: const Icon(Icons.stop_rounded),
            iconSize: 32,
            color: AppTheme.textSecondary,
          ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _isRunning ? _pauseTimer : _startTimer,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom Painter for circular timer ──
class _TimerPainter extends CustomPainter {
  final double progress;
  final double pulseValue;
  final bool isRunning;
  final bool isComplete;

  _TimerPainter({
    required this.progress,
    required this.pulseValue,
    required this.isRunning,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: [AppTheme.accent, AppTheme.primary, AppTheme.primaryLight],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }

    // Glow pulse when running
    if (isRunning) {
      final glowPaint = Paint()
        ..color = AppTheme.primary.withAlpha((20 * pulseValue).round())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius - 8 + pulseValue * 4, glowPaint);
    }

    // Complete glow
    if (isComplete) {
      final completePaint = Paint()
        ..color = AppTheme.success.withAlpha(30)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius - 8, completePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerPainter old) => true;
}
