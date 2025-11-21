# Prompt Backend : Correction CORS et URLs des photos de profil

## 🎯 Objectif

**Les photos de profil doivent être visibles sur TOUTES les plateformes :**
- ✅ **Flutter Web** (navigateur)
- ✅ **Android** (émulateur et appareil physique)
- ✅ **iOS** (simulateur et appareil physique)

## 🐛 Problème actuel

L'application Flutter ne peut pas charger les images de profil à cause de deux problèmes :

### 1. Erreur CORS (Web uniquement)
```
Access to XMLHttpRequest at 'http://localhost/8183/uploads/photos/user_1.png' 
from origin 'http://localhost:57130' has been blocked by CORS policy: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

### 2. URL mal formée (Web et Mobile)
Le backend retourne des URLs comme : `http://localhost/8183/uploads/photos/user_1.png`
Mais il devrait retourner : `http://localhost:8183/uploads/photos/user_1.png` (avec le port)

**Pour Mobile :** Les URLs doivent être accessibles depuis l'appareil :
- **Android émulateur** : `http://10.0.2.2:8183/uploads/photos/user_1.png`
- **Android physique / iOS** : `http://[IP_SERVEUR]:8183/uploads/photos/user_1.png` ou un domaine accessible

## ✅ Solutions à implémenter

### Solution 1 : Configurer CORS pour les ressources statiques

Ajoutez une configuration CORS pour permettre l'accès aux fichiers statiques depuis le frontend web.

**Fichier : `CorsConfiguration.java` ou dans votre configuration existante**

```java
@Configuration
public class CorsConfiguration implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("http://localhost:57130", "http://localhost:8080", "http://localhost:3000")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
    
    // Configuration spécifique pour les ressources statiques
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:${file.upload-dir}/")
                .setCachePeriod(3600)
                .resourceChain(true);
    }
}
```

### Solution 2 : Corriger les URLs retournées par UploadService

**Fichier : `UploadService.java`**

Le service doit retourner des URLs complètes avec le port correct. **IMPORTANT** : Les URLs doivent être accessibles depuis toutes les plateformes (Web, Android, iOS).

```java
@Service
public class UploadService {
    
    @Value("${file.upload-dir:${user.home}/Desktop/uploads}")
    private String baseUploadDir;
    
    // URL pour Web (localhost avec port)
    @Value("${server.url.web:http://localhost:8183}")
    private String serverUrlWeb;
    
    // URL pour Mobile (peut être la même ou une IP accessible)
    @Value("${server.url.mobile:http://localhost:8183}")
    private String serverUrlMobile;
    
    /**
     * Retourne l'URL complète de l'image uploadée
     * @param fileName Nom du fichier
     * @param typefichier Type de fichier (PHOTO, etc.)
     * @param isWeb true si la requête vient du web, false pour mobile
     * @return URL complète accessible depuis la plateforme
     */
    public String uploadFile(MultipartFile file, String fileName, TypeFichier typefichier, boolean isWeb){
        try{
            Path directory = Paths.get(baseUploadDir, getFolderName(typefichier));
            Files.createDirectories(directory);
            
            String extension;
            if(typefichier == TypeFichier.PHOTO) {
                extension = getFileExtension(file.getOriginalFilename()).orElse("");
            } else {
                extension = ".pdf";
            }
            
            Path filePath = directory.resolve(fileName + extension);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // ✅ Retourner une URL HTTP complète avec le port
            String relativeUrl = "/uploads/" + getFolderName(typefichier) + "/" + fileName + extension;
            
            // Utiliser l'URL appropriée selon la plateforme
            String baseUrl = isWeb ? serverUrlWeb : serverUrlMobile;
            String fullUrl = baseUrl + relativeUrl;
            
            // Vérifier que l'URL contient bien le port
            if (!fullUrl.contains(":8183") && baseUrl.contains("localhost")) {
                fullUrl = fullUrl.replace("http://localhost/", "http://localhost:8183/");
            }
            
            return fullUrl;
            // Exemples :
            // Web : "http://localhost:8183/uploads/photos/user_123.jpg"
            // Mobile : "http://192.168.1.100:8183/uploads/photos/user_123.jpg"
            
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'upload du fichier", e);
        }
    }
    
    // Méthode de compatibilité (utilise Web par défaut)
    public String uploadFile(MultipartFile file, String fileName, TypeFichier typefichier) {
        return uploadFile(file, fileName, typefichier, true);
    }
    
    // ... reste du code
}
```

**Alternative plus simple** : Utiliser une seule URL accessible depuis toutes les plateformes :

