import 'package:material_ui/material_ui.dart';

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
    final double paperAspectRatio = isLandscape ? 3 / 2 : 2 / 3;

    return AspectRatio(
      aspectRatio: paperAspectRatio,
      child: ClipRect(
        child: FittedBox(fit: BoxFit.cover, child: child),
      ),
    );
  }
}
