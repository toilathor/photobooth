import 'package:material_ui/material_ui.dart';

/// Hops its child a few times when it becomes [active], to point the guest at
/// the next step of the flow. Still when animations are turned off.
class NudgeBounce extends StatefulWidget {
  const NudgeBounce({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<NudgeBounce> createState() => _NudgeBounceState();
}

class _NudgeBounceState extends State<NudgeBounce>
    with SingleTickerProviderStateMixin {
  // One hop then a rest, so it reads as a hint rather than an alarm.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: -8.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 10,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: -8.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.bounceOut)),
      weight: 20,
    ),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 70),
  ]).animate(_controller);

  bool _hopped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(NudgeBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.active && !MediaQuery.disableAnimationsOf(context)) {
      // A few hops then rest: a looping motion would keep pulling the eye
      // (and the guest has already seen where to go).
      if (!_controller.isAnimating && !_hopped) {
        _hopped = true;
        _controller.repeat(count: 3);
      }
    } else {
      _hopped = false; // hint again next time the step becomes available
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      child: widget.child,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _offset.value), child: child),
    );
  }
}
