import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {

  static String get baseUrl {
    // Configuration pour les releases en production
    if (kReleaseMode) {
      // En production, utiliser l'URL de votre serveur de production
      return 'https://repartir-backend.onrender.com/api'; // À remplacer par votre URL de production
    }
    
    if (kIsWeb) return 'http://localhost:8183/api'; // navigateur
    if (Platform.isAndroid) {
      // Vérifier si on est en mode debug sur un appareil physique
      if (kDebugMode) {
        // Remplacer par l'adresse IP de votre machine sur le réseau local
        //return 'https://addressewifi/api
        return 'https://repartir-backend.onrender.com/api'; // remplacer l'adresse du backend
      }
      return 'http://10.0.2.2:8183/api'; // émulateur Android
    }
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