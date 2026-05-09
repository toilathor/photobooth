import 'package:flutter/material.dart';

class FrameData {
  final String path;
  final int photoSlots;
  final Size size;
  final List<Rect> slots;

  const FrameData({
    required this.path,
    required this.photoSlots,
    this.size = Size.zero,
    this.slots = const [],
  });
}
