import 'package:web/web.dart' as web;

/// On web every photo and recap video lives in memory behind a blob URL until
/// it is revoked; without this the booth tab grows with every guest.
void revokeBlobUrl(String path) {
  if (path.startsWith('blob:')) web.URL.revokeObjectURL(path);
}
