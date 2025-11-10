import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {

  static String get baseUrl {
  if (kIsWeb) return 'http://localhost:8183/api'; // navigateur
  if (Platform.isAndroid) return 'http://10.0.2.2:8183/api'; // émulateur Android
  return 'http://127.0.0.1:8183/api'; // iOS ou desktop
}


static String get baseOrigin {
  final uri = Uri.parse(baseUrl);
  final port = (uri.hasPort && uri.port != 0) ? ':${uri.port}' : '';
  return '${uri.scheme}://${uri.host}$port';
}

static const Duration connectTimeout = Duration(seconds: 15);
static const Duration receiveTimeout = Duration(seconds: 20);

  
}