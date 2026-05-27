import 'package:flutter/material.dart';

class ExpressiveItemData {
  final String label;
  final IconData icon;

  const ExpressiveItemData({required this.label, required this.icon});
}

class ExpressiveButtonGroup extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<ExpressiveItemData> items;

  const ExpressiveButtonGroup({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          return ExpressiveButton(
            data: items[index],
            isSelected: isSelected,
            onTap: () => onChanged(index),
          );
        }),
      ),
    );
  }
}

class ExpressiveButton extends StatelessWidget {
  final ExpressiveItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const ExpressiveButton({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onSecondary
                  : colorScheme.secondary.withValues(alpha: 0.5),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: SizedBox(width: isSelected ? 8 : 0),
            ),
            if (isSelected)
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSecondary,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
