import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:th_photobooth/core/configs/google_drive_config.dart';
import 'package:th_photobooth/models/gallery_file.dart';

class GalleryService {
  final http.Client _client;
  final String apiKey;

  GalleryService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      apiKey = apiKey ?? GoogleDriveConfig.apiKey;

  Future<List<GalleryFile>> listFiles(String sectionId) async {
    if (apiKey.isEmpty) {
      throw StateError('Google Drive API key is not configured');
    }

    final uri = Uri.https('www.googleapis.com', '/drive/v3/files', {
      'q': "'$sectionId' in parents and trashed = false",
      'pageSize': '1000',
      'orderBy': 'createdTime',
      'fields': 'files(id,name,mimeType,thumbnailLink,webViewLink,createdTime)',
      'key': apiKey,
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Gallery request failed (${response.statusCode})');
    }

    final payload = jsonDecode(response.body) as Map<String, Object?>;
    final files = payload['files'] as List<Object?>? ?? const [];
    return files
        .map((file) => GalleryFile.fromJson(file! as Map<String, Object?>))
        .toList(growable: false);
  }

  void close() => _client.close();
}
