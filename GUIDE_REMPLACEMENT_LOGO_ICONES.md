# Guide de Remplacement du Logo et des Icônes de l'Application

## ✅ Modifications Effectuées

### 1. Splash Screen (Écran de Démarrage)
Le fichier `lib/pages/shared/splash_screen.dart` a été modifié pour afficher le logo RePartir (`assets/images/logo_repartir.png`) au lieu du logo Flutter par défaut.

**Ce qui a été fait :**
- Affichage du logo RePartir centré sur l'écran
- Ajout d'un indicateur de chargement stylisé
- Ajout du texte "RePartir" sous le logo
- Design moderne avec ombre et bordures arrondies

### 2. Icônes de l'Application (Android & iOS) ✅
Les icônes de l'application ont été générées automatiquement à partir du logo RePartir.

**Ce qui a été fait :**
- ✅ Package `flutter_launcher_icons` ajouté et configuré dans `pubspec.yaml`
- ✅ Icônes Android générées dans toutes les tailles nécessaires (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Icônes adaptatives Android créées (avec fond blanc)
- ✅ Icônes iOS générées dans toutes les tailles nécessaires
- ✅ Fichier `colors.xml` créé pour Android avec la couleur de fond blanche

**Pour voir les nouvelles icônes :**
- Reconstruisez l'application : `flutter build apk` (Android) ou `flutter build ios` (iOS)
- Ou exécutez l'application en mode release sur un appareil réel

## 📱 Remplacement des Icônes de l'Application

Pour remplacer les icônes de l'application (l'icône qui apparaît sur l'écran d'accueil du téléphone), vous devez suivre ces étapes :

### Pour Android

1. **Préparer les images :**
   - Créez des versions de votre logo `logo_repartir.png` aux tailles suivantes :
     - `mipmap-mdpi`: 48x48 pixels
     - `mipmap-hdpi`: 72x72 pixels
     - `mipmap-xhdpi`: 96x96 pixels
     - `mipmap-xxhdpi`: 144x144 pixels
     - `mipmap-xxxhdpi`: 192x192 pixels

2. **Remplacer les fichiers :**
   - Remplacez les fichiers dans `android/app/src/main/res/` :
     - `mipmap-mdpi/ic_launcher.png`
     - `mipmap-hdpi/ic_launcher.png`
     - `mipmap-xhdpi/ic_launcher.png`
     - `mipmap-xxhdpi/ic_launcher.png`
     - `mipmap-xxxhdpi/ic_launcher.png`

3. **Alternative : Utiliser un package Flutter (Recommandé)**
   - Installez le package `flutter_launcher_icons` :
     ```yaml
     dev_dependencies:
       flutter_launcher_icons: ^0.13.1
     ```
   - Ajoutez la configuration dans `pubspec.yaml` :
     ```yaml
     flutter_launcher_icons:
       android: true
       ios: true
       image_path: "assets/images/logo_repartir.png"
       adaptive_icon_background: "#FFFFFF"
       adaptive_icon_foreground: "assets/images/logo_repartir.png"
     ```
   - Exécutez : `flutter pub get` puis `flutter pub run flutter_launcher_icons`

### Pour iOS

1. **Préparer les images :**
   - Créez des versions de votre logo aux tailles suivantes :
     - 20x20, 29x29, 40x40, 58x58, 60x60, 76x76, 80x80, 87x87, 120x120, 152x152, 167x167, 180x180, 1024x1024 pixels

2. **Remplacer les fichiers :**
   - Les icônes iOS sont dans `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Remplacez les fichiers PNG correspondants

3. **Alternative : Utiliser flutter_launcher_icons (Recommandé)**
   - La même configuration dans `pubspec.yaml` fonctionne pour iOS aussi

### Pour Web

1. **Favicon :**
   - Remplacez `web/favicon.png` par votre logo (32x32 ou 64x64 pixels)

2. **Icônes PWA :**
   - Remplacez les fichiers dans `web/icons/` :
     - `Icon-192.png` (192x192)
     - `Icon-512.png` (512x512)
     - `Icon-maskable-192.png` (192x192)
     - `Icon-maskable-512.png` (512x512)

### Pour Windows

1. **Icône :**
   - Remplacez `windows/runner/resources/app_icon.ico` par votre logo au format `.ico`

## 🎨 Configuration du Splash Screen Natif Android (Optionnel)

Pour afficher votre logo pendant le chargement natif Android (avant que Flutter ne démarre), vous pouvez :

1. **Créer une image de lancement :**
   - Créez une image `launch_image.png` (recommandé : 1080x1920 pixels)
   - Placez-la dans `android/app/src/main/res/mipmap-xxxhdpi/`

2. **Modifier `launch_background.xml` :**
   - Décommentez et modifiez les lignes dans `android/app/src/main/res/drawable/launch_background.xml` :
     ```xml
     <item>
         <bitmap
             android:gravity="center"
             android:src="@mipmap/launch_image" />
     </item>
     ```

## 📝 Notes Importantes

- Le logo doit être carré pour les icônes d'application
- Pour Android, utilisez un fond transparent ou blanc
- Pour iOS, les icônes sont automatiquement arrondies par le système
- Après avoir remplacé les icônes, vous devrez reconstruire l'application :
  - Android : `flutter build apk` ou `flutter build appbundle`
  - iOS : `flutter build ios`
  - Web : `flutter build web`

## 🚀 Méthode Rapide (Recommandée)

La méthode la plus simple est d'utiliser le package `flutter_launcher_icons` qui génère automatiquement toutes les tailles nécessaires à partir d'une seule image source.

