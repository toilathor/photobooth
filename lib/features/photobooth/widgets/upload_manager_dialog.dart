import 'package:material_ui/material_ui.dart';
import 'package:th_photobooth/i18n/strings.g.dart';
import 'package:th_photobooth/services/upload_queue.dart';

/// Lets the operator see the background Drive uploads, retry them as soon as
/// the network is back, or drop a session that should not be uploaded.
class UploadManagerDialog extends StatelessWidget {
  const UploadManagerDialog({super.key, required this.queue});

  final UploadQueue queue;

  static Future<void> show(BuildContext context, UploadQueue queue) =>
      showDialog<void>(
        context: context,
        builder: (_) => UploadManagerDialog(queue: queue),
      );

  String _status(UploadJob job) {
    if (identical(job, queue.active)) {
      return t.google_drive.uploading_files(
        current: job.sent,
        total: job.files.length,
      );
    }
    return job.failed
        ? t.google_drive.upload_retrying
        : t.google_drive.job_waiting;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: queue,
      builder: (context, _) {
        final pending = queue.pending;
        return AlertDialog(
          title: Text(t.google_drive.manager_title),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pending.isEmpty) Text(t.google_drive.manager_empty),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final job in pending)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            job.failed
                                ? Icons.cloud_off_rounded
                                : Icons.cloud_upload_rounded,
                            color: job.failed
                                ? colorScheme.error
                                : colorScheme.secondary,
                          ),
                          title: Text(
                            t.google_drive.job_title(
                              time: TimeOfDay.fromDateTime(job.createdAt)
                                  .format(context),
                            ),
                          ),
                          subtitle: Text(_status(job)),
                          trailing: IconButton(
                            tooltip: t.google_drive.remove_job,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => queue.remove(job),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.google_drive.manager_done(count: queue.uploadedCount),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: pending.any((job) => job.failed)
                  ? queue.retryNow
                  : null,
              child: Text(t.google_drive.retry_now),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        );
      },
    );
  }
}
