import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:provider/provider.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cài đặt'.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.secondary,
                letterSpacing: 2,
              ),
            ),
            const Gap(16),
            _DropdownSetting<int>(
              label: 'Số ảnh',
              value: provider.selectedPhotoCount,
              items: provider.photoCounts,
              onChanged: provider.isCapturing ? null : (val) {
                final newCount = val as int;
                if (provider.capturedPhotos.length > newCount) {
                  // Show selection dialog
                  showDialog<List<XFile>>(
                    context: context,
                    builder: (context) => _PhotoSelectionDialog(
                      photos: provider.capturedPhotos,
                      targetCount: newCount,
                    ),
                  ).then((selectedPhotos) {
                    if (selectedPhotos != null) {
                      provider.setPhotoCountWithSelection(newCount, selectedPhotos);
                    }
                  });
                } else {
                  provider.setPhotoCount(newCount);
                }
              },
            ),
            const Gap(20),
            _DropdownSetting<int>(
              label: 'Đếm Ngược',
              value: provider.countdown,
              items: provider.countdowns,
              onChanged: provider.isCapturing ? null : (val) => provider.setCountdown(val as int),
              suffix: ' giây',
            ),
            const Gap(24),
            const Divider(),
            const Gap(24),
            _Filters(provider: provider, colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

class _PhotoSelectionDialog extends StatefulWidget {
  final List<XFile> photos;
  final int targetCount;

  const _PhotoSelectionDialog({
    required this.photos,
    required this.targetCount,
  });

  @override
  State<_PhotoSelectionDialog> createState() => _PhotoSelectionDialogState();
}

class _PhotoSelectionDialogState extends State<_PhotoSelectionDialog> {
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

class _DropdownSetting<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String suffix;

  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.onPrimary,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map(
                    (e) => DropdownMenuItem(value: e, child: Text('$e$suffix')),
                  )
                  .toList(),
              onChanged: onChanged,
              isExpanded: true,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  final PhotoboothProvider provider;
  final ColorScheme colorScheme;

  const _Filters({required this.provider, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bộ lọc màu',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.filters.map((filter) {
            final isSelected = provider.selectedFilter == filter;
            return FilterChip(
              label: Text(filter),
              selected: provider.selectedFilter == filter,
              onSelected: provider.isCapturing 
                  ? null 
                  : (selected) {
                      if (selected) provider.setFilter(filter);
                    },
              selectedColor: colorScheme.secondary.withValues(alpha: 0.2),
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
