import 'package:material_ui/material_ui.dart';

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

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final foreground = isSelected
        ? colorScheme.onSecondary
        : colorScheme.onSurface.withValues(alpha: 0.7);

    // Both labels stay visible so the unselected tab never has to be guessed
    // from its icon alone.
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
