import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// A labelled segmented control: every option is visible and one tap away,
/// which suits the two or three choices the booth offers better than a menu.
class SegmentedSetting<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T>? onChanged;
  final String Function(T) itemLabelBuilder;

  /// Optional note under the control, e.g. what the selected option suits.
  final String? hint;

  const SegmentedSetting({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onChanged != null;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const Gap(8),
        Opacity(
          opacity: isEnabled ? 1 : 0.5,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: item == value,
                      enabled: isEnabled,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: isEnabled && item != value
                            ? () => onChanged!(item)
                            : null,
                        child: AnimatedContainer(
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          constraints: const BoxConstraints(minHeight: 40),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: item == value
                                ? colorScheme.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: item == value
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              itemLabelBuilder(item),
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: item == value
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: item == value
                                    ? colorScheme.onSecondary
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hint != null) ...[
          const Gap(6),
          Text(
            hint!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ],
    );
  }
}
