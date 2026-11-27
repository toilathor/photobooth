import 'package:flutter_test/flutter_test.dart';
import 'package:th_photobooth/core/configs/app_config.dart';

void main() {
  test('uses 10.5x15.61 cm (6x4 print ratio) at 600 dpi', () {
    expect(AppConfig.printPixelSize.width, 2480);
    expect(AppConfig.printPixelSize.height, 3688);
  });
}
