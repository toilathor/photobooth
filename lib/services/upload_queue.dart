import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:th_photobooth/services/storage_factory.dart';
import 'package:th_photobooth/services/storage_service_interface.dart';

/// A finished session waiting to be uploaded, or being uploaded.
class UploadJob {
  UploadJob(this.sectionId, this.files);

  final String sectionId;
  final Map<String, Uint8List> files;

  /// Files already uploaded in the current attempt.
  int sent = 0;

  /// The last attempt failed and will be retried.
  bool failed = false;

  /// Completes when the operator drops the job, so the queue stops waiting on
  /// its upload.
  final Completer<void> _dropped = Completer<void>();

  /// When the guest finished, to tell sessions apart in the upload manager.
  final DateTime createdAt = DateTime.now();
}

/// Uploads finished sessions in the background, one at a time, and keeps
/// retrying on a weak network so the booth never waits for Drive.
class UploadQueue extends ChangeNotifier {
  /// [storage] defaults to [StorageFactory.instance], looked up only when the
  /// first upload starts.
  UploadQueue({this._storage, this.retryDelay = const Duration(seconds: 20)});

  static final UploadQueue instance = UploadQueue();

  final StorageService? _storage;
  final Duration retryDelay;
  final List<UploadJob> _jobs = [];
  final Set<String> _uploaded = {};
  bool _running = false;
  UploadJob? _active;
  Completer<void>? _wake;

  /// Sessions not uploaded yet, the next one to upload first.
  List<UploadJob> get pending => List.unmodifiable(_jobs);

  bool isUploaded(String sectionId) => _uploaded.contains(sectionId);

  /// Sessions uploaded since the app opened.
  int get uploadedCount => _uploaded.length;

  /// The job being sent right now.
  UploadJob? get active => _active;

  /// Skips the wait after a failure, e.g. once the network is back.
  void retryNow() {
    if (_wake?.isCompleted == false) _wake!.complete();
  }

  /// Drops a session from the queue (its zip stays on the device). For the
  /// one being uploaded, the request can't be cancelled: the queue just stops
  /// waiting for it and moves on, and the files sent so far stay on Drive.
  bool remove(UploadJob job) {
    if (!_jobs.remove(job)) return false;
    if (!job._dropped.isCompleted) job._dropped.complete();
    notifyListeners();
    return true;
  }

  void add(String sectionId, Map<String, Uint8List> files) {
    _jobs.add(UploadJob(sectionId, files));
    notifyListeners();
    unawaited(_run());
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    final storage = _storage ?? StorageFactory.instance;
    while (_jobs.isNotEmpty) {
      final job = _active = _jobs.first;
      try {
        // On web an expired Google token can only be renewed by a popup, which
        // needs a click: wait for the next "Hoàn tất" instead of trying here.
        if (!await storage.hasRequiredScopes()) {
          throw StateError('Google sign-in expired');
        }
        // No timeout: a cancelled-but-still-running upload would be sent again
        // by the retry and duplicate the files on Drive.
        if (!job._dropped.isCompleted) {
          // Future.any also swallows a late error of an abandoned upload.
          await Future.any([
            storage.uploadCollection(
              files: job.files,
              sectionId: job.sectionId,
              onProgress: (sent, _) {
                job
                  ..sent = sent
                  ..failed = false;
                notifyListeners();
              },
            ),
            job._dropped.future,
          ]);
        }
        _active = null;
        if (!job._dropped.isCompleted) {
          _jobs.remove(job);
          _uploaded.add(job.sectionId);
        }
        notifyListeners();
      } catch (error) {
        _active = null;
        debugPrint('Upload of ${job.sectionId} failed, will retry: $error');
        // Move it to the back so one stuck session never blocks the others
        // (unless the operator dropped it meanwhile).
        job.failed = true;
        if (_jobs.remove(job)) _jobs.add(job);
        notifyListeners();
        _wake = Completer<void>();
        await Future.any([Future<void>.delayed(retryDelay), _wake!.future]);
        _wake = null;
      }
    }
    _running = false;
  }
}
