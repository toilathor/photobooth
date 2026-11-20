import 'package:flutter/foundation.dart';
import 'package:th_photobooth/models/gallery_file.dart';
import 'package:th_photobooth/services/gallery_service.dart';

class GalleryProvider extends ChangeNotifier {
  final GalleryService _service;
  final bool _ownsService;
  bool _isDisposed = false;

  GalleryProvider({GalleryService? service})
    : _service = service ?? GalleryService(),
      _ownsService = service == null;

  bool isLoading = true;
  Object? error;
  List<GalleryFile> files = const [];
  int selectedIndex = 0;

  Future<void> load(String sectionId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      if (sectionId.isEmpty) throw ArgumentError('Invalid gallery section');
      files = (await _service.listFiles(sectionId))
          .where((file) => file.isMedia)
          .toList(growable: false);
      selectedIndex = 0;
    } catch (exception) {
      error = exception;
      files = const [];
    } finally {
      isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void select(int index) {
    if (_isDisposed ||
        index < 0 ||
        index >= files.length ||
        index == selectedIndex) {
      return;
    }
    selectedIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_ownsService) _service.close();
    super.dispose();
  }
}
