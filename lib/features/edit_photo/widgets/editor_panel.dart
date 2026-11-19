import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:material_ui/material_ui.dart';
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
  final VoidCallback? onSaveRequested;
  final VoidCallback onCompleteRequested;
  final bool requiresQr;

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
    this.onSaveRequested,
    required this.onCompleteRequested,
    this.requiresQr = false,
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
                ? const EdgeInsets.fromLTRB(12, 12, 12, 8)
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
          Expanded(child: _buildTabContent(colorScheme)),

          if (widget.requiresQr)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: colorScheme.secondary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      t.editor.completeEditingHint,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          (() {
            final bool isLandscape =
                MediaQuery.orientationOf(context) == Orientation.landscape;
            if (!widget.isMobile || isLandscape) {
              final double btnHeight = widget.isMobile ? 48.0 : 72.0;
              return Padding(
                padding: widget.isMobile
                    ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    : const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (kIsWeb) ...[
                      if (widget.onSaveRequested != null ||
                          widget.requiresQr) ...[
                        Expanded(
                          flex: 1,
                          child: Tooltip(
                            message: widget.onSaveRequested == null
                                ? t.editor.completeBeforeDownload
                                : t.editor.saveToDevice,
                            child: SecondaryButton(
                              onTap: widget.onSaveRequested,
                              icon: Icons.save_alt_rounded,
                              height: btnHeight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ] else ...[
                      if (widget.onSaveRequested != null) ...[
                        Expanded(
                          flex: 1,
                          child: Tooltip(
                            message: t.editor.saveToDevice,
                            child: SecondaryButton(
                              onTap: widget.onSaveRequested!,
                              icon: Icons.save_alt_rounded,
                              height: btnHeight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ],
                    Expanded(
                      flex: 3,
                      child: Tooltip(
                        message: t.editor.completeEditing,
                        child: PrimaryButton(
                          onTap: widget.onCompleteRequested,
                          label: t.editor.completeEditing,
                          height: btnHeight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          })(),
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
          isMobile: widget.isMobile,
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
                isMobile: widget.isMobile,
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
            const Gap(16),
          ],
        ),
      ],
    );
  }
}
