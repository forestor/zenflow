import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/meditation_record.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _totalMinutes = 0;
  int _streak = 0;
  int _totalSessions = 0;
  List<MeditationRecord> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final total = await StorageService.getTotalMinutes();
    final streak = await StorageService.getStreak();
    final recent = await StorageService.getRecentRecords(7);
    final all = await StorageService.getRecords();
    if (mounted) {
      setState(() {
        _totalMinutes = total;
        _streak = streak;
        _recentRecords = recent;
        _totalSessions = all.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('명상 통계',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('꾸준히 쌓아가는 마음의 평화',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              // ── Summary Cards ──
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      value: '${_totalMinutes}분',
                      label: '총 명상 시간',
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '$_streak일',
                      label: '연속 스트릭',
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.self_improvement_rounded,
                      value: '$_totalSessions회',
                      label: '총 세션',
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // ── Weekly Bar Chart ──
              _buildWeeklyChart(),
              const SizedBox(height: 32),
              // ── Recent Records ──
              Text('최근 기록',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_recentRecords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.spa_outlined,
                            size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('아직 기록이 없습니다',
                            style: TextStyle(color: AppTheme.textSecondary)),
                        Text('첫 명상을 시작해 보세요!',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                ..._recentRecords.map((r) => _RecordTile(record: r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Aggregate minutes per day for last 7 days
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    final minutesPerDay = days.map((day) {
      return _recentRecords
          .where((r) =>
              r.date.year == day.year &&
              r.date.month == day.month &&
              r.date.day == day.day)
          .fold<int>(0, (sum, r) => sum + r.durationMinutes);
    }).toList();

    final maxMinutes = minutesPerDay.fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이번 주', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final height =
                    minutesPerDay[i] > 0 ? (minutesPerDay[i] / maxMinutes) * 90 : 4.0;
                final weekday = days[i].weekday; // 1=Mon
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (minutesPerDay[i] > 0)
                        Text(
                          '${minutesPerDay[i]}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: minutesPerDay[i] > 0
                              ? AppTheme.accentGradient
                              : null,
                          color: minutesPerDay[i] == 0
                              ? Colors.white.withAlpha(15)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayLabels[(weekday - 1) % 7],
                        style: TextStyle(
                          fontSize: 12,
                          color: days[i].day == now.day
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: days[i].day == now.day
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final MeditationRecord record;

  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isTimer = record.type == 'timer';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isTimer ? AppTheme.primary : AppTheme.accent).withAlpha(30),
            ),
            child: Icon(
              isTimer ? Icons.timer_outlined : Icons.air_rounded,
              color: isTimer ? AppTheme.primary : AppTheme.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTimer ? '명상 타이머' : '호흡 가이드',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${record.date.month}/${record.date.day} ${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${record.durationMinutes}분',
            style: const TextStyle(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
