import 'package:flutter/material.dart';
import 'package:th_photobooth/core/configs/app_config.dart';

class FrameData {
  final String filename;
  final int photoSlots;
  final Size size;
  final List<Rect> slots;
  final String categoryId;
  final String categoryName;

  const FrameData({
    this.filename = '',
    required this.photoSlots,
    this.size = Size.zero,
    this.slots = const [],
    this.categoryId = '',
    this.categoryName = '',
  });

  /// Factory for standard frames (4 slots)
  factory FrameData.standard({
    String filename = '',
    String categoryId = '',
    String categoryName = '',
  }) {
    return FrameData(
      filename: filename,
      photoSlots: 4,
      size: const Size(880, 2650),
      slots: const [
        Rect.fromLTWH(40, 40, 800, 600),
        Rect.fromLTWH(40, 660, 800, 600),
        Rect.fromLTWH(40, 1280, 800, 600),
        Rect.fromLTWH(40, 1900, 800, 600),
      ],
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  /// Factory for group frames (1 slot)
  factory FrameData.group({
    String filename = '',
    String categoryId = '',
    String categoryName = '',
  }) {
    return FrameData(
      filename: filename,
      photoSlots: 1,
      size: const Size(2800, 2000),
      slots: const [Rect.fromLTWH(350, 212, 2100, 1575)],
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  /// Check if the frame layout is for a group shot (1 slot)
  bool get isGroup => photoSlots == 1;

  /// Check if this is a custom frame designed by the user
  bool get isCustom =>
      filename.startsWith('standard_custom_') ||
      filename.startsWith('group_custom_');

  /// Dynamic getter to resolve the local or network asset path
  String get path {
    if (filename.isEmpty) return '';

    if (filename.startsWith('standard_custom_')) {
      return 'https://raw.githubusercontent.com/toilathor/photobooth/master/assets/frames/custom/standard/$filename';
    } else if (filename.startsWith('group_custom_')) {
      return 'https://raw.githubusercontent.com/toilathor/photobooth/master/assets/frames/custom/group/$filename';
    } else {
      return '${AppConfig.githubFramesBaseUrl}$filename';
    }
  }
}
