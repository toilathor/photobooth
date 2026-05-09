import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';

class FilterConfig {
  static ColorFilterGenerator getFilter(String key) {
    if (key == 'normal') return PresetFilters.none;
    return presetFiltersList.firstWhere(
      (filter) => _getKey(filter.name) == key,
      orElse: () => PresetFilters.none,
    );
  }

  static String _getKey(String name) {
    return name.toLowerCase().replaceAll(' ', '_').replaceAll('-', '');
  }

  static List<double> getFilterMatrix(String key, double intensity) {
    if (key == 'normal' || intensity == 0.0) {
      return [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    }

    final filterMatrix = getFilter(key).matrix;
    if (intensity == 1.0) {
      return filterMatrix;
    }

    final identityMatrix = [
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
    ];

    final result = List<double>.filled(20, 0);
    for (int i = 0; i < 20; i++) {
      result[i] =
          identityMatrix[i] + (filterMatrix[i] - identityMatrix[i]) * intensity;
    }
    return result;
  }

  static List<String> get availableFilters {
    return [
      'normal',
      ...presetFiltersList
          .where((f) => f.name != 'No Filter')
          .map((f) => _getKey(f.name)),
    ];
  }
}
