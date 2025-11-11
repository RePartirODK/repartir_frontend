# Problème : Photo de profil ne s'affiche pas

Date : 11 novembre 2025

## 🐛 Symptômes

1. ✅ L'upload réussit (code 200)
2. ✅ Le fichier est sauvegardé sur le serveur
3. ❌ La photo ne s'affiche pas dans l'application
4. ❌ L'URL n'est pas visible en base de données (ou est un chemin local)

## 🔍 Diagnostic probable

### Le problème est côté **BACKEND**

Votre `UploadService` sauvegarde le fichier localement et retourne un **chemin de fichier** :

```java
Path filePath = directory.resolve(fileName + extension);
Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
return filePath.toString();  // ← Retourne "C:/Users/.../Desktop/uploads/photos/user_123.jpg"
```

Ce chemin est ensuite enregistré dans `utilisateur.urlPhoto` :

```java
String urlPhoto = uploadService.uploadFile(file, fileName, TypeFichier.PHOTO);
utilisateur.setUrlPhoto(urlPhoto);  // ← Enregistre "C:/Users/.../Desktop/uploads/photos/user_123.jpg"
```

### ❌ Pourquoi ça ne marche pas ?

Le frontend (navigateur web) **ne peut pas accéder** à un fichier local du serveur via un chemin comme `C:/Users/.../Desktop/uploads/photos/user_123.jpg`.

Il faut une **URL HTTP** accessible, par exemple :
- `http://localhost:8183/uploads/photos/user_123.jpg`
- Ou une URL cloud : `https://storage.example.com/photos/user_123.jpg`

## ✅ Solutions

### **Solution 1 : Servir les fichiers avec Spring Boot (Recommandé pour développement)**

#### 1.1 Créer une configuration pour servir les fichiers statiques

Créez un fichier `StaticResourceConfiguration.java` :

```java
package com.example.repartir_backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class StaticResourceConfiguration implements WebMvcConfigurer {

    @Value("${file.upload-dir:${user.home}/Desktop/uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Servir les fichiers du dossier uploads via /uploads/**
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + uploadDir + "/");
    }
}
```

#### 1.2 Modifier `UploadService` pour retourner une URL HTTP

```java
@Service
public class UploadService {
    
    @Value("${file.upload-dir:${user.home}/Desktop/uploads}")
    private String baseUploadDir;
    
    @Value("${server.url:http://localhost:8183}")
    private String serverUrl;  // ← Ajouter ceci

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
            
            // ✅ Retourner une URL HTTP au lieu d'un chemin local
            String relativeUrl = "/uploads/" + getFolderName(typefichier) + "/" + fileName + extension;
            return serverUrl + relativeUrl;
            
            // Exemple : "http://localhost:8183/uploads/photos/user_123.jpg"
            
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'upload du fichier", e);
        }
    }
    
    // ... reste du code
}
```

#### 1.3 Ajouter dans `application.properties`

```properties
# URL du serveur (à adapter selon l'environnement)
server.url=http://localhost:8183
```

---

### **Solution 2 : Utiliser un service de stockage cloud (Recommandé pour production)**

Pour la production, utilisez :
- **AWS S3**
- **Google Cloud Storage**
- **Azure Blob Storage**
- **MinIO** (auto-hébergé)

Exemple avec AWS S3 :

```java
@Service
public class S3UploadService {
    
    private final AmazonS3 s3Client;
    
    @Value("${aws.s3.bucket}")
    private String bucketName;
    
    public String uploadFile(MultipartFile file, String fileName) {
        String key = "photos/" + fileName;
        
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());
        
        s3Client.putObject(bucketName, key, file.getInputStream(), metadata);
        
        // Retourner l'URL publique
        return s3Client.getUrl(bucketName, key).toString();
    }
}
```

---

## 🧪 Comment vérifier

### 1. Vérifiez ce qui est enregistré en base de données

Connectez-vous à votre base de données et exécutez :

```sql
SELECT id, email, url_photo FROM utilisateurs WHERE email = 'Dembeleoumou846@gmail.com';
```

**Si vous voyez** :
- ❌ `C:\Users\...\Desktop\uploads\photos\user_123.jpg` → **Problème confirmé**
- ✅ `http://localhost:8183/uploads/photos/user_123.jpg` → **Bon format**

### 2. Vérifiez les logs frontend

Après l'upload, regardez la console :

```
✅ Photo uploadée avec succès: {...}
🔄 Rechargement du profil pour obtenir la nouvelle URL...
🖼️ URL photo récupérée: [REGARDEZ ICI]
🔄 Profil rechargé
```

### 3. Testez l'URL manuellement

Copiez l'URL affichée et collez-la dans votre navigateur. Si l'image s'affiche, l'URL est bonne.

---

## 📝 Checklist de correction

- [ ] Créer `StaticResourceConfiguration.java`
- [ ] Modifier `UploadService.uploadFile()` pour retourner une URL HTTP
- [ ] Ajouter `server.url` dans `application.properties`
- [ ] Redémarrer le backend
- [ ] Tester l'upload d'une nouvelle photo
- [ ] Vérifier les logs frontend (URL récupérée)
- [ ] Vérifier en base de données
- [ ] Tester l'URL dans le navigateur

---

## 🎯 Résultat attendu

Après correction :

```
📷 Upload de la photo...
✅ Photo uploadée avec succès: {message: Photo enregistrée avec succès : user_123.jpg, success: true}
🔄 Rechargement du profil pour obtenir la nouvelle URL...
🖼️ URL photo récupérée: http://localhost:8183/uploads/photos/user_123.jpg
🔄 Profil rechargé
```

Et la photo devrait s'afficher dans l'application ! 🎉

---

**Auteur** : Assistant AI  
**Date** : 11 novembre 2025, 00:15

