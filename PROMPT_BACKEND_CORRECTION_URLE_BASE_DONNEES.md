# ⚠️ PROBLÈME CRITIQUE : URL mal formée en base de données

## 🐛 Problème identifié

Après l'upload d'une photo, le backend retourne la bonne URL :
```json
{"urlPhoto":"http://localhost:8183/uploads/photos/user_1.png"}
```

**MAIS** quand on recharge le profil via `/jeunes/profile`, l'URL retournée est :
```json
{"urlPhoto":"http://localhost/8183/uploads/photos/user_1.png"}
```

**Notez la différence** :
- ✅ Upload retourne : `http://localhost:8183/uploads/photos/user_1.png` (avec port)
- ❌ Profil retourne : `http://localhost/8183/uploads/photos/user_1.png` (sans port, avec /8183 dans le chemin)

## 🔍 Cause probable

L'URL est **mal enregistrée en base de données** après l'upload. Soit :
1. L'URL retournée par `UploadService` n'est pas correctement sauvegardée dans l'entité `Utilisateur`
2. Ou il y a une transformation incorrecte de l'URL lors de la sauvegarde

## ✅ Solution à implémenter

### 1. Vérifier la sauvegarde de l'URL après upload

**Dans le contrôleur qui gère l'upload de photo** (probablement `UtilisateurController` ou similaire) :

```java
@PostMapping("/upload-photo")
public ResponseEntity<?> uploadPhoto(
    @RequestParam("file") MultipartFile file,
    @RequestParam("email") String email
) {
    try {
        // Upload du fichier
        String urlPhoto = uploadService.uploadFile(file, "user_" + userId, TypeFichier.PHOTO);
        
        // ✅ VÉRIFIER que l'URL contient bien le port
        if (urlPhoto.contains("localhost") && !urlPhoto.contains(":8183")) {
            urlPhoto = urlPhoto.replace("http://localhost/", "http://localhost:8183/");
        }
        
        // Récupérer l'utilisateur
        Utilisateur utilisateur = utilisateurRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        
        // ✅ Sauvegarder l'URL CORRECTE
        utilisateur.setUrlPhoto(urlPhoto);
        utilisateurRepository.save(utilisateur);
        
        // ✅ VÉRIFIER avant de retourner
        log.info("URL photo sauvegardée : {}", utilisateur.getUrlPhoto());
        
        return ResponseEntity.ok(Map.of(
            "message", "Photo enregistrée avec succès",
            "urlPhoto", urlPhoto
        ));
    } catch (Exception e) {
        return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
    }
}
```

### 2. Vérifier que l'URL est correcte dans UploadService

**Dans `UploadService.java`**, s'assurer que la méthode retourne bien une URL avec le port :

```java
public String uploadFile(MultipartFile file, String fileName, TypeFichier typefichier) {
    try {
        // ... code d'upload ...
        
        String relativeUrl = "/uploads/" + getFolderName(typefichier) + "/" + fileName + extension;
        String fullUrl = serverUrl + relativeUrl;
        
        // ✅ DOUBLE VÉRIFICATION : s'assurer que le port est présent
        if (fullUrl.contains("localhost") && !fullUrl.contains(":8183")) {
            // Si l'URL est http://localhost/..., corriger en http://localhost:8183/...
            fullUrl = fullUrl.replace("http://localhost/", "http://localhost:8183/");
            fullUrl = fullUrl.replace("http://localhost", "http://localhost:8183");
        }
        
        log.info("URL générée par UploadService : {}", fullUrl);
        
        return fullUrl;
    } catch (IOException e) {
        throw new RuntimeException("Erreur lors de l'upload du fichier", e);
    }
}
```

### 3. Vérifier la configuration de server.url

**Dans `application.properties`**, s'assurer que :

```properties
# ✅ DOIT être exactement comme ça (avec le port)
server.url=http://localhost:8183

# ❌ NE DOIT PAS être :
# server.url=http://localhost/${server.port}
# server.url=http://localhost
```

### 4. Script SQL pour corriger les URLs existantes en base de données

Si des URLs sont déjà mal formées en base, exécuter ce script SQL :

```sql
-- Corriger les URLs mal formées dans la table utilisateurs
UPDATE utilisateurs 
SET url_photo = REPLACE(url_photo, 'http://localhost/8183/', 'http://localhost:8183/')
WHERE url_photo LIKE 'http://localhost/8183/%';

-- Vérifier les URLs corrigées
SELECT id, email, url_photo 
FROM utilisateurs 
WHERE url_photo IS NOT NULL;
```

## 🧪 Tests à effectuer

1. **Test upload** :
   - Uploader une nouvelle photo
   - Vérifier dans les logs que l'URL retournée contient `:8183`
   - Vérifier en base de données que l'URL sauvegardée est correcte

2. **Test rechargement profil** :
   - Après upload, appeler `/jeunes/profile`
   - Vérifier que l'URL retournée est `http://localhost:8183/uploads/photos/user_X.png`
   - **NE DOIT PAS être** `http://localhost/8183/uploads/photos/user_X.png`

3. **Test affichage** :
   - Les photos doivent s'afficher sans erreur CORS
   - Pas d'erreur 404

## 📝 Checklist

- [ ] `UploadService` retourne une URL avec le port
- [ ] Le contrôleur d'upload sauvegarde l'URL correcte en base
- [ ] `application.properties` contient `server.url=http://localhost:8183`
- [ ] Les URLs existantes en base sont corrigées (script SQL)
- [ ] Test upload : URL correcte retournée
- [ ] Test profil : URL correcte retournée après rechargement
- [ ] Test affichage : Photos s'affichent sans erreur

## 🔍 Vérification finale

Après correction, exécuter cette requête SQL pour vérifier :

```sql
SELECT id, email, url_photo 
FROM utilisateurs 
WHERE url_photo IS NOT NULL 
  AND url_photo NOT LIKE 'http://localhost:8183/%';
```

**Cette requête ne doit retourner AUCUN résultat** (toutes les URLs doivent commencer par `http://localhost:8183/`).


