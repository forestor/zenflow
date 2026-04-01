import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SoundSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const SoundSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> sounds = [
    {'id': 'silence', 'icon': Icons.volume_off_rounded, 'label': '고요함'},
    {'id': 'rain', 'icon': Icons.water_drop_rounded, 'label': '빗소리'},
    {'id': 'wave', 'icon': Icons.waves_rounded, 'label': '파도'},
    {'id': 'bowl', 'icon': Icons.notifications_active_rounded, 'label': '싱잉볼'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: sounds.map((sound) {
        final isSelected = selected == sound['id'];
        return GestureDetector(
          onTap: () => onChanged(sound['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? AppTheme.primary.withAlpha(40)
                  : Colors.white.withAlpha(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : Colors.white.withAlpha(20),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sound['icon'] as IconData,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  sound['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? AppTheme.primaryLight
                        : AppTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
