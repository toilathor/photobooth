import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:th_photobooth/components/custom_scrollbar.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';

import 'frame_item.dart';

class FrameSelector extends StatefulWidget {
  final List<FrameData> availableFrames;
  final String selectedFrame;
  final void Function(FrameData) onFrameSelected;
  final bool isMobile;

  const FrameSelector({
    super.key,
    required this.availableFrames,
    required this.selectedFrame,
    required this.onFrameSelected,
    this.isMobile = false,
  });

  @override
  State<FrameSelector> createState() => _FrameSelectorState();
}

class _FrameSelectorState extends State<FrameSelector> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  String _selectedCategory = '__all__';

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      '__all__',
      ...widget.availableFrames
          .map((f) => f.categoryName)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort(),
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          final String displayLabel = category == '__all__'
              ? t.editor.all
              : category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? colorScheme.secondary
                      : colorScheme.secondary.withValues(alpha: 0.05),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : colorScheme.secondary.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.secondary.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    displayLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onSecondary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFrames = _selectedCategory == '__all__'
        ? widget.availableFrames
        : widget.availableFrames
              .where((f) => f.categoryName == _selectedCategory)
              .toList();

    if (widget.isMobile) {
      return Column(
        children: [
          _buildCategoryFilter(context),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: filteredFrames.length,
              itemBuilder: (context, index) {
                final frame = filteredFrames[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FrameItem(
                    framePath: frame.path,
                    isSelected: widget.selectedFrame == frame.path,
                    onTap: () => widget.onFrameSelected(frame),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildCategoryFilter(context),
        Expanded(
          child: CustomScrollbar(
            controller: _scrollController,
            padding: const EdgeInsets.only(right: 4, top: 12, bottom: 20),
            child: MasonryGridView.count(
              controller: _scrollController,
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.fromLTRB(
                24,
                12,
                24,
                20,
              ), // Added bottom padding for scrollbar visibility
              itemCount: filteredFrames.length,
              itemBuilder: (context, index) {
                final frame = filteredFrames[index];
                return FrameItem(
                  framePath: frame.path,
                  isSelected: widget.selectedFrame == frame.path,
                  onTap: () => widget.onFrameSelected(frame),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
