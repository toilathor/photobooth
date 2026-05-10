import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;

class GoogleSignInWebButton extends StatefulWidget {
  const GoogleSignInWebButton({super.key});

  @override
  State<GoogleSignInWebButton> createState() => _GoogleSignInWebButtonState();
}

class _GoogleSignInWebButtonState extends State<GoogleSignInWebButton> {
  Widget? _button;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _button = (GoogleSignInPlatform.instance as web.GoogleSignInPlugin)
          .renderButton(
            configuration: web.GSIButtonConfiguration(
              type: web.GSIButtonType.standard,
              shape: web.GSIButtonShape.pill,
              size: web.GSIButtonSize.large,
              theme: web.GSIButtonTheme.filledBlue,
              text: web.GSIButtonText.signinWith,
              logoAlignment: web.GSIButtonLogoAlignment.left,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          width: 260,
          child: _button ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

void showWebLoginDialog(
  BuildContext context, {
  required VoidCallback onLoginSuccess,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 380,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 50,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(48),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: Color(0xFF4285F4),
                size: 36,
              ),
            ),
            const Gap(32),
            Text(
              'XÁC THỰC TÀI KHOẢN',
              style: GoogleFonts.plusJakartaSans(
                color: colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Để đảm bảo ảnh được lưu trữ riêng tư và an toàn trên Google Drive của bạn.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
            const Gap(40),
            const GoogleSignInWebButton(),
            const Gap(32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'QUAY LẠI',
                style: GoogleFonts.plusJakartaSans(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Gap(32),
          ],
        ),
      ),
    ),
  );
}
