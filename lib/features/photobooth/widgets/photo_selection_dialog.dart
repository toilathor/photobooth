import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PhotoSelectionDialog extends StatefulWidget {
  final List<XFile> photos;
  final int targetCount;

  const PhotoSelectionDialog({
    super.key,
    required this.photos,
    required this.targetCount,
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
      title: const Text('Chọn ảnh muốn giữ lại'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vui lòng chọn đúng ${widget.targetCount} ảnh để tiếp tục.',
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
                            child: kIsWeb
                                ? Image.network(photo.path, fit: BoxFit.cover)
                                : Image.file(
                                    File(photo.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: colorScheme.secondary
                                    .withValues(alpha: 0.3),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('HỦY'),
              ),
              const Gap(8),
              FilledButton.icon(
                onPressed: _selected.length == widget.targetCount
                    ? () => Navigator.pop(context, _selected)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  'XÁC NHẬN (${_selected.length}/${widget.targetCount})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
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
