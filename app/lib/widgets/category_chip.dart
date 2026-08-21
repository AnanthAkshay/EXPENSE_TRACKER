import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final String iconKey;
  final String colorHex;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    this.isSelected = false,
    this.onTap,
  });

  static IconData getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'utensils':
      case 'food':
        return Icons.restaurant;
      case 'car':
      case 'transport':
        return Icons.directions_car;
      case 'shopping-bag':
      case 'shopping':
        return Icons.shopping_bag;
      case 'file-text':
      case 'bills':
        return Icons.receipt_long;
      case 'film':
      case 'entertainment':
        return Icons.movie;
      case 'book-open':
      case 'education':
        return Icons.school;
      case 'activity':
      case 'health':
        return Icons.favorite;
      case 'plane':
      case 'travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  static Color parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = parseColor(colorHex);
    final iconData = getIconData(iconKey);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? catColor : catColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? catColor : catColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 16,
              color: isSelected ? Colors.white : catColor,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : catColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
