import 'package:flutter/material.dart';
import 'package:th_photobooth/models/frame_data.dart';

class FrameConfig {
  static const List<FrameData> allFrames = [
    FrameData(
      path: 'assets/frames/frame3.png',
      photoSlots: 3,
      size: Size(880, 2650),
      slots: [
        Rect.fromLTWH(59, 680, 762, 557),
        Rect.fromLTWH(61, 1293, 761, 556),
        Rect.fromLTWH(59, 1905, 762, 556),
      ],
    ),
    FrameData(
      path: 'assets/frames/frame1.png',
      photoSlots: 1,
      size: Size(431, 560),
      slots: [Rect.fromLTWH(17, 90, 397, 317)],
    ),
    FrameData(
      path: 'assets/frames/frame4.png',
      photoSlots: 4,
      size: Size(880, 2650),
      slots: [
        Rect.fromLTWH(55, 55, 770, 579),
        Rect.fromLTWH(55, 670, 770, 594),
        Rect.fromLTWH(78, 1302, 747, 562),
        Rect.fromLTWH(55, 1902, 770, 572),
      ],
    ),
  ];
}
