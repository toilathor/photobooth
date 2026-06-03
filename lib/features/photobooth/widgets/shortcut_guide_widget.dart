import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class ShortcutGuideWidget extends StatefulWidget {
  const ShortcutGuideWidget({super.key});

  @override
  State<ShortcutGuideWidget> createState() => _ShortcutGuideWidgetState();
}

class _ShortcutGuideWidgetState extends State<ShortcutGuideWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Only show on desktop web
    if (!kIsWeb) return const SizedBox.shrink();

    final bool isMobile =
        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP) ||
        MediaQuery.sizeOf(context).height < 500;

    if (isMobile) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = false),
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        Positioned(
          bottom: 24,
          left: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded) ...[_buildGuideCard(colorScheme), const Gap(12)],
              _buildFloatingButton(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: _isExpanded
                ? colorScheme.primary.withValues(alpha: 0.9)
                : colorScheme.surface.withValues(alpha: 0.8),
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isExpanded
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.secondary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.keyboard_alt_outlined,
                  color: _isExpanded ? Colors.white : colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(ColorScheme colorScheme) {
    return Material(
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.keyboard_command_key_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const Gap(8),
                      Text(
                        t.shortcuts.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    t.shortcuts.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Gap(16),
                  const Divider(height: 1),
                  const Gap(12),
                  _buildShortcutRow(
                    context,
                    'Space',
                    t.shortcuts.space,
                    isWideKey: true,
                  ),
                  _buildShortcutRow(context, 'S', t.shortcuts.key_s),
                  _buildShortcutRow(context, 'M', t.shortcuts.key_m),
                  _buildShortcutRow(context, 'V', t.shortcuts.key_v),
                  _buildShortcutRow(context, 'R', t.shortcuts.key_r),
                  _buildShortcutRow(context, 'F', t.shortcuts.key_f),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutRow(
    BuildContext context,
    String key,
    String label, {
    bool isWideKey = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Keycap container
          Container(
            constraints: BoxConstraints(minWidth: isWideKey ? 64 : 32),
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              key,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
