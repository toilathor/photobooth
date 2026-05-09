import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_photobooth/models/frame_data.dart';
import 'package:my_photobooth/helper/constants.dart';
import 'package:video_player/video_player.dart';

enum RecapViewMode { full, frame }

class VideoRecapPlayer extends StatefulWidget {
  final XFile videoFile;
  final FrameData frame;
  final List<Duration> photoTimestamps;

  const VideoRecapPlayer({
    super.key,
    required this.videoFile,
    required this.frame,
    required this.photoTimestamps,
  });

  @override
  State<VideoRecapPlayer> createState() => _VideoRecapPlayerState();
}

class _VideoRecapPlayerState extends State<VideoRecapPlayer> {
  RecapViewMode _viewMode = RecapViewMode.frame;
  
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
    _fullController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoFile.path))
        : VideoPlayerController.file(File(widget.videoFile.path));

    try {
      await _fullController.initialize();
      await _fullController.setLooping(true);
      if (mounted) {
        setState(() => _fullInitialized = true);
        _fullController.play();
      }
    } catch (e) {
      debugPrint('Error initializing full player: $e');
    }
  }

  Future<void> _initializeSlotPlayers() async {
    for (int i = 0; i < widget.frame.slots.length; i++) {
      final controller = kIsWeb
          ? VideoPlayerController.networkUrl(Uri.parse(widget.videoFile.path))
          : VideoPlayerController.file(File(widget.videoFile.path));
      
      _slotControllers.add(controller);
      _slotsInitialized.add(false);

      try {
        await controller.initialize();
        
        // Logic for 1s clip loop
        final endTime = i < widget.photoTimestamps.length 
            ? widget.photoTimestamps[i] 
            : controller.value.duration;
        final startTime = endTime > recapClipDuration 
            ? endTime - recapClipDuration 
            : Duration.zero;

        await controller.setVolume(0); // Mute slots to avoid echo
        await controller.seekTo(startTime);
        
        controller.addListener(() {
          if (controller.value.position >= endTime) {
            controller.seekTo(startTime);
          }
        });

        if (mounted) {
          setState(() => _slotsInitialized[i] = true);
          controller.play();
        }
      } catch (e) {
        debugPrint('Error initializing slot $i player: $e');
      }
    }
  }

  @override
  void dispose() {
    _fullController.dispose();
    for (var controller in _slotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Mode Switcher
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SegmentedButton<RecapViewMode>(
            segments: const [
              ButtonSegment(
                value: RecapViewMode.frame,
                label: Text('GẮN KHUNG'),
                icon: Icon(Icons.grid_view_rounded),
              ),
              ButtonSegment(
                value: RecapViewMode.full,
                label: Text('TOÀN BỘ'),
                icon: Icon(Icons.fullscreen_rounded),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (newSelection) {
              setState(() => _viewMode = newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: colorScheme.secondary,
              selectedForegroundColor: colorScheme.primary,
            ),
          ),
        ),
        
        // Video View Area
        Expanded(
          child: Center(
            child: _viewMode == RecapViewMode.full 
                ? _buildFullView() 
                : _buildFrameView(),
          ),
        ),
      ],
    );
  }

  Widget _buildFullView() {
    if (!_fullInitialized) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: _fullController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_fullController),
          _ControlsOverlay(controller: _fullController),
          VideoProgressIndicator(_fullController, allowScrubbing: true),
        ],
      ),
    );
  }

  Widget _buildFrameView() {
    return AspectRatio(
      aspectRatio: widget.frame.size.width / widget.frame.size.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaleX = constraints.maxWidth / widget.frame.size.width;
          final scaleY = constraints.maxHeight / widget.frame.size.height;

          return Stack(
            children: [
              // Slot Video Players
              for (int i = 0; i < widget.frame.slots.length; i++)
                Positioned(
                  left: widget.frame.slots[i].left * scaleX,
                  top: widget.frame.slots[i].top * scaleY,
                  width: widget.frame.slots[i].width * scaleX,
                  height: widget.frame.slots[i].height * scaleY,
                  child: Container(
                    color: Colors.black,
                    child: _slotsInitialized.length > i && _slotsInitialized[i]
                        ? ClipRRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _slotControllers[i].value.size.width,
                                height: _slotControllers[i].value.size.height,
                                child: VideoPlayer(_slotControllers[i]),
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
                  child: Image.asset(widget.frame.path, fit: BoxFit.fill),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 64.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
