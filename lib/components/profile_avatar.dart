import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

/// Widget réutilisable pour afficher un avatar de profil avec fallback
/// Affiche une icône de personne pour jeune/mentor, building pour centre/entreprise
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final bool isPerson; // true pour jeune/mentor, false pour centre/entreprise
  final Color? backgroundColor;
  final Color? iconColor;
  final String? cacheKey; // Pour forcer le rafraîchissement de l'image

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.radius = 30,
    this.isPerson = true,
    this.backgroundColor,
    this.iconColor,
    this.cacheKey,
  });

  /// Corrige l'URL si elle n'a pas le bon format (ajoute le port si manquant)
  /// Fonctionne pour Web et Mobile
  String? _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Si l'URL ne commence pas par http/https, retourner null
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return null;
    }
    
    try {
      // Correction PRIORITAIRE pour le cas : http://localhost/8183/...
      // Ce format incorrect vient de la base de données où le port est dans le chemin
      // Pattern : http://localhost/8183/uploads/... → http://localhost:8183/uploads/...
      // Vérifier d'abord si l'URL contient ce pattern
      if (url.contains('http://localhost/8183')) {
        // Remplacer http://localhost/8183 par http://localhost:8183 partout
        final corrected = url.replaceAll('http://localhost/8183', 'http://localhost:8183');
        debugPrint('🔧 URL corrigée: $url → $corrected');
        return corrected;
      }
      
      // Correction pour http://localhost/uploads/... (sans port, sans /8183)
      if (url.contains('http://localhost/uploads/') && !url.contains(':8183')) {
        return url.replaceAll('http://localhost/uploads/', 'http://localhost:8183/uploads/');
      }
      
      final uri = Uri.parse(url);
      
      // Si l'URL est http://localhost/8183/... (sans port dans l'URI), corriger
      if (uri.host == 'localhost' && uri.port == 0 && uri.path.startsWith('/8183/')) {
        // Extraire le chemin après /8183
        final path = uri.path.substring(5); // Enlever '/8183'
        return 'http://localhost:8183$path${uri.hasQuery ? '?${uri.query}' : ''}';
      }
      
      // Si l'URL est http://localhost/... sans port et sans /8183 dans le chemin, ajouter le port
      if (uri.host == 'localhost' && uri.port == 0 && !uri.path.startsWith('/8183/')) {
        return 'http://localhost:8183${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
      }
      
      // Pour mobile : si l'URL contient localhost mais qu'on est sur mobile,
      // on garde l'URL telle quelle (le frontend gère déjà la conversion pour Android émulateur)
      // En production, les URLs doivent être des domaines complets
      
      return url;
    } catch (e) {
      // Si l'URL est invalide, retourner null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = backgroundColor ?? Colors.grey.shade200;
    final defaultIconColor = iconColor ?? Colors.blueGrey;
    
    // Corriger l'URL si nécessaire
    String? fixedUrl = _fixImageUrl(photoUrl);
    
    // Ajouter un timestamp ou cacheKey à l'URL pour forcer le rafraîchissement
    String? imageUrl = fixedUrl;
    if (fixedUrl != null && cacheKey != null) {
      try {
        final uri = Uri.parse(fixedUrl);
        final updatedUri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'v': cacheKey ?? DateTime.now().millisecondsSinceEpoch.toString(),
        });
        imageUrl = updatedUri.toString();
      } catch (e) {
        // Si l'URL ne peut pas être parsée, utiliser l'URL originale
        imageUrl = fixedUrl;
      }
    }
    
    final bool hasPhoto = imageUrl != null && imageUrl.isNotEmpty;

    // Utiliser Image.network avec errorBuilder pour mieux gérer les erreurs CORS
    if (hasPhoto) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: defaultBgColor,
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // En cas d'erreur (CORS, 404, etc.), afficher l'icône par défaut
              return Icon(
                isPerson ? Icons.person : Icons.business,
                size: radius * 1.5,
                color: defaultIconColor,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              // Afficher un indicateur de chargement
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            // Headers pour éviter le cache (mais ne pas utiliser Cache-Control qui peut causer des problèmes CORS)
            headers: kIsWeb ? {} : {'Cache-Control': 'no-cache'},
          ),
        ),
      );
    }

    // Pas de photo, afficher l'icône par défaut
    return CircleAvatar(
      radius: radius,
      backgroundColor: defaultBgColor,
      child: Icon(
        isPerson ? Icons.person : Icons.business,
        size: radius * 1.5,
        color: defaultIconColor,
      ),
    );
  }
}

