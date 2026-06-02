import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:th_photobooth/components/custom_scrollbar.dart';
import 'package:th_photobooth/models/frame_data.dart';

import 'frame_item.dart';

class FrameSelector extends StatefulWidget {
  final List<FrameData> availableFrames;
  final String selectedFrame;
  final void Function(FrameData) onFrameSelected;

  const FrameSelector({
    super.key,
    required this.availableFrames,
    required this.selectedFrame,
    required this.onFrameSelected,
  });

  @override
  State<FrameSelector> createState() => _FrameSelectorState();
}

class _FrameSelectorState extends State<FrameSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollbar(
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
        itemCount: widget.availableFrames.length,
        itemBuilder: (context, index) {
          final frame = widget.availableFrames[index];
          return FrameItem(
            framePath: frame.path,
            isSelected: widget.selectedFrame == frame.path,
            onTap: () => widget.onFrameSelected(frame),
          );
        },
      ),
    );
  }
}
