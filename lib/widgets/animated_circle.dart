import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedCircle extends StatelessWidget {
  final double size;
  final String label;
  final Color? color;

  const AnimatedCircle({
    super.key,
    required this.size,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            (color ?? AppTheme.primary).withAlpha(180),
            (color ?? AppTheme.primary).withAlpha(60),
            (color ?? AppTheme.primary).withAlpha(10),
          ],
          stops: const [0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.primary).withAlpha(80),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(
            fontSize: size * 0.1,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 2,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
