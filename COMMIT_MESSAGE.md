feat(jeune): Intégration complète des APIs backend + upload photo

## 🎯 Intégration Majeure Module Jeune

### Pages Intégrées (5)
- ✅ `profil_page.dart` : Affichage du profil via API GET /api/jeunes/profile
- ✅ `edit_profil_page.dart` : Modification du profil + upload photo caméra/galerie
- ✅ `offre_list_page.dart` : Liste des offres d'emploi via API GET /api/offres/lister
- ✅ `detail_offre_commune_page.dart` : Détails offre via API GET /api/offres/{id}
- ✅ `mes_formations_page.dart` : Mes inscriptions via API GET /api/inscriptions/mes-inscriptions

### Services Créés (7)
- ✅ `JeuneService` : Profil, modification, upload photo
- ✅ `OffreService` : Liste et détails offres
- ✅ `FormationService` : Mes inscriptions
- ✅ `MentorService` : CRUD mentors/mentorings (prêt)
- ✅ `CentreService` : CRUD centres (prêt)
- ✅ `NotificationService` : Notifications (prêt)
- ✅ `ApiConfig` : Configuration centralisée API

### Modèles Créés (8)
- ✅ `JeuneProfil` : Profil jeune complet
- ✅ `OffreEmploi` : Modèle offre d'emploi
- ✅ `Formation` : Modèle formation
- ✅ `InscriptionResponse` : Modèle inscription détaillée
- ✅ `Mentor` : Modèle mentor
- ✅ `Mentoring` : Modèle mentoring
- ✅ `Centre` : Modèle centre
- ✅ `Notification` : Modèle notification

### Nouvelles Fonctionnalités
- 📸 **Upload Photo de Profil** (caméra + galerie)
- 🔒 **Permissions Android/iOS** configurées
- 🌐 **Gestion web** (message informatif)
- ⚡ **États loading/erreur/vide** sur toutes les pages
- 🔄 **Rechargement automatique** après modifications

### Packages Ajoutés
- `image_picker: ^1.2.0` pour l'upload photo

### Configuration
- Permissions Android: CAMERA, READ/WRITE_EXTERNAL_STORAGE
- Permissions iOS: NSCameraUsageDescription, NSPhotoLibraryUsageDescription
- Détection web pour limiter fonctionnalités non supportées

### Corrections
- ✅ Fix navigation JEUNE dans main.dart
- ✅ Fix navigation ENTREPRISE dans main.dart
- ✅ Gestion erreurs Lazy Loading backend
- ✅ Modèles mis à jour selon APIs backend

### Tests
- ✅ Profil: Affichage et modification fonctionnels
- ✅ Offres: Liste et détails fonctionnels
- ✅ Formations: Mes inscriptions fonctionnelles
- ✅ Upload photo: Fonctionnel sur mobile, message web

### Documentation
- 📄 `STATUT_INTEGRATION_COMPLET.md` : État détaillé
- 📄 `ANALYSE_BACKEND_FRONTEND.md` : Analyse complète
- 📄 `MESSAGE_ERREUR_BACKEND.md` : Solutions Lazy Loading
- 📄 `PROMPT_CURSOR_BACKEND.md` : Prompt pour backend

## 📊 Statistiques
- **Pages intégrées avec API** : 5 sur ~14
  - ✅ Profil (affichage + modification + upload photo)
  - ✅ Liste offres d'emploi
  - ✅ Détail offre d'emploi
  - ✅ Mes formations
  - ❌ **Pages statiques** : Mentors, Formations, Centres, Chat
- **Services API** : 7/7
- **Modèles créés** : 8
- **Endpoints utilisés** : 8
- **Nouvelles fonctionnalités** : 5
- **Erreurs corrigées** : 4
- **Lignes de code** : ~1500

## 🚀 Impact
- Module Jeune partiellement opérationnel avec APIs réelles
- 5 pages fonctionnelles avec données backend
- Base solide pour intégration des pages restantes (mentors, formations, centres, chat)
- Architecture scalable et maintenable
- Upload photo opérationnel sur mobile

## 📌 Pages Restantes (Statiques)
À intégrer dans un futur commit :
- Mentors (liste + détails)
- Formations (liste + détails + inscription)
- Centres de formation (liste + détails)
- Chat (WebSocket/STOMP)
