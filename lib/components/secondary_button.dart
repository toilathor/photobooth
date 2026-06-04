import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double height;

  const SecondaryButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.height = 72,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Icon(
              icon,
              color: colorScheme.onSurface,
              size: height > 60 ? 28 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
