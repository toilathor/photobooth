import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/core/configs/asset_config.dart';
import 'package:my_photobooth/core/configs/filter_config.dart';
import 'package:my_photobooth/i18n/strings.g.dart';

class FilterSelector extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final void Function(String) onFilterSelected;
  final ColorScheme colorScheme;
  final String? previewImagePath;
  final bool isDisabled;

  const FilterSelector({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.colorScheme,
    this.previewImagePath,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filters.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery.of(context).size.width / 250).floor(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final filterKey = filters[index];
        return _FilterThumbnail(
          filterKey: filterKey,
          isSelected: selectedFilter == filterKey,
          previewImagePath: previewImagePath,
          onTap: isDisabled ? null : () => onFilterSelected(filterKey),
          colorScheme: colorScheme,
        );
      },
    );
  }
}

class _FilterThumbnail extends StatelessWidget {
  final String filterKey;
  final bool isSelected;
  final String? previewImagePath;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  const _FilterThumbnail({
    required this.filterKey,
    required this.isSelected,
    this.previewImagePath,
    this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    if (filterKey == 'normal') {
      label = t.filters.normal;
    } else {
      label = FilterConfig.getFilter(filterKey).name;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? colorScheme.secondary : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.secondary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(
                  FilterConfig.getFilterMatrix(filterKey, 1.0),
                ),
                child: Image.asset(AssetConfig.sampleFilter, fit: BoxFit.cover),
              ),
            ),
          ),
          const Gap(8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? colorScheme.secondary
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
