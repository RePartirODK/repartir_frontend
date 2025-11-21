# ⚠️ PROBLÈME : updateMe écrase l'URL de photo avec une URL mal formée

## 🐛 Problème identifié

Quand on appelle l'endpoint de mise à jour du profil (probablement `PUT /jeunes/profile` ou similaire), l'URL de photo envoyée est correcte :
```json
{
  "urlPhoto": "http://localhost:8183/uploads/photos/user_1.png"
}
```

**MAIS** après la mise à jour, quand on recharge le profil, l'URL retournée est mal formée :
```json
{
  "urlPhoto": "http://localhost/8183/uploads/photos/user_1.png"
}
```

## 🔍 Cause probable

La méthode qui gère `updateMe` (probablement dans `JeuneController` ou `JeuneService`) ne normalise pas l'URL de photo avant de la sauvegarder en base de données.

## ✅ Solution à implémenter

### Dans le service qui gère la mise à jour du profil

**Fichier : `JeuneService.java` ou similaire**

```java
public Jeune updateJeune(Long id, JeuneRequest request) {
    Jeune jeune = jeuneRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Jeune non trouvé"));
    
    // Mettre à jour les champs
    if (request.getPrenom() != null) {
        jeune.setPrenom(request.getPrenom());
    }
    if (request.getAPropos() != null) {
        jeune.setAPropos(request.getAPropos());
    }
    // ... autres champs ...
    
    // ✅ NORMALISER l'URL de photo si elle est fournie
    if (request.getUrlPhoto() != null && !request.getUrlPhoto().isEmpty()) {
        String normalizedUrl = normalizeUrl(request.getUrlPhoto());
        jeune.getUtilisateur().setUrlPhoto(normalizedUrl);
        log.info("URL photo normalisée : {} -> {}", request.getUrlPhoto(), normalizedUrl);
    }
    
    return jeuneRepository.save(jeune);
}

/**
 * Normalise une URL pour s'assurer qu'elle contient le port correct
 */
private String normalizeUrl(String url) {
    if (url == null || url.isEmpty()) {
        return url;
    }
    
    // Corriger http://localhost/8183/... en http://localhost:8183/...
    if (url.contains("http://localhost/8183/")) {
        return url.replace("http://localhost/8183/", "http://localhost:8183/");
    }
    
    // Corriger http://localhost/... (sans port) en http://localhost:8183/...
    if (url.contains("http://localhost/") && !url.contains(":8183")) {
        return url.replace("http://localhost/", "http://localhost:8183/");
    }
    
    return url;
}
```

### Alternative : Utiliser la méthode de normalisation existante

Si vous avez déjà une méthode `normalizeUrl()` dans `UploadService` ou `UtilisateurServices`, réutilisez-la :

```java
@Autowired
private UploadService uploadService; // ou UtilisateurServices

public Jeune updateJeune(Long id, JeuneRequest request) {
    Jeune jeune = jeuneRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Jeune non trouvé"));
    
    // ... mise à jour des autres champs ...
    
    // ✅ NORMALISER l'URL de photo
    if (request.getUrlPhoto() != null && !request.getUrlPhoto().isEmpty()) {
        String normalizedUrl = uploadService.normalizeUrl(request.getUrlPhoto());
        // OU : String normalizedUrl = utilisateurServices.normalizeUrl(request.getUrlPhoto());
        jeune.getUtilisateur().setUrlPhoto(normalizedUrl);
    }
    
    return jeuneRepository.save(jeune);
}
```

## 🧪 Test à effectuer

1. **Uploader une photo** → Vérifier que l'URL retournée est correcte : `http://localhost:8183/uploads/photos/user_X.png`
2. **Appeler updateMe avec cette URL** → Vérifier dans les logs que l'URL est normalisée
3. **Recharger le profil** → Vérifier que l'URL retournée est toujours : `http://localhost:8183/uploads/photos/user_X.png`
4. **NE DOIT PAS être** : `http://localhost/8183/uploads/photos/user_X.png`

## 📝 Checklist

- [ ] La méthode `updateMe` normalise l'URL de photo avant sauvegarde
- [ ] Les logs montrent l'URL normalisée
- [ ] Test upload + updateMe : URL reste correcte
- [ ] Test rechargement profil : URL reste correcte

## 🔍 Vérification

Après correction, dans les logs backend, vous devriez voir :
```
URL photo normalisée : http://localhost/8183/uploads/photos/user_1.png -> http://localhost:8183/uploads/photos/user_1.png
```

Et après rechargement du profil, l'URL doit toujours être au format correct.


