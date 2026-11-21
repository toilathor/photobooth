import 'package:material_ui/material_ui.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Keys the booth binds, each with its own glyph in [ShortcutKeycap].
enum ShortcutKey { enter, escape, space, r }

/// A small keycap telling which key triggers the button it sits in.
///
/// One family for every key: the same rounded cap, a 1.4px round-capped
/// stroke on a 12px grid, all in the button's own text colour, kept quiet with
/// low opacity so the label stays the first thing read. Shown on desktop
/// layouts only, where a keyboard is at hand.
class ShortcutKeycap extends StatelessWidget {
  const ShortcutKeycap(this.shortcut, {super.key, required this.color});

  final ShortcutKey shortcut;

  /// The colour of the text next to it; the cap derives its tones from it.
  final Color color;

  /// Whether this layout shows keycaps (desktop size, not a phone in landscape).
  static bool isShown(BuildContext context) =>
      ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP) &&
      MediaQuery.sizeOf(context).height >= 500;

  @override
  Widget build(BuildContext context) {
    if (!isShown(context)) return const SizedBox.shrink();
    final ink = color.withValues(alpha: 0.75);
    return ExcludeSemantics(
      child: Container(
        height: 20,
        constraints: const BoxConstraints(minWidth: 22),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: shortcut == ShortcutKey.r
            ? Text(
                'R',
                style: TextStyle(
                  color: ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              )
            : CustomPaint(
                size: const Size.square(12),
                painter: _GlyphPainter(shortcut, ink),
              ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.shortcut, this.color);

  final ShortcutKey shortcut;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 12; // drawn on a 12×12 grid
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Offset p(double x, double y) => Offset(x * s, y * s);

    switch (shortcut) {
      case ShortcutKey.enter: // ⏎ down then left, arrow pointing back
        canvas.drawPath(
          Path()
            ..moveTo(10 * s, 2 * s)
            ..lineTo(10 * s, 7 * s)
            ..lineTo(2.5 * s, 7 * s)
            ..moveTo(5 * s, 4.5 * s)
            ..lineTo(2.5 * s, 7 * s)
            ..lineTo(5 * s, 9.5 * s),
          paint,
        );
      case ShortcutKey.escape: // ⎋ open circle with an arrow leaving it
        canvas.drawArc(
          Rect.fromCircle(center: p(6.5, 6.5), radius: 4.2 * s),
          -1.6, // leaves a gap at the top-left for the arrow
          4.78,
          false,
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(6.5 * s, 6.5 * s)
            ..lineTo(1.5 * s, 1.5 * s)
            ..moveTo(1.5 * s, 4.5 * s)
            ..lineTo(1.5 * s, 1.5 * s)
            ..lineTo(4.5 * s, 1.5 * s),
          paint,
        );
      case ShortcutKey.space: // ␣ open bracket
        canvas.drawPath(
          Path()
            ..moveTo(1.5 * s, 6 * s)
            ..lineTo(1.5 * s, 9 * s)
            ..lineTo(10.5 * s, 9 * s)
            ..lineTo(10.5 * s, 6 * s),
          paint,
        );
      case ShortcutKey.r:
        break; // drawn as text
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.shortcut != shortcut || old.color != color;
}
