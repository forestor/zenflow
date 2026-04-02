import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'timer_screen.dart';
import 'breathing_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    TimerScreen(showCloseButton: false),
    BreathingScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
              label: '홈',
            ),
            NavigationDestination(
              icon: Icon(Icons.spa_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.spa_rounded, color: AppTheme.primary),
              label: '명상',
            ),
            NavigationDestination(
              icon: Icon(Icons.air_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.air_rounded, color: AppTheme.primary),
              label: '호흡',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: AppTheme.textSecondary),
              selectedIcon:
                  Icon(Icons.bar_chart_rounded, color: AppTheme.primary),
              label: '통계',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Tab ──
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _totalMinutes = 0;
  int _streak = 0;
  int _todayMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final total = await StorageService.getTotalMinutes();
    final streak = await StorageService.getStreak();
    final todayRecords = await StorageService.getRecentRecords(1);
    final today = DateTime.now();
    final todayMin = todayRecords
        .where((r) =>
            r.date.year == today.year &&
            r.date.month == today.month &&
            r.date.day == today.day)
        .fold<int>(0, (sum, r) => sum + r.durationMinutes);
    if (mounted) {
      setState(() {
        _totalMinutes = total;
        _streak = streak;
        _todayMinutes = todayMin;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '고요한 밤이에요 🌙';
    if (hour < 12) return '좋은 아침이에요 ☀️';
    if (hour < 18) return '평온한 오후에요 🍃';
    return '편안한 저녁이에요 🌅';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 추가 제약
              children: [
                const SizedBox(height: 16),
                // ── Header ──
                Text('ZenFlow',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 36,
                          foreground: Paint()
                            ..shader = AppTheme.accentGradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 40),
                            ),
                        )),
                const SizedBox(height: 4),
                Text(_getGreeting(),
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 32),
                // ── Today's Summary ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('오늘의 명상',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_todayMinutes',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(' 분',
                                style: TextStyle(
                                    fontSize: 18, color: AppTheme.textSecondary)),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department_rounded,
                                    color: AppTheme.warning, size: 16),
                                const SizedBox(width: 4),
                                Text('$_streak일 연속',
                                    style: const TextStyle(
                                        color: AppTheme.warning,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // ── Quick Actions ──
                Text('시작하기',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _QuickActionCard(
                  icon: Icons.timer_outlined,
                  title: '명상 타이머',
                  subtitle: '고요한 시간을 가져보세요',
                  gradient: AppTheme.accentGradient,
                  onTap: () {
                    final homeState =
                        context.findAncestorStateOfType<_HomeScreenState>();
                    homeState?.setState(() => homeState._currentIndex = 1);
                  },
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  icon: Icons.air_rounded,
                  title: '호흡 가이드',
                  subtitle: '4-7-8 호흡법으로 마음을 가라앉히세요',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF00E5FF)],
                  ),
                  onTap: () {
                    final homeState =
                        context.findAncestorStateOfType<_HomeScreenState>();
                    homeState?.setState(() => homeState._currentIndex = 2);
                  },
                ),
                const SizedBox(height: 48),
                // ── Motivational Quote ──
                Center(
                  child: Text(
                    '"호흡에 집중하면, 지금 이 순간으로 돌아올 수 있습니다."',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withAlpha(150),
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(10)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
