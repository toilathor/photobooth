import 'package:material_ui/material_ui.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final double height;

  /// Read by screen readers, since the button shows only an icon.
  final String? semanticLabel;

  const SecondaryButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.height = 72,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onTap != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.5,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Icon(
                  icon,
                  color: colorScheme.onSurface,
                  size: height > 60 ? 28 : 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
