import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/core/configs/app_config.dart';

void main() {
  test('uses the RX1HS high-quality 4x6 raster size', () {
    expect(AppConfig.printPixelSize.width, 2400);
    expect(AppConfig.printPixelSize.height, 3600);
  });
}
