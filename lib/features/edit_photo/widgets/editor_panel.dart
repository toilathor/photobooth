import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:my_photobooth/components/primary_button.dart';
import 'package:my_photobooth/components/secondary_button.dart';
import 'package:my_photobooth/features/edit_photo/widgets/video_recap_player.dart';
import 'package:my_photobooth/models/frame_data.dart';

import 'frame_selector.dart';

class EditorPanel extends StatelessWidget {
  final List<FrameData> availableFrames;
  final String selectedFrame;
  final void Function(FrameData) onFrameSelected;
  final List<XFile> photos;
  final XFile? videoRecapFile;
  final List<Duration> photoTimestamps;
  final bool isProcessing;

  const EditorPanel({
    super.key,
    required this.availableFrames,
    required this.selectedFrame,
    required this.onFrameSelected,
    required this.photos,
    this.videoRecapFile,
    this.photoTimestamps = const [],
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'CHỌN KHUNG HÌNH',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2,
                  color: colorScheme.secondary,
                ),
              ),
            ),
            Expanded(
              child: FrameSelector(
                availableFrames: availableFrames,
                selectedFrame: selectedFrame,
                onFrameSelected: onFrameSelected,
              ),
            ),
            if (videoRecapFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextButton.icon(
                  onPressed: () {
                    final frameData = availableFrames.firstWhere(
                      (FrameData f) => f.path == selectedFrame,
                    );
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        backgroundColor: Colors.black,
                        insetPadding: const EdgeInsets.all(24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: VideoRecapPlayer(
                            videoFile: videoRecapFile!,
                            frame: frameData,
                            photoTimestamps: photoTimestamps,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('XEM VIDEO RECAP'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Download Button
                  Expanded(
                    flex: 1,
                    child: SecondaryButton(
                      onTap: () {
                        // TODO: Implement download logic
                      },
                      icon: Icons.file_download_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Print Button
                  Expanded(
                    flex: 3,
                    child: PrimaryButton(
                      onTap: () {
                        // TODO: Implement print logic
                      },
                      label: 'IN ẢNH',
                      icon: Icons.local_printshop_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
