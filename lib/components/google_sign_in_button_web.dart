// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/storage_factory.dart';

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
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        _WebLoginDialogContent(onLoginSuccess: onLoginSuccess),
  );
}

class _WebLoginDialogContent extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const _WebLoginDialogContent({required this.onLoginSuccess});

  @override
  State<_WebLoginDialogContent> createState() => __WebLoginDialogContentState();
}

class __WebLoginDialogContentState extends State<_WebLoginDialogContent> {
  StreamSubscription<dynamic>? _subscription;
  bool _isCheckingScopes = true;
  bool _hasScopes = false;
  bool _isRequestingScopes = false;
  String? _errorMessage;
  bool _isSuccessCallbackTriggered = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
    _subscription = StorageFactory.instance.onCurrentUserChanged.listen((user) {
      _checkState();
    });
  }

  Future<void> _checkInitialState() async {
    await _checkState();
  }

  Future<void> _checkState() async {
    if (!mounted) return;
    final user = StorageFactory.instance.currentUser;
    if (user != null) {
      final hasScopes = await StorageFactory.instance.hasRequiredScopes();
      if (mounted) {
        setState(() {
          _hasScopes = hasScopes;
          _isCheckingScopes = false;
        });
        if (hasScopes && !_isSuccessCallbackTriggered) {
          _isSuccessCallbackTriggered = true;
          Navigator.pop(context);
          widget.onLoginSuccess();
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _hasScopes = false;
          _isCheckingScopes = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _handleGrantPermission() async {
    if (_isRequestingScopes) return;
    setState(() {
      _isRequestingScopes = true;
      _errorMessage = null;
    });

    final success = await StorageFactory.instance.requestRequiredScopes();

    if (!mounted) return;
    setState(() {
      _isRequestingScopes = false;
    });

    if (success) {
      await _checkState();
    } else {
      setState(() {
        _errorMessage = t.auth.grant_failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = StorageFactory.instance.currentUser;

    if (_isCheckingScopes) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380,
          height: 200,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Show Grant UI if user is signed in but hasn't authorized the Drive scope
    final bool showGrantUI = user != null && !_hasScopes;

    return Dialog(
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
                color:
                    (showGrantUI
                            ? const Color(0xFF34A853)
                            : const Color(0xFF4285F4))
                        .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                showGrantUI ? Icons.vpn_key_rounded : Icons.lock_person_rounded,
                color: showGrantUI
                    ? const Color(0xFF34A853)
                    : const Color(0xFF4285F4),
                size: 36,
              ),
            ),
            const Gap(32),
            Text(
              showGrantUI ? t.auth.grant_title : t.auth.title,
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
                showGrantUI ? t.auth.grant_description : t.auth.description,
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
            if (showGrantUI) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34A853),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isRequestingScopes
                        ? null
                        : _handleGrantPermission,
                    icon: _isRequestingScopes
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cloud_done_rounded),
                    label: Text(
                      t.auth.grant_btn,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const Gap(12),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.plusJakartaSans(
                    color: colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ] else ...[
              const GoogleSignInWebButton(),
            ],
            const Gap(32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                t.auth.back,
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
    );
  }
}
