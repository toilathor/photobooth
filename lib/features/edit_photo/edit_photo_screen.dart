import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPhotoScreen extends StatelessWidget {
  const EditPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CHỈNH SỬA ẢNH',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: colorScheme.secondary,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'Màn hình Chỉnh sửa đang phát triển...',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
      ),
    );
  }
}
