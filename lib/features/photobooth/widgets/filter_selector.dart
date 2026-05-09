import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/i18n/strings.g.dart';

class FilterSelector extends StatelessWidget {
  final PhotoboothProvider provider;
  final ColorScheme colorScheme;

  const FilterSelector({
    super.key,
    required this.provider,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.filters.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.filters.map((filterKey) {
            final isSelected = provider.selectedFilter == filterKey;
            
            // Map key to localized string
            String label;
            switch (filterKey) {
              case 'normal': label = t.filters.normal; break;
              case 'mono': label = t.filters.mono; break;
              case 'bw': label = t.filters.bw; break;
              case 'soft': label = t.filters.soft; break;
              case 'dazz_classic': label = t.filters.dazz_classic; break;
              case 'dazz_instant': label = t.filters.dazz_instant; break;
              default: label = filterKey;
            }

            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: provider.isCapturing 
                  ? null 
                  : (selected) {
                      if (selected) provider.setFilter(filterKey);
                    },
              selectedColor: colorScheme.secondary.withValues(alpha: 0.2),
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
