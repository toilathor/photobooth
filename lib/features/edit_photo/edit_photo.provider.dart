import 'package:flutter/material.dart';

class FrameData {
  final String path;
  final int photoSlots;

  const FrameData({required this.path, required this.photoSlots});
}

class EditPhotoProvider with ChangeNotifier {
  bool isProcessing = false;
  String? selectedFilter;
  List<StickerItem> stickers = [];

  final List<FrameData> allFrames = [
    const FrameData(path: 'assets/frames/frame2.png', photoSlots: 3),
    const FrameData(path: 'assets/frames/frame1.png', photoSlots: 1),
    const FrameData(path: 'assets/frames/frame.png', photoSlots: 4),
    // Duplicates for demonstration
    const FrameData(path: 'assets/frames/frame2.png', photoSlots: 3),
    const FrameData(path: 'assets/frames/frame1.png', photoSlots: 1),
    const FrameData(path: 'assets/frames/frame.png', photoSlots: 4),
  ];

  List<FrameData> filteredFrames = [];
  late FrameData selectedFrame;
  bool printTwoCopies = false;

  EditPhotoProvider() {
    filteredFrames = allFrames;
    selectedFrame = allFrames.first;
  }

  void initForPhotoCount(int count) {
    filteredFrames = allFrames.where((f) => f.photoSlots == count).toList();
    if (filteredFrames.isNotEmpty) {
      selectedFrame = filteredFrames.first;
    }
    notifyListeners();
  }

  void setSelectedFrame(FrameData frame) {
    selectedFrame = frame;
    notifyListeners();
  }

  void togglePrintTwoCopies(bool value) {
    printTwoCopies = value;
    notifyListeners();
  }

  void setProcessing(bool value) {
    isProcessing = value;
    notifyListeners();
  }

  void addSticker(String assetPath, Offset position) {
    stickers.add(StickerItem(assetPath: assetPath, position: position));
    notifyListeners();
  }

  void updateStickerPosition(int index, Offset newPosition) {
    if (index >= 0 && index < stickers.length) {
      stickers[index] = stickers[index].copyWith(position: newPosition);
      notifyListeners();
    }
  }

  void removeSticker(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers.removeAt(index);
      notifyListeners();
    }
  }

  void clearStickers() {
    stickers.clear();
    notifyListeners();
  }
}

class StickerItem {
  final String assetPath;
  final Offset position;
  final double scale;
  final double rotation;

  StickerItem({
    required this.assetPath,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  StickerItem copyWith({
    String? assetPath,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return StickerItem(
      assetPath: assetPath ?? this.assetPath,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}
