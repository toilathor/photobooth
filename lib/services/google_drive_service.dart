import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../core/configs/google_drive_config.dart';
import 'storage_service_interface.dart';

class _AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final String _accessToken;

  _AuthenticatedClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}

class GoogleDriveService implements StorageService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Completer<void>? _initCompleter;

  GoogleSignInAccount? _currentUser;

  @override
  GoogleSignInAccount? get currentUser => _currentUser;

  final StreamController<GoogleSignInAccount?> _userStreamController =
      StreamController<GoogleSignInAccount?>.broadcast();

  @override
  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _userStreamController.stream;

  @override
  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter?.future;

    _initCompleter = Completer<void>();

    try {
      _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _currentUser = event.user;
          _userStreamController.add(_currentUser);
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
          _userStreamController.add(_currentUser);
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

  @override
  Future<GoogleSignInAccount?> signIn() async {
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
  Future<void> signOut() async {
    await init();
    await _googleSignIn.signOut();
  }

  @override
  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    // Để tương thích, chúng ta vẫn có thể dùng phương thức này hoặc
    // chuyển hướng nó sang một collection có 1 tệp.
    return null;
  }

  @override
  Future<String?> uploadCollection({
    required Map<String, Uint8List> files,
    required String folderName,
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      final account = await signIn();
      if (account == null) return null;

      final authorization = await account.authorizationClient.authorizeScopes(
        GoogleDriveConfig.scopes,
      );

      final httpClient = _AuthenticatedClient(authorization.accessToken);
      final driveApi = drive.DriveApi(httpClient);

      // 1. Lấy/Tạo thư mục gốc (Photobooth)
      String? rootId = await _getOrCreateFolder(driveApi);
      if (rootId == null) return null;

      // 2. Tạo thư mục con cho phiên (Session Folder)
      final sessionFolder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = [rootId];

      final createdFolder = await driveApi.files.create(sessionFolder);
      final sessionId = createdFolder.id;
      if (sessionId == null) return null;

      // 3. Tải lên tất cả các tệp trong Map vào thư mục sessionId
      final Map<String, String> subFolderIds = {};
      int currentCount = 0;
      final int totalCount = files.length;

      onProgress?.call(0, totalCount);

      final fileNames = files.keys.toList();
      for (var fileName in fileNames) {
        final fileBytes = files[fileName];
        if (fileBytes == null) continue;

        String actualFileName = fileName;
        String parentId = sessionId;

        // Xử lý thư mục con (chỉ hỗ trợ 1 cấp)
        if (actualFileName.contains('/')) {
          final parts = actualFileName.split('/');
          final subFolderName = parts[0];
          actualFileName = parts.sublist(1).join('/');

          if (subFolderIds.containsKey(subFolderName)) {
            parentId = subFolderIds[subFolderName]!;
          } else {
            final subFolder = drive.File()
              ..name = subFolderName
              ..mimeType = 'application/vnd.google-apps.folder'
              ..parents = [sessionId];
            final createdSubFolder = await driveApi.files.create(subFolder);
            if (createdSubFolder.id != null) {
              subFolderIds[subFolderName] = createdSubFolder.id!;
              parentId = createdSubFolder.id!;
            }
          }
        }

        final mimeType = _getMimeType(actualFileName);
        final driveFile = drive.File()
          ..name = actualFileName
          ..mimeType = mimeType
          ..parents = [parentId];

        // Đảm bảo Stream được tạo từ một bản sao sạch của tệp
        final media = drive.Media(
          Stream.fromIterable([fileBytes]),
          fileBytes.length,
          contentType: mimeType,
        );

        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
          uploadOptions: drive.UploadOptions.resumable,
        );

        // Giải phóng bộ nhớ bằng cách loại bỏ byte array khỏi map ngay lập tức
        files.remove(fileName);

        currentCount++;
        onProgress?.call(currentCount, totalCount);
      }

      // 4. Cấp quyền xem cho bất kỳ ai có link (Public reader)
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'reader'
          ..type = 'anyone',
        sessionId,
      );

      // 5. Lấy link chia sẻ của thư mục
      final folderMetadata =
          await driveApi.files.get(sessionId, $fields: 'webViewLink')
              as drive.File;

      httpClient.close();
      return folderMetadata.webViewLink;
    } catch (e) {
      if (kDebugMode) print('Error uploading collection: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getFolderLink(String folderName) async {
    try {
      final account = await signIn();
      if (account == null) return null;

      final authorization = await account.authorizationClient.authorizeScopes(
        GoogleDriveConfig.scopes,
      );

      final httpClient = _AuthenticatedClient(authorization.accessToken);
      final driveApi = drive.DriveApi(httpClient);

      // 1. Lấy thư mục gốc (Photobooth)
      String? rootId = await _getOrCreateFolder(driveApi);
      if (rootId == null) return null;

      // 2. Tìm thư mục con với tên folderName
      final query =
          "name = '$folderName' and '$rootId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
      final folderList = await driveApi.files.list(
        q: query,
        $fields: 'files(id, webViewLink)',
      );

      httpClient.close();

      if (folderList.files != null && folderList.files?.isNotEmpty == true) {
        return folderList.files?.first.webViewLink;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error checking folder: $e');
      return null;
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
      _userStreamController.add(_currentUser);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error requesting scopes: $e');
      return false;
    }
  }
}
