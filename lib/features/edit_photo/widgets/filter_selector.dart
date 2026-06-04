import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:th_photobooth/components/custom_scrollbar.dart';
import 'package:th_photobooth/core/configs/filter_config.dart';
import 'package:th_photobooth/gen/assets.gen.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class FilterSelector extends StatefulWidget {
  final List<String> filters;
  final String selectedFilter;
  final void Function(String) onFilterSelected;
  final ColorScheme colorScheme;
  final String? previewImagePath;
  final bool isDisabled;
  final bool isMobile;

  const FilterSelector({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.colorScheme,
    this.previewImagePath,
    this.isDisabled = false,
    this.isMobile = false,
  });

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return CustomScrollbar(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 2, left: 24, right: 24),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(24, 2, 24, 2),
          itemCount: widget.filters.length,
          itemBuilder: (context, index) {
            final filterKey = widget.filters[index];
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _FilterThumbnail(
                filterKey: filterKey,
                isSelected: widget.selectedFilter == filterKey,
                onTap: widget.isDisabled
                    ? null
                    : () => widget.onFilterSelected(filterKey),
                colorScheme: widget.colorScheme,
              ),
            );
          },
        ),
      );
    }

    return CustomScrollbar(
      controller: _scrollController,
      padding: const EdgeInsets.only(right: 4, top: 12, bottom: 20),
      child: MasonryGridView.count(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: widget.filters.length,
        itemBuilder: (context, index) {
          final filterKey = widget.filters[index];
          return _FilterThumbnail(
            filterKey: filterKey,
            isSelected: widget.selectedFilter == filterKey,
            onTap: widget.isDisabled
                ? null
                : () => widget.onFilterSelected(filterKey),
            colorScheme: widget.colorScheme,
          );
        },
      ),
    );
  }
}

class _FilterThumbnail extends StatelessWidget {
  final String filterKey;
  final bool isSelected;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  const _FilterThumbnail({
    required this.filterKey,
    required this.isSelected,
    this.onTap,
    required this.colorScheme,
  });

  Widget _buildPreviewImage() {
    return Assets.images.sampleFilter.image(fit: BoxFit.cover);
  }

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.05 : 0.95,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? colorScheme.secondary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.secondary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                // Inner image thumbnail
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        FilterConfig.getFilterMatrix(filterKey, 1.0),
                      ),
                      child: _buildPreviewImage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? colorScheme.secondary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
