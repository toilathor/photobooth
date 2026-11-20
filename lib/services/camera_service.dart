import 'package:camera/camera.dart';

/// Owns CameraController creation and disposal so providers do not depend on
/// plugin construction details.
class CameraService {
  CameraController? controller;

  CameraController createController({
    required CameraDescription description,
    required ResolutionPreset resolution,
  }) {
    final created = CameraController(
      description,
      resolution,
      enableAudio: false,
    );
    controller = created;
    return created;
  }

  Future<void> disposeController(CameraController? value) async {
    if (identical(controller, value)) controller = null;
    await value?.dispose();
  }

  Future<void> dispose() async {
    final current = controller;
    controller = null;
    await current?.dispose();
  }
}
