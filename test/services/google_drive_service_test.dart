import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:th_photobooth/services/google_drive_service.dart';

void main() {
  test(
    'makes the section public first and resumes a half-done upload',
    () async {
      // What Drive already holds from an earlier, interrupted attempt.
      const onDrive = {
        'done.jpg': ('id-done', 3), // fully sent: same size
        'partial.jpg': ('id-partial', 1), // different size: send again
      };
      final calls = <String>[];

      final client = MockClient((request) async {
        final url = request.url;
        final json = {'content-type': 'application/json'};
        if (url.path.endsWith('/permissions')) {
          calls.add('${request.method} permissions');
          return http.Response(
            request.method == 'GET' ? '{"permissions":[]}' : '{}',
            200,
            headers: json,
          );
        }
        if (request.method == 'GET' && url.path == '/drive/v3/files') {
          final name = RegExp(r"name = '([^']+)'")
              .firstMatch(url.queryParameters['q']!)!
              .group(1)!;
          final file = onDrive[name];
          return http.Response(
            jsonEncode({
              'files': [
                if (file != null) {'id': file.$1, 'size': '${file.$2}'},
              ],
            }),
            200,
            headers: json,
          );
        }
        if (url.host == 'resumable.test') {
          return http.Response('{"id":"sent"}', 200, headers: json);
        }
        // Start of a resumable upload: create (POST) or update (PATCH).
        final metadata = jsonDecode(request.body) as Map<String, Object?>;
        calls.add('${request.method} ${metadata['name']}');
        return http.Response(
          '',
          200,
          headers: {'location': 'https://resumable.test/${metadata['name']}'},
        );
      });

      final progress = <int>[];
      await GoogleDriveService().uploadFiles(
        drive.DriveApi(client),
        sectionId: 'section',
        files: {
          'done.jpg': Uint8List(3),
          'partial.jpg': Uint8List(5),
          'new.jpg': Uint8List(4),
        },
        onProgress: (current, _) => progress.add(current),
      );

      expect(calls, [
        'GET permissions',
        'POST permissions',
        'PATCH partial.jpg',
        'POST new.jpg',
      ]);
      expect(progress.last, 3);
    },
  );
}
