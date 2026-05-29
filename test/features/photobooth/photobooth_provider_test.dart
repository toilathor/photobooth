import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/features/photobooth/providers/photobooth.provider.dart';
import 'package:th_photobooth/core/configs/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.cameras = []; // Initialize cameras to empty list for testing
  });

  group('PhotoboothProvider Tests', () {
    test('Initial state should be correct', () {
      final provider = PhotoboothProvider();
      expect(provider.countdown, 4);
      expect(provider.capturedPhotos, isEmpty);
      expect(provider.isVideoRecap, isTrue); // Default is true now
    });

    test('setCountdown should update countdown', () {
      final provider = PhotoboothProvider();
      provider.setCountdown(5);
      expect(provider.countdown, 5);
    });

    test('toggleVideoRecap should update isVideoRecap', () {
      final provider = PhotoboothProvider();
      provider.toggleVideoRecap(true);
      expect(provider.isVideoRecap, isTrue);

      provider.toggleVideoRecap(false);
      expect(provider.isVideoRecap, isFalse);
    });
  });
}
