import 'package:flutter/material.dart';
import 'package:th_photobooth/core/configs/google_drive_config.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/models/gallery_file.dart';
import 'package:video_player/video_player.dart';

class GalleryLightbox extends StatefulWidget {
  final List<GalleryFile> files;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const GalleryLightbox({
    super.key,
    required this.files,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<GalleryLightbox> {
  late final PageController _controller = PageController(
    initialPage: widget.selectedIndex,
  );

  @override
  void didUpdateWidget(covariant GalleryLightbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex ||
        !_controller.hasClients) {
      return;
    }
    if ((_controller.page ?? _controller.initialPage).round() ==
        widget.selectedIndex) {
      return;
    }
    _controller.animateToPage(
      widget.selectedIndex,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final thumbnailHeight = MediaQuery.sizeOf(context).width < 600
        ? 88.0
        : 112.0;
    final selectedFile = widget.files[widget.selectedIndex];

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: ColoredBox(
              color: Colors.black,
              child: Stack(
                children: [
                  PageView.builder(
                    key: const ValueKey('gallery-lightbox'),
                    controller: _controller,
                    itemCount: widget.files.length,
                    onPageChanged: widget.onSelected,
                    itemBuilder: (context, index) => _GalleryMedia(
                      key: ValueKey(widget.files[index].id),
                      file: widget.files[index],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedFile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              shadows: [Shadow(blurRadius: 8)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.selectedIndex + 1}/${widget.files.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            shadows: [Shadow(blurRadius: 8)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.selectedIndex > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filled(
                        tooltip: t.gallery.previous,
                        onPressed: () =>
                            widget.onSelected(widget.selectedIndex - 1),
                        icon: const Icon(Icons.chevron_left_rounded),
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(48),
                          backgroundColor: Colors.black45,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (widget.selectedIndex < widget.files.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton.filled(
                        tooltip: t.gallery.next,
                        onPressed: () =>
                            widget.onSelected(widget.selectedIndex + 1),
                        icon: const Icon(Icons.chevron_right_rounded),
                        style: IconButton.styleFrom(
                          minimumSize: const Size.square(48),
                          backgroundColor: Colors.black45,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: thumbnailHeight,
          child: ListView.separated(
            key: const ValueKey('gallery-thumbnail-list'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: widget.files.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final file = widget.files[index];
              final isSelected = index == widget.selectedIndex;
              return Semantics(
                button: true,
                selected: isSelected,
                label: t.gallery.openFile(name: file.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: thumbnailHeight * 1.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.secondary
                          : colorScheme.outlineVariant,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: colorScheme.surfaceContainerHighest,
                    child: InkWell(
                      onTap: () => widget.onSelected(index),
                      child: _GalleryThumbnail(file: file),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GalleryThumbnail extends StatelessWidget {
  final GalleryFile file;

  const _GalleryThumbnail({required this.file});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (file.thumbnailLink != null)
          Image.network(
            file.thumbnailLink!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _GalleryFileIcon(file: file),
          )
        else
          _GalleryFileIcon(file: file),
        if (file.isVideo)
          const Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 34,
              shadows: [Shadow(blurRadius: 8)],
            ),
          ),
      ],
    );
  }
}

class _GalleryFileIcon extends StatelessWidget {
  final GalleryFile file;

  const _GalleryFileIcon({required this.file});

  @override
  Widget build(BuildContext context) => Center(
    child: Icon(
      file.isVideo ? Icons.videocam_rounded : Icons.image_rounded,
      size: 42,
      color: Theme.of(context).colorScheme.secondary,
    ),
  );
}

class _GalleryMedia extends StatelessWidget {
  final GalleryFile file;

  const _GalleryMedia({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    if (file.isVideo) return _GalleryVideo(file: file);

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Image.network(
          file.contentUrl(GoogleDriveConfig.apiKey),
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, _, _) => const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white70,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryVideo extends StatefulWidget {
  final GalleryFile file;

  const _GalleryVideo({required this.file});

  @override
  State<_GalleryVideo> createState() => _GalleryVideoState();
}

class _GalleryVideoState extends State<_GalleryVideo> {
  late final VideoPlayerController _controller =
      VideoPlayerController.networkUrl(
        Uri.parse(widget.file.contentUrl(GoogleDriveConfig.apiKey)),
      );
  late final Future<void> _initialization = _controller.initialize();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Icon(
              Icons.videocam_off_rounded,
              color: Colors.white70,
              size: 64,
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                IconButton.filled(
                  tooltip: _controller.value.isPlaying
                      ? t.gallery.pause
                      : t.gallery.play,
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(64),
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
