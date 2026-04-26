import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/features/photobooth/photobooth_provider.dart';
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
            _DropdownSetting(
              label: 'Số ảnh',
              value: provider.selectedPhotoCount,
              items: provider.photoCounts,
              onChanged: (val) => provider.setPhotoCount(val!),
            ),
            const Gap(20),
            _DropdownSetting(
              label: 'Đếm Ngược',
              value: provider.countdown,
              items: provider.countdowns,
              onChanged: (val) => provider.setCountdown(val!),
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

class _DropdownSetting extends StatelessWidget {
  final String label;
  final dynamic value;
  final List<dynamic> items;
  final ValueChanged<dynamic> onChanged;
  final String suffix;

  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
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
            child: DropdownButton<dynamic>(
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
            return ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => provider.setFilter(filter),
              selectedColor: colorScheme.secondary,
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
