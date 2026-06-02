import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/features/edit_photo/providers/edit_photo.provider.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class UploadProgressDialog extends StatelessWidget {
  final EditPhotoProvider provider;

  const UploadProgressDialog({
    super.key,
    required this.provider,
  });

  static Future<void> show(BuildContext context, EditPhotoProvider provider) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ChangeNotifierProvider<EditPhotoProvider>.value(
          value: provider,
          child: PopScope(
            canPop: false,
            child: UploadProgressDialog(provider: provider),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditPhotoProvider>(
      builder: (context, provider, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final progress = provider.uploadProgress;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 360,
            padding: const EdgeInsets.symmetric(
              vertical: 48,
              horizontal: 32,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 50,
                  spreadRadius: -10,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: provider.isPreparingUpload ? 0 : progress,
                  ),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary.withValues(
                                  alpha: 0.05,
                                ),
                              ),
                            ),
                          ),
                          // Progress circle
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: provider.isPreparingUpload ? null : value,
                              strokeWidth: 12,
                              strokeCap: StrokeCap.round,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.secondary,
                              ),
                            ),
                          ),
                          if (!provider.isPreparingUpload)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(value * 100).toInt()}',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.secondary,
                                    height: 1,
                                    letterSpacing: -2,
                                  ),
                                ),
                                Text(
                                  '%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary.withValues(alpha: 0.5),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            )
                          else
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0.8,
                                end: 1.2,
                              ),
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOutSine,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Icon(
                                    Icons.cloud_upload_rounded,
                                    color: colorScheme.secondary,
                                    size: 56,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const Gap(40),
                Text(
                  provider.isPreparingUpload
                      ? t.google_drive.preparing
                      : t.google_drive.uploading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: colorScheme.secondary,
                  ),
                ),
                const Gap(16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    provider.uploadStatusMessage,
                    key: ValueKey(provider.uploadStatusMessage),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
