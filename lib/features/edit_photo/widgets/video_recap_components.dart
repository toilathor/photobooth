import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:video_player/video_player.dart';

import 'video_recap_player.dart' show RecapViewMode;

class RecapModeSelector extends StatelessWidget {
  final RecapViewMode currentMode;
  final ValueChanged<RecapViewMode> onChanged;

  const RecapModeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RecapModeItem(
            isSelected: currentMode == RecapViewMode.frame,
            icon: Icons.grid_view_rounded,
            label: t.editor.frame_mode,
            onTap: () => onChanged(RecapViewMode.frame),
          ),
          RecapModeItem(
            isSelected: currentMode == RecapViewMode.full,
            icon: Icons.fullscreen_rounded,
            label: t.editor.full_mode,
            onTap: () => onChanged(RecapViewMode.full),
          ),
        ],
      ),
    );
  }
}

class RecapModeItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const RecapModeItem({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onSecondary
                  : Colors.white.withValues(alpha: 0.5),
            ),
            if (isSelected) ...[
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RecapControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const RecapControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class RecapVideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const RecapVideoProgressBar({super.key, required this.controller});

  @override
  State<RecapVideoProgressBar> createState() => _RecapVideoProgressBarState();
}

class _RecapVideoProgressBarState extends State<RecapVideoProgressBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final duration = value.duration.inMilliseconds;
    final position = value.position.inMilliseconds;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
        thumbColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.2),
      ),
      child: Slider(
        value: duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0,
        onChanged: (val) {
          final target = Duration(milliseconds: (val * duration).toInt());
          widget.controller.seekTo(target);
        },
      ),
    );
  }
}

class StoryProgressIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double activeProgress;
  final bool isSeeking;

  const StoryProgressIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    required this.activeProgress,
    required this.isSeeking,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        double progress = 0.0;
        if (index < activeIndex) {
          progress = 1.0;
        } else if (index == activeIndex) {
          progress = activeProgress;
        }

        final duration = isSeeking || progress == 0.0
            ? Duration.zero
            : const Duration(milliseconds: 200);

        return Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: Curves.linear,
                    width: maxWidth * progress,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
