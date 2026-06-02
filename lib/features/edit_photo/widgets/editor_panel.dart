import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:th_photobooth/components/expressive_button_group.dart';
import 'package:th_photobooth/components/primary_button.dart';
import 'package:th_photobooth/components/secondary_button.dart';
import 'package:th_photobooth/features/edit_photo/widgets/filter_selector.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';

import 'frame_selector.dart';

class EditorPanel extends StatefulWidget {
  final List<FrameData> availableFrames;
  final String selectedFrame;
  final void Function(FrameData) onFrameSelected;
  final List<XFile> photos;
  final XFile? videoRecapFile;
  final List<Duration> photoTimestamps;
  final bool isProcessing;

  final List<String> filters;
  final String selectedFilter;
  final double filterIntensity;
  final void Function(String) onFilterSelected;
  final void Function(double) onFilterIntensityChanged;
  final VoidCallback? onQRRequested;
  final VoidCallback? onSaveRequested;

  const EditorPanel({
    super.key,
    required this.availableFrames,
    required this.selectedFrame,
    required this.onFrameSelected,
    required this.photos,
    this.videoRecapFile,
    this.photoTimestamps = const [],
    required this.isProcessing,
    required this.filters,
    required this.selectedFilter,
    required this.filterIntensity,
    required this.onFilterSelected,
    required this.onFilterIntensityChanged,
    this.onQRRequested,
    this.onSaveRequested,
    this.isMobile = false,
  });

  final bool isMobile;

  @override
  State<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<EditorPanel> {
  int _selectedTabIndex = 0; // 0: Frames, 1: Filters

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Switcher
          Padding(
            padding: widget.isMobile
                ? const EdgeInsets.all(16)
                : const EdgeInsets.all(24),
            child: ExpressiveButtonGroup(
              selectedIndex: _selectedTabIndex,
              onChanged: (index) => setState(() => _selectedTabIndex = index),
              items: [
                ExpressiveItemData(
                  label: t.editor.frames,
                  icon: Icons.filter_frames_rounded,
                ),
                ExpressiveItemData(
                  label: t.editor.filters,
                  icon: Icons.auto_awesome_rounded,
                ),
              ],
            ),
          ),

          // Tab Content
          widget.isMobile
              ? SizedBox(height: 180, child: _buildTabContent(colorScheme))
              : Expanded(child: _buildTabContent(colorScheme)),

          if (!widget.isMobile)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (kIsWeb) ...[
                    if (widget.onQRRequested != null) ...[
                      Expanded(
                        flex: 1,
                        child: SecondaryButton(
                          onTap: widget.onQRRequested!,
                          icon: Icons.qr_code_2_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (widget.onSaveRequested != null) ...[
                      Expanded(
                        flex: 1,
                        child: SecondaryButton(
                          onTap: widget.onSaveRequested!,
                          icon: Icons.save_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ] else ...[
                    if (widget.onSaveRequested != null) ...[
                      Expanded(
                        flex: 1,
                        child: SecondaryButton(
                          onTap: widget.onSaveRequested!,
                          icon: Icons.save_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ],
                  // Print Button
                  Expanded(
                    flex: 3,
                    child: PrimaryButton(
                      onTap: () {
                        // TODO: Implement print logic
                      },
                      label: t.editor.printPhoto,
                      icon: Icons.local_printshop_rounded,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colorScheme) {
    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        // Frames Tab
        FrameSelector(
          availableFrames: widget.availableFrames,
          selectedFrame: widget.selectedFrame,
          onFrameSelected: widget.onFrameSelected,
        ),

        // Filters Tab
        Column(
          children: [
            Expanded(
              child: FilterSelector(
                filters: widget.filters,
                selectedFilter: widget.selectedFilter,
                onFilterSelected: widget.onFilterSelected,
                colorScheme: colorScheme,
              ),
            ),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              replacement: const SizedBox.shrink(),
              visible: widget.selectedFilter != 'normal',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.tonality_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Slider(
                        value: widget.filterIntensity,
                        onChanged: widget.onFilterIntensityChanged,
                        activeColor: colorScheme.secondary,
                        inactiveColor: colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${(widget.filterIntensity * 100).toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(16),
          ],
        ),
      ],
    );
  }
}
