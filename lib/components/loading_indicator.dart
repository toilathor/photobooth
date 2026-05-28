import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 64,
      height: 64,
      child: CircularProgressIndicator(
        strokeWidth: 6,
        strokeCap: StrokeCap.round,
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
      ),
    );
  }
}
