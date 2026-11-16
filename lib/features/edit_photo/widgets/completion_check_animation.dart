import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CompletionCheckAnimation extends StatelessWidget {
  const CompletionCheckAnimation({super.key});

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
          width: 220,
          height: 220,
          repeat: false,
        ),
      ),
    );
  }
}
