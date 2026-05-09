import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_photobooth/features/photobooth/photobooth.provider.dart';
import 'package:my_photobooth/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionIcon(
              icon: Icons.touch_app,
              label: t.actions.manual,
              colorScheme: colorScheme,
              onTap: provider.takeManualPhoto,
              isEnabled:
                  !provider.isAutoCapturing &&
                  provider.capturedPhotos.length < provider.selectedPhotoCount,
            ),
            const Gap(32),
            _ActionIcon(
              icon: Icons.camera_alt,
              label: t.actions.auto,
              colorScheme: colorScheme,
              isPrimary: true,
              onTap: provider.startAutoCapture,
              isEnabled: !provider.isAutoCapturing,
            ),
            const Gap(32),
            _ActionIcon(
              icon: Icons.refresh,
              label: t.actions.retake,
              colorScheme: colorScheme,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(t.dialogs.resetSession.title),
                    content: Text(t.dialogs.resetSession.content),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        child: Text(t.dialogs.resetSession.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                        ),
                        child: Text(t.dialogs.resetSession.confirm),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await provider.clearSession();
                }
              },
              isEnabled:
                  !provider.isAutoCapturing &&
                  provider.capturedPhotos.isNotEmpty,
            ),
          ],
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: provider.isVideoRecap,
              onChanged: provider.isAutoCapturing
                  ? null
                  : provider.toggleVideoRecap,
              activeThumbColor: colorScheme.secondary,
            ),
            Text(
              t.actions.videoRecap,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final bool isPrimary;
  final VoidCallback? onTap;

  final bool isEnabled;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.colorScheme,
    this.isPrimary = false,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final double outerSize = isPrimary ? 84 : 64;
    final double innerSize = isPrimary ? 70 : 50;
    final double iconSize = isPrimary ? 36 : 24;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onTap : null,
              customBorder: const CircleBorder(),
              splashColor: colorScheme.secondary.withValues(alpha: 0.3),
              highlightColor: colorScheme.secondary.withValues(alpha: 0.1),
              child: Container(
                width: outerSize,
                height: outerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.secondary.withValues(
                      alpha: isPrimary ? 0.6 : 0.3,
                    ),
                    width: 1,
                  ),
                  boxShadow: isPrimary && isEnabled
                      ? [
                          BoxShadow(
                            color: colorScheme.secondary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Container(
                    width: innerSize,
                    height: innerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isPrimary
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.secondary,
                                const Color(0xFFFFE57F), // Lighter Gold
                                colorScheme.secondary,
                              ],
                            )
                          : null,
                      color: isPrimary
                          ? null
                          : colorScheme.onSurface.withValues(alpha: 0.1),
                      border: isPrimary
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            )
                          : Border.all(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: isPrimary
                          ? colorScheme.primary
                          : colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(12),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: isPrimary ? 14 : 12,
              fontWeight: FontWeight.w800,
              color: isPrimary ? colorScheme.secondary : colorScheme.onSurface,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
