import 'package:flutter/material.dart';

/// Colored chip for categories
class CategoryBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const CategoryBadge({super.key, required this.label, this.color, this.icon});

  Color get _defaultColor => const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _defaultColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
