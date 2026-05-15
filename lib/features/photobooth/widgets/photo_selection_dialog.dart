import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_photobooth/i18n/strings.g.dart';

class PhotoSelectionDialog extends StatefulWidget {
  final List<XFile> photos;
  final int targetCount;
  final bool isMirrored;

  const PhotoSelectionDialog({
    super.key,
    required this.photos,
    required this.targetCount,
    this.isMirrored = false,
  });

  @override
  State<PhotoSelectionDialog> createState() => _PhotoSelectionDialogState();
}

class _PhotoSelectionDialogState extends State<PhotoSelectionDialog> {
  final List<XFile> _selected = [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(t.dialogs.photoSelection.title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.dialogs.photoSelection.subtitle(count: widget.targetCount),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Gap(16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: widget.photos.length,
                itemBuilder: (context, index) {
                  final photo = widget.photos[index];
                  final isSelected = _selected.contains(photo);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(photo);
                        } else if (_selected.length < widget.targetCount) {
                          _selected.add(photo);
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Transform.scale(
                              scaleX: widget.isMirrored ? -1 : 1,
                              child: kIsWeb
                                  ? Image.network(photo.path, fit: BoxFit.cover)
                                  : Image.file(
                                      File(photo.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: colorScheme.secondary.withValues(
                                  alpha: 0.3,
                                ),
                                border: Border.all(
                                  color: colorScheme.secondary,
                                  width: 3,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurface.withValues(alpha: 0.8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  t.dialogs.photoSelection.cancel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(8),
              FilledButton.icon(
                onPressed: _selected.length == widget.targetCount
                    ? () => Navigator.pop(context, _selected)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  disabledBackgroundColor: colorScheme.secondary.withValues(
                    alpha: 0.2,
                  ),
                  disabledForegroundColor: colorScheme.onSecondary.withValues(
                    alpha: 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  '${t.dialogs.photoSelection.confirm} (${_selected.length}/${widget.targetCount})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
