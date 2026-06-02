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
  final List<XFile> photos;

  const VideoRecapPlayer({
    super.key,
    required this.videoFile,
    required this.frame,
    required this.photoTimestamps,
    required this.photos,
    this.isMirrored = false,
  });

  @override
  State<VideoRecapPlayer> createState() => _VideoRecapPlayerState();
}

class _VideoRecapPlayerState extends State<VideoRecapPlayer> {
  RecapViewMode _viewMode = RecapViewMode.frame;
  bool _isPlaying = true;

  // Controller for full video
  VideoPlayerController? _fullController;
  bool _fullInitialized = false;

  // Controller for slots (sequential playback)
  VideoPlayerController? _slotVideoController;
  bool _slotVideoInitialized = false;
  int _activeSlotIndex = 0;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    if (_viewMode == RecapViewMode.full) {
      _initializeFullPlayer();
    } else {
      _initializeSlotPlayers();
    }
  }

  void _disposeFullPlayer() {
    _fullController?.dispose();
    _fullController = null;
    _fullInitialized = false;
  }

  void _disposeSlotPlayers() {
    _slotVideoController?.removeListener(_slotVideoListener);
    _slotVideoController?.dispose();
    _slotVideoController = null;
    _slotVideoInitialized = false;
    _isSeeking = false;
  }

  Future<void> _initializeFullPlayer() async {
    final videoPath = widget.videoFile.path;
    final controller = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(videoPath))
        : VideoPlayerController.file(File(videoPath));

    _fullController = controller;
    _fullInitialized = false;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0); // Always mute
      if (mounted && _fullController == controller) {
        setState(() => _fullInitialized = true);
        if (_isPlaying) {
          controller.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing full player: $e');
    }
  }

  Duration _getSlotStartTime(int i) {
    final endTime = _getSlotEndTime(i);
    return endTime > AppConfig.recapClipDuration
        ? endTime - AppConfig.recapClipDuration
        : Duration.zero;
  }

  Duration _getSlotEndTime(int i) {
    final timestamps = widget.photoTimestamps;
    final duration = _slotVideoController?.value.duration ?? Duration.zero;
    if (i < timestamps.length) {
      return timestamps[i];
    }
    return duration;
  }

  Future<void> _initializeSlotPlayers() async {
    final videoPath = widget.videoFile.path;

    _disposeSlotPlayers();

    final controller = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(videoPath))
        : VideoPlayerController.file(File(videoPath));

    _slotVideoController = controller;
    _slotVideoInitialized = false;
    _activeSlotIndex = 0;

    try {
      await controller.initialize();
      await controller.setVolume(0); // Always mute slots

      final startTime = _getSlotStartTime(0);
      await controller.seekTo(startTime);

      controller.addListener(_slotVideoListener);

      if (mounted && _slotVideoController == controller) {
        setState(() => _slotVideoInitialized = true);
        if (_isPlaying) {
          controller.play();
        }
      }
    } catch (e) {
      debugPrint('Error initializing slot player: $e');
    }
  }

  void _slotVideoListener() {
    final controller = _slotVideoController;
    if (controller == null ||
        !mounted ||
        _viewMode != RecapViewMode.frame ||
        !_isPlaying) {
      return;
    }

    final endTime = _getSlotEndTime(_activeSlotIndex);
    if (!_isSeeking && controller.value.position >= endTime) {
      _isSeeking = true;

      // Move to next slot
      setState(() {
        _activeSlotIndex = (_activeSlotIndex + 1) % widget.frame.slots.length;
      });

      final nextStartTime = _getSlotStartTime(_activeSlotIndex);
      controller
          .seekTo(nextStartTime)
          .then((_) {
            _isSeeking = false;
          })
          .catchError((dynamic e) {
            _isSeeking = false;
            debugPrint('Error seeking to next slot $_activeSlotIndex: $e');
          });
    }
  }

  void _goToPreviousSlot() {
    if (_slotVideoController == null || !_slotVideoInitialized || _isSeeking) {
      return;
    }

    _isSeeking = true;

    if (_activeSlotIndex == 0) {
      final startTime = _getSlotStartTime(0);
      _slotVideoController!
          .seekTo(startTime)
          .then((_) {
            _isSeeking = false;
          })
          .catchError((dynamic e) {
            _isSeeking = false;
            debugPrint('Error seeking to start of slot 0: $e');
          });
    } else {
      setState(() {
        _activeSlotIndex--;
      });

      final nextStartTime = _getSlotStartTime(_activeSlotIndex);
      _slotVideoController!
          .seekTo(nextStartTime)
          .then((_) {
            _isSeeking = false;
          })
          .catchError((dynamic e) {
            _isSeeking = false;
            debugPrint('Error seeking to previous slot $_activeSlotIndex: $e');
          });
    }
  }

  void _goToNextSlot() {
    if (_slotVideoController == null || !_slotVideoInitialized || _isSeeking) {
      return;
    }

    _isSeeking = true;
    setState(() {
      _activeSlotIndex = (_activeSlotIndex + 1) % widget.frame.slots.length;
    });

    final nextStartTime = _getSlotStartTime(_activeSlotIndex);
    _slotVideoController!
        .seekTo(nextStartTime)
        .then((_) {
          _isSeeking = false;
        })
        .catchError((dynamic e) {
          _isSeeking = false;
          debugPrint('Error seeking to next slot $_activeSlotIndex: $e');
        });
  }

  void _handleTap(TapUpDetails details, double width) {
    if (_viewMode != RecapViewMode.frame) return;

    if (details.localPosition.dx < width / 2) {
      _goToPreviousSlot();
    } else {
      _goToNextSlot();
    }
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_viewMode == RecapViewMode.full) {
        if (_isPlaying) {
          _fullController?.play();
        } else {
          _fullController?.pause();
        }
      } else {
        if (_isPlaying) {
          _slotVideoController?.play();
        } else {
          _slotVideoController?.pause();
        }
      }
    });
  }

  void _restartPlayback() {
    setState(() {
      _isPlaying = true;
      if (_viewMode == RecapViewMode.full) {
        _fullController?.seekTo(Duration.zero);
        _fullController?.play();
      } else {
        _activeSlotIndex = 0;
        final startTime = _getSlotStartTime(0);
        _slotVideoController?.seekTo(startTime);
        _slotVideoController?.play();
      }
    });
  }

  Widget _buildStoryProgressBar() {
    if (_slotVideoController == null || !_slotVideoInitialized) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _slotVideoController!,
      builder: (context, value, child) {
        final startTime = _getSlotStartTime(_activeSlotIndex);
        final endTime = _getSlotEndTime(_activeSlotIndex);
        final totalMs = endTime.inMilliseconds - startTime.inMilliseconds;
        double progress = 0.0;
        if (totalMs > 0) {
          final currentMs =
              value.position.inMilliseconds - startTime.inMilliseconds;
          progress = (currentMs / totalMs).clamp(0.0, 1.0);
        }

        return _StoryProgressIndicator(
          count: widget.frame.slots.length,
          activeIndex: _activeSlotIndex,
          activeProgress: progress,
        );
      },
    );
  }

  @override
  void dispose() {
    _disposeFullPlayer();
    _disposeSlotPlayers();
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    _handleTap(details, constraints.maxWidth);
                  },
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
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(
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

                      // Story Progress Bar
                      if (_viewMode == RecapViewMode.frame)
                        Positioned(
                          top: 8,
                          left: 24,
                          right: 24,
                          child: _buildStoryProgressBar(),
                        ),
                    ],
                  ),
                );
              },
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

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
              const Gap(16),
              // Mode Selector
              _ModeSelector(
                currentMode: _viewMode,
                onChanged: (mode) {
                  if (mode == _viewMode) return;
                  setState(() => _viewMode = mode);
                  if (mode == RecapViewMode.full) {
                    _disposeSlotPlayers();
                    _initializeFullPlayer();
                  } else {
                    _disposeFullPlayer();
                    _initializeSlotPlayers();
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
        ),
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
          if (_viewMode == RecapViewMode.full &&
              _fullInitialized &&
              _fullController != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _VideoProgressBar(controller: _fullController!),
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
    if (!_fullInitialized || _fullController == null) {
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
        aspectRatio: _fullController?.value.aspectRatio ?? 1,
        child: Transform.scale(
          scaleX: widget.isMirrored == kIsWeb ? 1 : -1,
          child: VideoPlayer(_fullController!),
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
                // Slot Video Players / Photo Previews
                for (int i = 0; i < frame.slots.length; i++)
                  Positioned(
                    left: frame.slots[i].left * scaleX,
                    top: frame.slots[i].top * scaleY,
                    width: frame.slots[i].width * scaleX,
                    height: frame.slots[i].height * scaleY,
                    child: Container(
                      color: Colors.black,
                      child: i == _activeSlotIndex
                          ? (_slotVideoInitialized &&
                                    _slotVideoController != null
                                ? ClipRRect(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _slotVideoController!
                                            .value
                                            .size
                                            .width,
                                        height: _slotVideoController!
                                            .value
                                            .size
                                            .height,
                                        child: Transform.scale(
                                          scaleX: widget.isMirrored == kIsWeb
                                              ? 1
                                              : -1,
                                          child: VideoPlayer(
                                            _slotVideoController!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ))
                          : (widget.photos.length > i
                                ? ClipRRect(
                                    child: Transform.scale(
                                      scaleX: widget.isMirrored ? -1 : 1,
                                      child: kIsWeb
                                          ? Image.network(
                                              widget.photos[i].path,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(widget.photos[i].path),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                    ),
                  ),
                // Frame Overlay
                if (frame.path.isNotEmpty)
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

class _StoryProgressIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double activeProgress;

  const _StoryProgressIndicator({
    required this.count,
    required this.activeIndex,
    required this.activeProgress,
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
                    duration: const Duration(milliseconds: 200),
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
