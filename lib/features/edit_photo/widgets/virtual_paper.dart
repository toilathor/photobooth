import 'package:flutter/material.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class VirtualPaper extends StatelessWidget {
  final Widget child;
  final bool isLandscape;

  const VirtualPaper({
    super.key,
    required this.child,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    // KP-108IN is 100mm x 148mm (4x6 inch)
    final double paperAspectRatio = isLandscape ? 148 / 100 : 100 / 148;

    return AspectRatio(
      aspectRatio: paperAspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double longSide = isLandscape
              ? constraints.maxWidth
              : constraints.maxHeight;
          // Perforation margin is ~10mm out of 148mm (approx 6.75%)
          final double perforationGap = longSide * 0.0675;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Perforation Lines
                if (!isLandscape) ...[
                  Positioned(
                    top: perforationGap,
                    left: 0,
                    right: 0,
                    child: const _DashedLine(isVertical: false),
                  ),
                  Positioned(
                    bottom: perforationGap,
                    left: 0,
                    right: 0,
                    child: const _DashedLine(isVertical: false),
                  ),
                ] else ...[
                  Positioned(
                    left: perforationGap,
                    top: 0,
                    bottom: 0,
                    child: const _DashedLine(isVertical: true),
                  ),
                  Positioned(
                    right: perforationGap,
                    top: 0,
                    bottom: 0,
                    child: const _DashedLine(isVertical: true),
                  ),
                ],
                // The actual content (photo strips)
                Padding(
                  padding: isLandscape
                      ? EdgeInsets.symmetric(
                          horizontal: perforationGap + 2,
                          vertical: 2,
                        )
                      : EdgeInsets.symmetric(
                          vertical: perforationGap + 2,
                          horizontal: 2,
                        ),
                  child: Center(
                    child: FittedBox(fit: BoxFit.contain, child: child),
                  ),
                ),
                // Paper size indicator (Placed in the perforation margin area)
                if (isLandscape)
                  Positioned(
                    left: 8,
                    top: 8,
                    right: 8,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'CANON KP-108IN (4x6") - ${t.preview.landscape}',
                        style: TextStyle(
                          fontSize: constraints.maxHeight * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withValues(alpha: 0.1),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      'CANON KP-108IN (4x6") - ${t.preview.portrait}',
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.02,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.1),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final bool isVertical;
  const _DashedLine({required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: isVertical ? Axis.vertical : Axis.horizontal,
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            width: isVertical ? 0.5 : null,
            height: isVertical ? null : 0.5,
            margin: isVertical
                ? const EdgeInsets.symmetric(vertical: 2)
                : const EdgeInsets.symmetric(horizontal: 2),
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}
