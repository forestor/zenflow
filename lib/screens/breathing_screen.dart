import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/meditation_record.dart';
import '../services/storage_service.dart';
import '../widgets/animated_circle.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  // 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s = 19s total
  static const int _inhale = 4;
  static const int _hold = 7;
  static const int _exhale = 8;
  static const int _totalCycle = _inhale + _hold + _exhale;

  late AnimationController _controller;
  bool _isRunning = false;
  int _cycleCount = 0;
  int _totalCycles = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalCycle),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && _isRunning) {
          setState(() => _cycleCount++);
          _controller.forward(from: 0);
        }
      });
  }

  String get _currentPhase {
    if (!_isRunning) return '시작하려면\n탭하세요';
    final seconds = _controller.value * _totalCycle;
    if (seconds < _inhale) return '들이쉬세요';
    if (seconds < _inhale + _hold) return '참으세요';
    return '내쉬세요';
  }

  Color get _currentColor {
    if (!_isRunning) return AppTheme.primary;
    final seconds = _controller.value * _totalCycle;
    if (seconds < _inhale) return const Color(0xFF448AFF); // blue
    if (seconds < _inhale + _hold) return const Color(0xFF7C4DFF); // purple
    return const Color(0xFF00E5FF); // cyan
  }

  double get _circleSize {
    if (!_isRunning) return 160;
    final seconds = _controller.value * _totalCycle;
    if (seconds < _inhale) {
      // Expand during inhale
      final t = seconds / _inhale;
      return 160 + 100 * t;
    } else if (seconds < _inhale + _hold) {
      // Hold at max
      return 260;
    } else {
      // Shrink during exhale
      final t = (seconds - _inhale - _hold) / _exhale;
      return 260 - 100 * t;
    }
  }

  String get _phaseTimer {
    if (!_isRunning) return '';
    final seconds = _controller.value * _totalCycle;
    if (seconds < _inhale) {
      return '${(_inhale - seconds).ceil()}';
    } else if (seconds < _inhale + _hold) {
      return '${(_inhale + _hold - seconds).ceil()}';
    } else {
      return '${(_totalCycle - seconds).ceil()}';
    }
  }

  void _toggle() {
    if (_isRunning) {
      _stop();
    } else {
      _start();
    }
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _cycleCount = 0;
      _startTime = DateTime.now();
    });
    _controller.forward(from: 0);
  }

  void _stop() async {
    _controller.stop();
    _controller.reset();
    _totalCycles = _cycleCount;
    final elapsed = _startTime != null
        ? DateTime.now().difference(_startTime!).inMinutes
        : 0;
    setState(() {
      _isRunning = false;
      _cycleCount = 0;
    });

    if (elapsed > 0 || _totalCycles > 0) {
      await StorageService.saveRecord(MeditationRecord(
        date: DateTime.now(),
        durationMinutes: elapsed > 0 ? elapsed : 1,
        type: 'breathing',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_totalCycles 사이클 완료! 기록이 저장되었습니다 🙏'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('호흡 가이드', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('4-7-8 호흡법', style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(flex: 2),
            // ── Breathing Circle ──
            GestureDetector(
              onTap: _toggle,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedCircle(
                        size: _circleSize,
                        label: _currentPhase,
                        color: _currentColor,
                      ),
                      const SizedBox(height: 24),
                      if (_isRunning)
                        Text(
                          _phaseTimer,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w200,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const Spacer(flex: 1),
            // ── Cycle Counter ──
            if (_isRunning)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '사이클: $_cycleCount',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // ── Guide Text ──
            _buildGuideInfo(),
            const SizedBox(height: 32),
            // ── Stop Button ──
            if (_isRunning)
              TextButton.icon(
                onPressed: _stop,
                icon: const Icon(Icons.stop_rounded, color: AppTheme.warning),
                label: const Text('종료',
                    style: TextStyle(color: AppTheme.warning, fontSize: 16)),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideInfo() {
    if (_isRunning) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(10)),
        ),
        child: Column(
          children: [
            _guideRow('💨', '들이쉬기', '$_inhale초'),
            const SizedBox(height: 8),
            _guideRow('⏸️', '참기', '$_hold초'),
            const SizedBox(height: 8),
            _guideRow('🌬️', '내쉬기', '$_exhale초'),
          ],
        ),
      ),
    );
  }

  Widget _guideRow(String emoji, String label, String time) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
        ),
        Text(time,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
      ],
    );
  }
}
