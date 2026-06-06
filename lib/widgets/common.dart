import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A rounded surface card used everywhere.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: const BorderSide(color: AppTheme.line),
      ),
      child: Container(
        width: double.infinity,
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Section label.
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color ?? AppTheme.textLo,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// Thin progress bar.
class Bar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;
  const Bar(this.value, {super.key, required this.color, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: AppTheme.surfaceHi,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Big number stat.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const StatTile(this.value, this.label, {super.key, this.color = AppTheme.textHi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppTheme.textLo, fontSize: 11)),
      ],
    );
  }
}

/// 1..5 selector (sleep, energy).
class Rating extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  const Rating({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final on = value != null && n <= value!;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(n),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 38,
              decoration: BoxDecoration(
                color: on ? AppTheme.green : AppTheme.surfaceHi,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text('$n',
                  style: TextStyle(
                      color: on ? Colors.black : AppTheme.textLo,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        );
      }),
    );
  }
}
