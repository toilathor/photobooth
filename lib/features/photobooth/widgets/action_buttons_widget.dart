import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoboothProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionIcon(
            icon: Icons.refresh_rounded,
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
                !provider.isAutoCapturing && provider.capturedPhotos.isNotEmpty,
          ),
          Gap(isMobile ? 16 : 32),
          _ActionIcon(
            icon: Icons.camera_alt_rounded,
            label: t.actions.auto,
            colorScheme: colorScheme,
            isPrimary: true,
            onTap: provider.startAutoCapture,
            isEnabled: !provider.isAutoCapturing,
          ),
          Gap(isMobile ? 16 : 32),
          _ActionIcon(
            icon: Icons.touch_app_rounded,
            label: t.actions.manual,
            colorScheme: colorScheme,
            onTap: provider.takeManualPhoto,
            isEnabled:
                !provider.isAutoCapturing &&
                provider.capturedPhotos.length < provider.selectedPhotoCount,
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
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
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 850;
    final double outerSize = widget.isPrimary
        ? (isMobile ? 72 : 84)
        : (isMobile ? 54 : 64);
    final double innerSize = widget.isPrimary
        ? (isMobile ? 60 : 70)
        : (isMobile ? 42 : 50);
    final double iconSize = widget.isPrimary
        ? (isMobile ? 28 : 36)
        : (isMobile ? 20 : 24);
    final bool useGradient = widget.isPrimary;
    final Color lighterSecondary =
        Color.lerp(widget.colorScheme.secondary, Colors.white, 0.4) ?? Colors.white;

    return Opacity(
      opacity: widget.isEnabled ? 1.0 : 0.4,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isEnabled ? widget.onTap : null,
              onHighlightChanged: (isHighlighted) {
                if (widget.isEnabled) {
                  setState(() {
                    _isPressed = isHighlighted;
                  });
                }
              },
              customBorder: const CircleBorder(),
              splashColor:
                  (useGradient ? widget.colorScheme.secondary : widget.colorScheme.onSurface)
                      .withValues(alpha: 0.3),
              highlightColor:
                  (useGradient ? widget.colorScheme.secondary : widget.colorScheme.onSurface)
                      .withValues(alpha: 0.1),
              child: AnimatedScale(
                scale: _isPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: outerSize,
                  height: outerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          (useGradient
                                  ? widget.colorScheme.secondary
                                  : widget.colorScheme.onSurface)
                              .withValues(alpha: widget.isPrimary ? 0.6 : 0.2),
                      width: 1,
                    ),
                    boxShadow: widget.isPrimary && widget.isEnabled
                        ? [
                            BoxShadow(
                              color: widget.colorScheme.secondary.withValues(alpha: 0.3),
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
                        gradient: useGradient
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.colorScheme.secondary,
                                  lighterSecondary,
                                  widget.colorScheme.secondary,
                                ],
                              )
                            : null,
                        color: useGradient
                            ? null
                            : widget.colorScheme.onSurface.withValues(alpha: 0.1),
                        border: widget.isPrimary
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.5,
                              )
                            : Border.all(
                                color: widget.colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                      ),
                      child: Icon(
                        widget.icon,
                        size: iconSize,
                        color: widget.isPrimary
                            ? widget.colorScheme.onSecondary
                            : widget.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(12),
          Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: widget.isPrimary ? (isMobile ? 12 : 14) : (isMobile ? 10 : 12),
              fontWeight: FontWeight.w800,
              color: widget.isPrimary ? widget.colorScheme.secondary : widget.colorScheme.onSurface,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
