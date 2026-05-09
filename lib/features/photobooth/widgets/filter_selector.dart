import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';

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
          'Bộ lọc màu',
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
          children: provider.filters.map((filter) {
            final isSelected = provider.selectedFilter == filter;
            return FilterChip(
              label: Text(filter),
              selected: provider.selectedFilter == filter,
              onSelected: provider.isCapturing 
                  ? null 
                  : (selected) {
                      if (selected) provider.setFilter(filter);
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
