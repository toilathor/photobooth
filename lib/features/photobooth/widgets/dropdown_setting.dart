import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownSetting<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String suffix;
  final String Function(T)? itemLabelBuilder;

  const DropdownSetting({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.suffix = '',
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Gap(8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        '${itemLabelBuilder != null ? itemLabelBuilder!(e) : e}$suffix',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              isExpanded: true,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
