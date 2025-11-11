/// Utilitaires pour la gestion des images
class ImageUtils {
  /// Ajoute un timestamp à l'URL pour éviter le cache
  /// 
  /// Exemple : 
  /// addCacheBuster('http://example.com/photo.jpg') 
  /// => 'http://example.com/photo.jpg?t=1699876543'
  static String addCacheBuster(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // Si l'URL ne commence pas par http, on la retourne telle quelle
    if (!url.startsWith('http')) return url;
    
    // Ajouter un timestamp pour forcer le rechargement
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final separator = url.contains('?') ? '&' : '?';
    
    return '$url${separator}t=$timestamp';
  }

  /// Crée un NetworkImage avec cache-busting
  static NetworkImage networkImageWithRefresh(String url) {
    return NetworkImage(addCacheBuster(url));
  }
}

