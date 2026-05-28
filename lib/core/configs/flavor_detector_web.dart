import 'dart:js_interop';

import 'package:flutter/services.dart' as services;
import 'package:web/web.dart' as web;

@JS('appFlavor')
external String? get jsAppFlavor;

String? getWebFlavorImpl() {
  // 1. Check compile-time/run-time appFlavor injected in window
  try {
    final jsFlavor = jsAppFlavor;
    if (jsFlavor != null && jsFlavor.isNotEmpty) {
      return jsFlavor;
    }
  } catch (_) {}

  // 2. Check compile-time appFlavor from services
  if (services.appFlavor != null && services.appFlavor?.isNotEmpty == true) {
    return services.appFlavor;
  }

  // 3. Fallback to runtime URL params or hostname
  final hostname = web.window.location.hostname;
  final search = web.window.location.search;
  if (search.contains('flavor=commercial') ||
      (hostname.contains('photobooth') && !hostname.contains('thphotobooth'))) {
    return 'commercial';
  }
  if (search.contains('flavor=personal') || hostname.contains('thphotobooth')) {
    return 'personal';
  }
  return null;
}
