import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:th_photobooth/core/configs/app_config.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/frame_data.dart';
import 'package:video_player/video_player.dart';

enum RecapViewMode { full, frame }

class VideoRecapPlayer extends StatefulWidget {
  final XFile videoFile;
  final FrameData frame;
  final List<Duration> photoTimestamps;
  final bool isMirrored;

  const VideoRecapPlayer({
    super.key,
    required this.videoFile,
    required this.frame,
    required this.photoTimestamps,
    this.isMirrored = false,
  });

  @override
  State<VideoRecapPlayer> createState() => _VideoRecapPlayerState();
}

class _VideoRecapPlayerState extends State<VideoRecapPlayer> {
  RecapViewMode _viewMode = RecapViewMode.frame;
  bool _isPlaying = true;

  // Controller for full video
  late VideoPlayerController _fullController;
  bool _fullInitialized = false;

  // Controllers for each slot
  final List<VideoPlayerController> _slotControllers = [];
  final List<bool> _slotsInitialized = [];

  @override
  void initState() {
    super.initState();
    _initializeFullPlayer();
    _initializeSlotPlayers();
  }

  Future<void> _initializeFullPlayer() async {
    final videoPath = widget.videoFile.path;
    _fullController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(videoPath))
        : VideoPlayerController.file(File(videoPath));

