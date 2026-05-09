import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_photobooth/models/frame_data.dart';
import 'frame_item.dart';

class FrameSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: availableFrames.length,
      itemBuilder: (context, index) {
        final frame = availableFrames[index];
        return FrameItem(
          framePath: frame.path,
          isSelected: selectedFrame == frame.path,
          onTap: () => onFrameSelected(frame),
        );
      },
    );
  }
}
