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
import 'package:th_photobooth/models/qr_corner.dart';

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

  /// Names what "complete" actually does here: create a QR or print.
  final String completeLabel;
  final bool requiresQr;
  final bool photoIsMirrored;

  /// Where the gallery QR sits on the print. The picker is hidden when
  /// [onQrCornerChanged] is null (no QR is printed).
  final QrCorner qrCorner;
  final ValueChanged<QrCorner>? onQrCornerChanged;

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
    required this.completeLabel,
    this.requiresQr = false,
    this.photoIsMirrored = false,
    this.qrCorner = QrCorner.fallback,
    this.onQrCornerChanged,
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

          if (widget.onQrCornerChanged != null)
            _QrCornerPicker(
              selected: widget.qrCorner,
              onChanged: widget.onQrCornerChanged!,
              isMobile: widget.isMobile,
            ),

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
                      style: GoogleFonts.inter(
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
                              semanticLabel: t.editor.saveToDevice,
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
                              semanticLabel: t.editor.saveToDevice,
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
                      child: PrimaryButton(
                        onTap: widget.onCompleteRequested,
                        label: widget.completeLabel,
                        height: btnHeight,
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
                previewImagePath: widget.photos.isNotEmpty
                    ? widget.photos.first.path
                    : null,
                previewIsMirrored: widget.photoIsMirrored,
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
                        label: '${(widget.filterIntensity * 100).toInt()}%',
                        semanticFormatterCallback: (v) =>
                            '${t.filters.title} ${(v * 100).toInt()}%',
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
                        style: GoogleFonts.inter(
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

class _QrCornerPicker extends StatelessWidget {
  final QrCorner selected;
  final ValueChanged<QrCorner> onChanged;
  final bool isMobile;

  const _QrCornerPicker({
    required this.selected,
    required this.onChanged,
    required this.isMobile,
  });

  String _label(QrCorner corner) => switch (corner) {
    QrCorner.topLeft => t.editor.qrCorners.topLeft,
    QrCorner.topRight => t.editor.qrCorners.topRight,
    QrCorner.bottomLeft => t.editor.qrCorners.bottomLeft,
    QrCorner.bottomRight => t.editor.qrCorners.bottomRight,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        12,
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              t.editor.qrPosition,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          for (final corner in QrCorner.values)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Tooltip(
                message: _label(corner),
                child: Semantics(
                  button: true,
                  selected: corner == selected,
                  label: '${t.editor.qrPosition}: ${_label(corner)}',
                  excludeSemantics: true,
                  child: Material(
                    key: ValueKey('qr-corner-${corner.name}'),
                    color: corner == selected
                        ? colorScheme.secondary
                        : colorScheme.onSurface.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onChanged(corner),
                      child: SizedBox.square(
                        dimension: 44,
                        child: Icon(
                          corner.icon,
                          size: 20,
                          color: corner == selected
                              ? colorScheme.onSecondary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
