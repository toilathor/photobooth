import 'package:flutter/material.dart';

class CustomScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final EdgeInsets? padding;
  final double thickness;
  final Radius radius;
  final bool thumbVisibility;
  final bool trackVisibility;
  final Color? thumbColor;
  final Color? trackColor;

  const CustomScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.padding,
    this.thickness = 3.0,
    this.radius = const Radius.circular(10.0),
    this.thumbVisibility = true,
    this.trackVisibility = true,
    this.thumbColor,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveThumbColor =
        thumbColor ?? colorScheme.onSurface.withValues(alpha: 0.25);
    final effectiveTrackColor =
        trackColor ?? colorScheme.onSurface.withValues(alpha: 0.04);

    return RawScrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      thickness: thickness,
      radius: radius,
      thumbColor: effectiveThumbColor,
      trackColor: effectiveTrackColor,
      trackRadius: radius,
      padding: padding,
      child: child,
    );
  }
}
