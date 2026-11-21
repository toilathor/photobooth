import 'package:material_ui/material_ui.dart';
import 'package:lottie/lottie.dart';

/// Plays the completion check once, then calls [onFinished] so the screen
/// moves on exactly when the animation ends, not after a guessed delay.
class CompletionCheckAnimation extends StatefulWidget {
  const CompletionCheckAnimation({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<CompletionCheckAnimation> createState() =>
      _CompletionCheckAnimationState();
}

class _CompletionCheckAnimationState extends State<CompletionCheckAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _finished = false;

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Lottie.asset(
          'assets/animations/completion-check.json',
          controller: _controller,
          width: 220,
          height: 220,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(_finish);
          },
          // Without the animation there is nothing to wait for.
          errorBuilder: (context, error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
