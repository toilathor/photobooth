import 'package:material_ui/material_ui.dart';

class FrameItem extends StatelessWidget {
  final String framePath;
  final bool isSelected;
  final VoidCallback onTap;

  const FrameItem({
    super.key,
    required this.framePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.secondary : Colors.transparent,
              width: 3,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                if (framePath.isEmpty)
                  Container(
                    color: colorScheme.errorContainer,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.error,
                      size: 40,
                    ),
                  )
                else
                  Image.asset(
                    framePath,
                    fit: BoxFit.cover,
                    cacheWidth: 150,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.errorContainer,
                      child: Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: 40,
                      ),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: colorScheme.onSecondary,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
