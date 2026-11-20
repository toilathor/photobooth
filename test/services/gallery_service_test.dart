import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:th_photobooth/services/gallery_service.dart';

void main() {
  test('lists public Drive files using the section and API key', () async {
    late Uri requestedUri;
    final service = GalleryService(
      apiKey: 'test-key',
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"files":[{"id":"image-id","name":"photo.jpg",'
          '"mimeType":"image/jpeg","thumbnailLink":"https://thumb",'
          '"webViewLink":"https://drive","createdTime":"2026-10-26T00:00:00Z"}]}',
          200,
        );
      }),
    );

    final files = await service.listFiles('section_123456');

    expect(requestedUri.queryParameters['key'], 'test-key');
    expect(requestedUri.queryParameters['q'], contains('section_123456'));
    expect(files.single.name, 'photo.jpg');
    expect(files.single.isImage, isTrue);
    service.close();
  });

  test('fails clearly when the API key is missing', () async {
    final service = GalleryService(apiKey: '');

    await expectLater(
      service.listFiles('section_123456'),
      throwsA(isA<StateError>()),
    );
    service.close();
  });
}
