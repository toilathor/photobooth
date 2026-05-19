import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/components/primary_button.dart';
import 'package:my_photobooth/components/secondary_button.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:my_photobooth/models/frame_data.dart';

import 'package:my_photobooth/components/filter_selector.dart';
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
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: widget.isMobile
                ? const EdgeInsets.fromLTRB(16, 16, 16, 12)
                : const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              t.editor.title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2,
                color: colorScheme.secondary,
              ),
            ),
          ),

          // Tab Switcher
          Padding(
            padding: widget.isMobile
                ? const EdgeInsets.symmetric(horizontal: 16)
                : const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: t.editor.frames,
                    icon: Icons.filter_frames_rounded,
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    colorScheme: colorScheme,
                  ),
                  _TabButton(
                    label: t.editor.filters,
                    icon: Icons.auto_awesome_rounded,
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ),

          const Gap(16),

          // Tab Content
          widget.isMobile
              ? SizedBox(
                  height: 180,
                  child: IndexedStack(
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
                              previewImagePath: widget.photos.isNotEmpty
                                  ? widget.photos.first.path
                                  : null,
                            ),
                          ),
                          if (widget.selectedFilter != 'normal') ...[
                            const Gap(16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tonality_rounded,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 20,
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Slider(
                                      value: widget.filterIntensity,
                                      onChanged: widget.onFilterIntensityChanged,
                                      activeColor: colorScheme.secondary,
                                      inactiveColor: colorScheme.onSurface
                                          .withValues(alpha: 0.1),
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
                          ],
                        ],
                      ),
                    ],
                  ),
                )
              : Expanded(
                  child: IndexedStack(
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
                              previewImagePath: widget.photos.isNotEmpty
                                  ? widget.photos.first.path
                                  : null,
                            ),
                          ),
                          if (widget.selectedFilter != 'normal') ...[
                            const Gap(24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tonality_rounded,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 20,
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Slider(
                                      value: widget.filterIntensity,
                                      onChanged: widget.onFilterIntensityChanged,
                                      activeColor: colorScheme.secondary,
                                      inactiveColor: colorScheme.onSurface
                                          .withValues(alpha: 0.1),
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
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

          Padding(
            padding: widget.isMobile
                ? const EdgeInsets.all(16.0)
                : const EdgeInsets.all(24.0),
            child: Row(
              children: [
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
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.onSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const Gap(8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
