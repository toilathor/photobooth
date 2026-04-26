import 'package:flutter_test/flutter_test.dart';
import 'package:my_photobooth/features/photobooth/photobooth_provider.dart';
import 'package:my_photobooth/helper/constants.dart';

void main() {
  setUp(() {
    cameras = []; // Initialize cameras to empty list for testing
  });

  group('PhotoboothProvider Tests', () {
    test('Initial state should be correct', () {
      final provider = PhotoboothProvider();
      expect(provider.countdown, 3);
      expect(provider.capturedPhotos, isEmpty);
      expect(provider.isVideoRecap, isFalse);
      expect(provider.selectedFilter, '');
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
    });

    test('setFilter should update selectedFilter', () {
      final provider = PhotoboothProvider();
      provider.setFilter('Mono (Retro Effect)');
      expect(provider.selectedFilter, 'Mono (Retro Effect)');
    });
  });
}
