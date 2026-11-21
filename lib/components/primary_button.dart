import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/components/shortcut_keycap.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String label;

  /// Leading icon, for actions named by what they produce (print, QR).
  final IconData? icon;

  /// Trailing icon, for directional actions (continue →).
  final IconData? trailingIcon;

  /// Key that also triggers the button, shown as a keycap while enabled.
  final ShortcutKey? shortcut;
  final double height;

  const PrimaryButton({
    super.key,
    required this.onTap,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.shortcut,
    this.height = 72,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = widget.onTap != null;
    final bool isLarge = widget.height > 60;
    final double iconSize = isLarge ? 26 : 20;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget iconWidget(IconData data) =>
        Icon(data, color: colorScheme.onSecondary, size: iconSize);

    return Semantics(
      button: true,
      enabled: isEnabled,
      child: AnimatedScale(
        // Feedback lands on press-down, not on release.
        scale: _pressed && !reduceMotion ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: colorScheme.secondary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHighlightChanged: isEnabled ? _setPressed : null,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        iconWidget(widget.icon!),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontSize: isLarge ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        iconWidget(widget.trailingIcon!),
                      ],
                      if (widget.shortcut != null &&
                          isEnabled &&
                          ShortcutKeycap.isShown(context)) ...[
                        const SizedBox(width: 12),
                        ShortcutKeycap(
                          widget.shortcut!,
                          color: colorScheme.onSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