    try {
      await _fullController.initialize();
      await _fullController.setLooping(true);
      await _fullController.setVolume(0); // Always mute
      if (mounted) {
        setState(() => _fullInitialized = true);
        if (_isPlaying && _viewMode == RecapViewMode.full) {
          _fullController.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing full player: $e');
    }
  }

  Future<void> _initializeSlotPlayers() async {
    final videoPath = widget.videoFile.path;
    final timestamps = widget.photoTimestamps;
    final slots = widget.frame.slots;

    for (int i = 0; i < slots.length; i++) {
      final controller = kIsWeb
          ? VideoPlayerController.networkUrl(Uri.parse(videoPath))
          : VideoPlayerController.file(File(videoPath));

      _slotControllers.add(controller);
      _slotsInitialized.add(false);

      try {
        await controller.initialize();

        // Logic for clip loop
        final endTime = i < timestamps.length
            ? timestamps[i]
            : controller.value.duration;
        final startTime = endTime > AppConfig.recapClipDuration
            ? endTime - AppConfig.recapClipDuration
            : Duration.zero;

        await controller.setVolume(0); // Always mute slots
        await controller.seekTo(startTime);

        controller.addListener(() {
          if (controller.value.position >= endTime) {
            controller.seekTo(startTime);
          }
        });

        if (mounted) {
          setState(() => _slotsInitialized[i] = true);
          if (_isPlaying && _viewMode == RecapViewMode.frame) {
            controller.play();
          }
        }
      } catch (e) {
        debugPrint('Error initializing slot $i player: $e');
      }
    }
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_viewMode == RecapViewMode.full) {
        if (_isPlaying) {
          _fullController.play();
        } else {
          _fullController.pause();
        }
      } else {
        for (var controller in _slotControllers) {
          if (_isPlaying) {
            controller.play();
          } else {
            controller.pause();
          }
        }
      }
    });
  }

  void _restartPlayback() {
    setState(() {
      _isPlaying = true;
      if (_viewMode == RecapViewMode.full) {
        _fullController.seekTo(Duration.zero);
        _fullController.play();
      } else {
        final timestamps = widget.photoTimestamps;
        for (int i = 0; i < _slotControllers.length; i++) {
          final endTime = i < timestamps.length
              ? timestamps[i]
              : _slotControllers[i].value.duration;
          final startTime = endTime > AppConfig.recapClipDuration
              ? endTime - AppConfig.recapClipDuration
              : Duration.zero;

          _slotControllers[i].seekTo(startTime);
          _slotControllers[i].play();
        }
      }
    });
  }

  @override
  void dispose() {
    _fullController.dispose();
    for (VideoPlayerController controller in _slotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Main Content Area
          Expanded(
            child: Stack(
              children: [
                // Background Glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                        radius: 1.2,
                      ),
                    ),
                  ),
                ),

                // Video Display
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: _viewMode == RecapViewMode.full
                        ? _buildFullView()
                        : _buildFrameView(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Controls
          _buildBottomControls(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.video_collection_rounded,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const Gap(8),
                Text(
                  t.video_recap.title,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Mode Selector
          _ModeSelector(
            currentMode: _viewMode,
            onChanged: (mode) {
              setState(() => _viewMode = mode);
              if (mode == RecapViewMode.full) {
                // Pause slot players when showing full video
                for (var controller in _slotControllers) {
                  controller.pause();
                }
                if (_fullInitialized && _isPlaying) _fullController.play();
              } else {
                // Pause full player when showing frame slots
                _fullController.pause();
                for (var controller in _slotControllers) {
                  if (_isPlaying) controller.play();
                }
              }
            },
          ),
          const Gap(16),
          IconButton.filledTonal(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    // Show controls in both modes now

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_viewMode == RecapViewMode.full && _fullInitialized)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _VideoProgressBar(controller: _fullController),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Playback Controls
              _ControlButton(
                icon: _isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: _isPlaying
                    ? t.video_recap.controls.pause
                    : t.video_recap.controls.play,
                onPressed: _togglePlayback,
              ),
              const Gap(16),
              _ControlButton(
                icon: Icons.replay_rounded,
                label: t.video_recap.controls.restart,
                onPressed: _restartPlayback,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullView() {
    if (!_fullInitialized) {
      return const CircularProgressIndicator();
    }
    return Container(
      key: const ValueKey('full_view'),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: _fullController.value.aspectRatio,
        child: Transform.scale(
          scaleX: widget.isMirrored == kIsWeb ? 1 : -1,
          child: VideoPlayer(_fullController),
        ),
      ),
    );
  }

  Widget _buildFrameView() {
    return Container(
      key: const ValueKey('frame_view'),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: widget.frame.size.width / widget.frame.size.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final frame = widget.frame;
            final scaleX = constraints.maxWidth / frame.size.width;
            final scaleY = constraints.maxHeight / frame.size.height;

            return Stack(
              children: [
                // Slot Video Players
                for (int i = 0; i < frame.slots.length; i++)
                  Positioned(
                    left: frame.slots[i].left * scaleX,
                    top: frame.slots[i].top * scaleY,
                    width: frame.slots[i].width * scaleX,
                    height: frame.slots[i].height * scaleY,
                    child: Container(
                      color: Colors.black,
                      child:
                          _slotsInitialized.length > i && _slotsInitialized[i]
                          ? ClipRRect(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _slotControllers[i].value.size.width,
                                  height: _slotControllers[i].value.size.height,
                                  child: Transform.scale(
                                    scaleX: widget.isMirrored == kIsWeb
                                        ? 1
                                        : -1,
                                    child: VideoPlayer(_slotControllers[i]),
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                    ),
                  ),
                // Frame Overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.asset(frame.path, fit: BoxFit.fill),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final RecapViewMode currentMode;
  final ValueChanged<RecapViewMode> onChanged;

  const _ModeSelector({required this.currentMode, required this.onChanged});

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
          _ModeItem(
            isSelected: currentMode == RecapViewMode.frame,
            icon: Icons.grid_view_rounded,
            label: t.editor.frame_mode,
            onTap: () => onChanged(RecapViewMode.frame),
          ),
          _ModeItem(
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

class _ModeItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeItem({
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ControlButton({
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

class _VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoProgressBar({required this.controller});

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
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
    final colorScheme = Theme.of(context).colorScheme;
    final value = widget.controller.value;
    final duration = value.duration.inMilliseconds;
    final position = value.position.inMilliseconds;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
        thumbColor: Colors.white,
        overlayColor: colorScheme.primary.withValues(alpha: 0.2),
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