```java
@Service
public class UploadService {
    
    @Value("${file.upload-dir:${user.home}/Desktop/uploads}")
    private String baseUploadDir;
    
    // URL accessible depuis Web et Mobile
    // Pour développement : utiliser l'IP locale (ex: 192.168.1.100:8183)
    // Pour production : utiliser un domaine (ex: https://api.example.com)
    @Value("${server.url:http://localhost:8183}")
    private String serverUrl;
    
    public String uploadFile(MultipartFile file, String fileName, TypeFichier typefichier){
        try{
            Path directory = Paths.get(baseUploadDir, getFolderName(typefichier));
            Files.createDirectories(directory);
            
            String extension;
            if(typefichier == TypeFichier.PHOTO) {
                extension = getFileExtension(file.getOriginalFilename()).orElse("");
            } else {
                extension = ".pdf";
            }
            
            Path filePath = directory.resolve(fileName + extension);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // ✅ Retourner une URL HTTP complète avec le port
            String relativeUrl = "/uploads/" + getFolderName(typefichier) + "/" + fileName + extension;
            String fullUrl = serverUrl + relativeUrl;
            
            // Vérifier que l'URL contient bien le port
            if (!fullUrl.contains(":8183") && serverUrl.contains("localhost")) {
                fullUrl = fullUrl.replace("http://localhost/", "http://localhost:8183/");
            }
            
            return fullUrl;
            
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'upload du fichier", e);
        }
    }
}
```

### Solution 3 : Ajouter dans `application.properties`

**Pour développement local :**

```properties
# URL du serveur (DOIT inclure le port)
# Pour Web : localhost fonctionne
# Pour Mobile : utiliser l'IP locale de votre machine (ex: 192.168.1.100)
server.url=http://localhost:8183

# Alternative : URLs séparées pour Web et Mobile
# server.url.web=http://localhost:8183
# server.url.mobile=http://192.168.1.100:8183

# Dossier d'upload
file.upload-dir=${user.home}/Desktop/uploads
```

**Pour production :**

```properties
# Utiliser un domaine accessible depuis toutes les plateformes
server.url=https://api.votredomaine.com

# Dossier d'upload
file.upload-dir=/var/uploads
```

**Note importante pour Mobile :**
- Sur **Android émulateur**, utiliser `http://10.0.2.2:8183` (le frontend Flutter gère cela automatiquement)
- Sur **appareil physique** (Android/iOS), utiliser l'IP locale de votre machine (ex: `http://192.168.1.100:8183`)
- En **production**, utiliser un domaine accessible (ex: `https://api.example.com`)

### Solution 4 : Vérifier que les endpoints retournent les bonnes URLs

Vérifiez que tous les endpoints qui retournent des données avec `urlPhoto` utilisent bien l'URL complète :

- ✅ `/jeunes/profile` → `utilisateur.urlPhoto`
- ✅ `/mentors/profile` → `utilisateur.urlPhoto`
- ✅ `/entreprises/profile` → `urlPhotoEntreprise` ou `utilisateur.urlPhoto`
- ✅ `/centres/profile` → `urlPhoto` ou `utilisateur.urlPhoto`
- ✅ Tous les endpoints de listes (mentorings, offres, formations) qui incluent des photos

## 🧪 Tests à effectuer

### Tests Web
1. **Test CORS** : Ouvrez la console du navigateur et vérifiez qu'il n'y a plus d'erreurs CORS
2. **Test URL** : Vérifiez dans la base de données que les URLs sont au format `http://localhost:8183/uploads/...`
3. **Test affichage** : Les photos doivent s'afficher dans l'application Flutter Web

### Tests Mobile
1. **Android émulateur** : Les photos doivent s'afficher (le frontend utilise automatiquement `10.0.2.2:8183`)
2. **Appareil physique Android/iOS** : 
   - Vérifiez que l'appareil est sur le même réseau WiFi que le serveur
   - Utilisez l'IP locale du serveur dans `server.url` (ex: `http://192.168.1.100:8183`)
   - Testez que les photos s'affichent correctement
3. **Production** : Les photos doivent être accessibles via le domaine de production

## 📝 Checklist

- [ ] Configuration CORS ajoutée pour les ressources statiques
- [ ] `UploadService` retourne des URLs avec le port correct
- [ ] `application.properties` contient `server.url=http://localhost:8183` (ou IP accessible pour mobile)
- [ ] Tous les endpoints retournent des URLs complètes
- [ ] **Testé avec Flutter Web** sur `http://localhost:57130` ✅
- [ ] **Testé avec Android émulateur** ✅
- [ ] **Testé avec appareil physique Android/iOS** (si applicable) ✅

## 🔍 Vérification

Après correction, les URLs en base de données doivent être au format :
```
http://localhost:8183/uploads/photos/user_1.png
```

Et non pas :
```
http://localhost/uploads/photos/user_1.png  ❌
C:/Users/.../Desktop/uploads/photos/user_1.png  ❌
```

