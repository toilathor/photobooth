import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const SecondaryButton({
    super.key,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Icon(icon, color: colorScheme.onSurface, size: 28),
          ),
        ),
      ),
    );
  }
}
