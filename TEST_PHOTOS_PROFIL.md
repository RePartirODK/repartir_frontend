# Guide de Test : Photos de Profil

## ✅ Corrections Backend Effectuées

Le backend a été corrigé avec succès :
- ✅ `application.properties` : URL complète avec port
- ✅ `SecurityConfig.java` : CORS amélioré (OPTIONS, cache)
- ✅ `UploadService.java` : Validation et correction automatique des URLs
- ✅ Configurations ressources statiques : Cache et CORS pour `/uploads/**`

## 🧪 Tests à Effectuer

### 1. Test Flutter Web

1. **Redémarrer le serveur Spring Boot** si ce n'est pas déjà fait
2. **Lancer l'application Flutter Web** :
   ```bash
   flutter run -d chrome
   ```
3. **Vérifier dans la console du navigateur** :
   - Ouvrir les DevTools (F12)
   - Onglet Console
   - **Ne doit plus y avoir d'erreurs CORS** ❌
   - Les requêtes vers `/uploads/photos/...` doivent retourner 200 ✅

4. **Tester l'affichage des photos** :
   - Se connecter en tant que **Jeune** → Vérifier la photo de profil
   - Se connecter en tant que **Mentor** → Vérifier la photo de profil et les photos des jeunes
   - Se connecter en tant que **Entreprise** → Vérifier la photo de profil
   - Se connecter en tant que **Centre** → Vérifier la photo de profil

5. **Tester l'upload de photo** :
   - Aller dans "Modifier le profil"
   - Uploader une nouvelle photo
   - Vérifier que la photo s'affiche immédiatement après l'upload
   - Vérifier dans la base de données que l'URL est au format : `http://localhost:8183/uploads/photos/user_X.jpg`

### 2. Test Android Émulateur

1. **Lancer l'émulateur Android**
2. **Lancer l'application Flutter** :
   ```bash
   flutter run
   ```
   (Sélectionner l'émulateur Android)

3. **Vérifier que les photos s'affichent** :
   - Le frontend utilise automatiquement `10.0.2.2:8183` pour l'émulateur
   - Tester l'affichage des photos de profil
   - Tester l'upload de photo

### 3. Test Appareil Physique (Android/iOS)

**Important** : Pour tester sur un appareil physique, vous devez modifier `application.properties` :

```properties
# Trouver l'IP locale de votre machine :
# Windows : ipconfig
# Mac/Linux : ifconfig ou ip addr

# Exemple (remplacer par votre IP) :
server.url=http://192.168.1.100:8183
```

**Étapes** :
1. Trouver l'IP locale de votre machine :
   - **Windows** : Ouvrir CMD → `ipconfig` → Chercher "IPv4 Address"
   - **Mac/Linux** : Terminal → `ifconfig` ou `ip addr`

2. Modifier `application.properties` dans le backend :
   ```properties
   server.url=http://[VOTRE_IP]:8183
   ```
   Exemple : `server.url=http://192.168.1.100:8183`

3. **Redémarrer le serveur Spring Boot**

4. **S'assurer que l'appareil est sur le même réseau WiFi** que votre machine

5. **Lancer l'application Flutter** sur l'appareil :
   ```bash
   flutter run
   ```
   (Sélectionner l'appareil physique)

6. **Tester** :
   - Affichage des photos de profil
   - Upload de nouvelles photos

## 🔍 Vérifications dans la Base de Données

Après un upload de photo, vérifier que l'URL enregistrée est correcte :

```sql
-- Vérifier les URLs de photos
SELECT id, email, url_photo FROM utilisateurs WHERE url_photo IS NOT NULL;

-- Les URLs doivent être au format :
-- ✅ http://localhost:8183/uploads/photos/user_X.jpg
-- ✅ http://192.168.1.100:8183/uploads/photos/user_X.jpg (pour mobile)

-- ❌ NE DOIT PAS être :
-- http://localhost/uploads/photos/user_X.jpg (sans port)
-- C:/Users/.../Desktop/uploads/photos/user_X.jpg (chemin local)
```

## 🐛 Dépannage

### Problème : Erreur CORS toujours présente (Web)

**Solution** :
1. Vérifier que `SecurityConfig.java` contient bien la configuration CORS
2. Vérifier que les origines autorisées incluent `http://localhost:57130`
3. Redémarrer le serveur Spring Boot
4. Vider le cache du navigateur (Ctrl+Shift+Delete)

### Problème : Photos ne s'affichent pas (Mobile)

**Solution** :
1. Vérifier que l'appareil est sur le même réseau WiFi
2. Vérifier que l'IP dans `application.properties` est correcte
3. Tester l'URL directement dans le navigateur de l'appareil :
   - `http://[IP]:8183/uploads/photos/user_X.jpg`
4. Vérifier que le firewall n'bloque pas le port 8183

### Problème : URL mal formée en base de données

**Solution** :
1. Vérifier que `UploadService.java` contient la validation du port
2. Vérifier que `application.properties` contient `server.url=http://localhost:8183`
3. Redémarrer le serveur et réessayer l'upload

## ✅ Checklist de Validation

- [ ] Serveur Spring Boot redémarré après les modifications
- [ ] **Web** : Pas d'erreurs CORS dans la console
- [ ] **Web** : Photos s'affichent correctement
- [ ] **Web** : Upload de photo fonctionne
- [ ] **Android émulateur** : Photos s'affichent
- [ ] **Appareil physique** : IP configurée et photos s'affichent (si testé)
- [ ] **Base de données** : URLs au bon format
- [ ] Tous les acteurs peuvent voir/modifier leurs photos de profil

## 📝 Notes

- Les photos doivent être visibles **immédiatement** après l'upload
- Si une photo ne s'affiche pas, l'icône par défaut doit apparaître (personne pour jeunes/mentors, building pour entreprises/centres)
- Le widget `ProfileAvatar` gère automatiquement les erreurs et affiche l'icône par défaut en cas de problème


