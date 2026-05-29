import 'package:flutter/material.dart';
import 'package:th_photobooth/models/frame_data.dart';

class FrameConfig {
  static const List<FrameData> allFrames = [
    FrameData(
      path: 'assets/frames/frame1.png',
      photoSlots: 1,
      size: Size(2800, 2000),
      slots: [Rect.fromLTWH(350, 212, 2100, 1575)],
    ),
    FrameData(
      path: '',
      photoSlots: 4,
      size: Size(880, 2650),
      slots: [
        Rect.fromLTWH(40, 40, 800, 600),
        Rect.fromLTWH(40, 660, 800, 600),
        Rect.fromLTWH(40, 1280, 800, 600),
        Rect.fromLTWH(40, 1900, 800, 600),
      ],
    ),
  ];
}
