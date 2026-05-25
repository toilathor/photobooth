import 'package:flutter/material.dart';

class GoogleSignInWebButton extends StatelessWidget {
  const GoogleSignInWebButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void showWebLoginDialog(
  BuildContext context, {
  required VoidCallback onLoginSuccess,
}) {
  // No-op on mobile platforms as Google Sign-in flow is native.
}
