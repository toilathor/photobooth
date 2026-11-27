import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/core/configs/app_config.dart';

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
    final Size print = AppConfig.printPixelSize;
    final double paperAspectRatio = isLandscape
        ? print.height / print.width
        : print.width / print.height;

    return AspectRatio(
      aspectRatio: paperAspectRatio,
      child: ClipRect(
        child: FittedBox(fit: BoxFit.cover, child: child),
      ),
    );
  }
}
