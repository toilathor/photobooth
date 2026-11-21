import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../core/configs/google_drive_config.dart';
import 'storage_section.dart';
import 'storage_service_interface.dart';
import 'storage_user.dart';

class _AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final String _accessToken;

  _AuthenticatedClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

class GoogleDriveService implements StorageService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Completer<void>? _initCompleter;

  GoogleSignInAccount? _currentUser;

  @override
  StorageUser? get currentUser => _toStorageUser(_currentUser);

  final StreamController<StorageUser?> _userStreamController =
      StreamController<StorageUser?>.broadcast();

  @override
  Stream<StorageUser?> get onCurrentUserChanged => _userStreamController.stream;

  StorageUser? _toStorageUser(GoogleSignInAccount? account) {
    if (account == null) return null;
    return StorageUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
    );
  }

  @override
  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter?.future;

    _initCompleter = Completer<void>();

    try {
      _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _currentUser = event.user;
          _userStreamController.add(currentUser);
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          _currentUser = null;
          _userStreamController.add(null);
        }
      });

      // Khởi tạo Google Sign-In với clientId từ Config
      // Chúng ta gọi initialize cho cả Web và Mobile để đảm bảo SDK luôn sẵn sàng
      await _googleSignIn.initialize(
        clientId: kIsWeb ? GoogleDriveConfig.clientId : null,
        serverClientId: !kIsWeb ? GoogleDriveConfig.clientId : null,
      );

      if (!kIsWeb) {
        try {
          _currentUser = await _googleSignIn.attemptLightweightAuthentication();
          _userStreamController.add(currentUser);
        } catch (e) {
          if (kDebugMode) print('Lightweight auth failed: $e');
        }
      }

      _initCompleter?.complete();
    } catch (e) {
      if (_initCompleter?.isCompleted != true) _initCompleter?.complete();
      if (kDebugMode) print('Error initializing GoogleSignIn: $e');
    }

    return _initCompleter?.future;
  }

  Future<GoogleSignInAccount?> _signInAccount() async {
    await init();

    try {
      if (_currentUser != null) return _currentUser;

      var account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        _currentUser = account;
        return account;
      }

      account = await _googleSignIn.authenticate(
        scopeHint: GoogleDriveConfig.scopes,
      );
      _currentUser = account;
      return account;
    } catch (e) {
      if (kDebugMode) print('Error signing in: $e');
      return null;
    }
  }

  @override
  Future<StorageSection?> prepareSection(String folderName) async {
    _AuthenticatedClient? httpClient;
    try {
      final account = await _signInAccount();
      if (account == null) return null;

      final authorization = await account.authorizationClient.authorizeScopes(
        GoogleDriveConfig.scopes,
      );
      httpClient = _AuthenticatedClient(authorization.accessToken);
      final driveApi = drive.DriveApi(httpClient);
      final rootId = await _getOrCreateFolder(driveApi);
      if (rootId == null) return null;

      final escapedName = _escapeQuery(folderName);
      final folders = await driveApi.files.list(
        q:
            "name = '$escapedName' and '$rootId' in parents and "
            "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
        $fields: 'files(id, webViewLink)',
      );
      final existing = folders.files?.firstOrNull;
      if (existing?.id != null) return _toSection(existing!);

      final created = await driveApi.files.create(
        drive.File()
          ..name = folderName
          ..mimeType = 'application/vnd.google-apps.folder'
          ..parents = [rootId],
        $fields: 'id, webViewLink',
      );
      return created.id == null ? null : _toSection(created);
    } finally {
      httpClient?.close();
    }
  }

  @override
  Future<void> uploadCollection({
    required Map<String, Uint8List> files,
    required String sectionId,
    void Function(int current, int total)? onProgress,
  }) async {
    _AuthenticatedClient? httpClient;
    try {
      final account = await _signInAccount();
      if (account == null) throw StateError('Google Drive sign-in required');

      final authorization = await account.authorizationClient.authorizeScopes(
        GoogleDriveConfig.scopes,
      );

      httpClient = _AuthenticatedClient(authorization.accessToken);
      await uploadFiles(
        drive.DriveApi(httpClient),
        files: files,
        sectionId: sectionId,
        onProgress: onProgress,
      );
    } catch (e) {
      if (kDebugMode) print('Error uploading collection: $e');
      rethrow;
    } finally {
      httpClient?.close();
    }
  }

  /// Makes the section public, then sends [files] into it. Files Drive already
  /// has at the same size are skipped, so a retry resumes where it stopped.
  @visibleForTesting
  Future<void> uploadFiles(
    drive.DriveApi driveApi, {
    required Map<String, Uint8List> files,
    required String sectionId,
    void Function(int current, int total)? onProgress,
  }) async {
    // Public first: the QR is shown before the upload ends, and a guest who
    // scans early should see an empty gallery rather than an error.
    final permissions = await driveApi.permissions.list(
      sectionId,
      $fields: 'permissions(id, role, type)',
    );
    final isPublic =
        permissions.permissions?.any(
          (permission) =>
              permission.type == 'anyone' && permission.role == 'reader',
        ) ??
        false;
    if (!isPublic) {
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'reader'
          ..type = 'anyone',
        sectionId,
      );
    }

    final Map<String, String> subFolderIds = {};
    int currentCount = 0;
    final int totalCount = files.length;

    onProgress?.call(0, totalCount);

    final fileNames = files.keys.toList();
    for (var fileName in fileNames) {
      final fileBytes = files[fileName];
      if (fileBytes == null) continue;

      String actualFileName = fileName;
      String parentId = sectionId;

      // Xử lý thư mục con (chỉ hỗ trợ 1 cấp)
      if (actualFileName.contains('/')) {
        final parts = actualFileName.split('/');
        final subFolderName = parts[0];
        actualFileName = parts.sublist(1).join('/');

        if (subFolderIds.containsKey(subFolderName)) {
          parentId = subFolderIds[subFolderName]!;
        } else {
          parentId = await _getOrCreateSubFolder(
            driveApi,
            sectionId,
            subFolderName,
          );
          subFolderIds[subFolderName] = parentId;
        }
      }

      final mimeType = _getMimeType(actualFileName);
      final metadata = drive.File()
        ..name = actualFileName
        ..mimeType = mimeType;

      // Đảm bảo Stream được tạo từ một bản sao sạch của tệp
      final media = drive.Media(
        Stream.fromIterable([fileBytes]),
        fileBytes.length,
        contentType: mimeType,
      );

      final escapedName = _escapeQuery(actualFileName);
      final existing = await driveApi.files.list(
        q: "name = '$escapedName' and '$parentId' in parents and trashed = false",
        $fields: 'files(id, size)',
      );
      final existingFile = existing.files?.firstOrNull;
      final existingId = existingFile?.id;
      // Already sent by an earlier attempt: a retry resumes instead of
      // sending every video again over a weak network.
      if (existingFile?.size == '${fileBytes.length}') {
        currentCount++;
        onProgress?.call(currentCount, totalCount);
        continue;
      }
      if (existingId == null) {
        metadata.parents = [parentId];
        await driveApi.files.create(
          metadata,
          uploadMedia: media,
          uploadOptions: drive.UploadOptions.resumable,
        );
      } else {
        await driveApi.files.update(
          metadata,
          existingId,
          uploadMedia: media,
          uploadOptions: drive.UploadOptions.resumable,
        );
      }

      currentCount++;
      onProgress?.call(currentCount, totalCount);
    }
  }

  Future<String?> _getOrCreateFolder(drive.DriveApi driveApi) async {
    try {
      const query =
          "name = '${GoogleDriveConfig.folderName}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
      final folderList = await driveApi.files.list(q: query);

      if (folderList.files != null && folderList.files?.isNotEmpty == true) {
        return folderList.files?.first.id;
      }

      final folder = drive.File()
        ..name = GoogleDriveConfig.folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      if (kDebugMode) print('Error getting/creating folder: $e');
      return null;
    }
  }

  Future<String> _getOrCreateSubFolder(
    drive.DriveApi driveApi,
    String parentId,
    String name,
  ) async {
    final escapedName = _escapeQuery(name);
    final folders = await driveApi.files.list(
      q:
          "name = '$escapedName' and '$parentId' in parents and "
          "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      $fields: 'files(id)',
    );
    final existingId = folders.files?.firstOrNull?.id;
    if (existingId != null) return existingId;

    final created = await driveApi.files.create(
      drive.File()
        ..name = name
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = [parentId],
      $fields: 'id',
    );
    if (created.id == null) throw StateError('Unable to create Drive folder');
    return created.id!;
  }

  StorageSection _toSection(drive.File folder) {
    final id = folder.id!;
    return StorageSection(
      id: id,
      webViewUrl:
          folder.webViewLink ?? 'https://drive.google.com/drive/folders/$id',
    );
  }

  String _escapeQuery(String value) => value.replaceAll("'", r"\'");

  String _getMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'application/octet-stream';
  }

  @override
  Future<bool> hasRequiredScopes() async {
    if (!kIsWeb) return true;
    final account = _currentUser;
    if (account == null) return false;
    try {
      final auth = await account.authorizationClient.authorizationForScopes(
        GoogleDriveConfig.scopes,
      );
      return auth != null;
    } catch (e) {
      if (kDebugMode) print('Error checking scopes: $e');
      return false;
    }
  }

  @override
  Future<bool> requestRequiredScopes() async {
    if (!kIsWeb) return true;
    final account = _currentUser;
    if (account == null) return false;
    try {
      await account.authorizationClient.authorizeScopes(
        GoogleDriveConfig.scopes,
      );
      _userStreamController.add(currentUser);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error requesting scopes: $e');
      return false;
    }
  }
}
