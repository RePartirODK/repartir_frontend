# Endpoints Backend Manquants - Espace Jeune

Date : 10 novembre 2025

## 🚨 ENDPOINTS CRITIQUES MANQUANTS

### 1. Upload de Photo de Profil ✅ IMPLÉMENTÉ

**Endpoint** : `POST /api/utilisateurs/photoprofil`

**Authentification** : Bearer Token (Jeune)

**Content-Type** : `multipart/form-data`

**Paramètres** :
- `file` : MultipartFile (image JPG, JPEG, PNG)
- `email` : String (email de l'utilisateur)

**Réponse** :
```
"Photo enregistrée avec succès : user_123.jpg"
```

**Notes** :
- ✅ **DÉJÀ IMPLÉMENTÉ côté backend**
- ✅ **DÉJÀ INTÉGRÉ côté frontend**
- Le backend valide le format (JPG, JPEG, PNG uniquement)
- Taille maximale : 10MB (défini dans `application.properties`)
- Le fichier est sauvegardé localement dans `${user.home}/Desktop/uploads/photos/`
- Le nom du fichier est généré : `user_{utilisateurId}.{extension}`
- Le champ `utilisateur.urlPhoto` est mis à jour avec le chemin complet

**Frontend** :
- Envoie le fichier directement en `multipart/form-data`
- Utilise `http.MultipartRequest` avec le fichier en bytes
- Ajoute automatiquement l'`Authorization: Bearer {token}`

---

### 2. Demande de Mentorat ✅ IMPLÉMENTÉ

**Endpoint** : `POST /api/mentorings/create/{idMentor}/{idJeune}`

**Authentification** : Bearer Token (Jeune)

**Path Parameter** :
- `mentorId` : ID du mentor

**Body** (optionnel) :
```json
{
  "message": "Bonjour, je souhaiterais bénéficier de votre accompagnement pour..."
}
```

**Réponse** :
```json
{
  "id": 123,
  "mentorId": 5,
  "jeuneId": 42,
  "statut": "EN_ATTENTE",
  "dateCreation": "2025-11-10T23:30:00",
  "message": "Bonjour, je souhaiterais..."
}
```

**Statuts possibles** :
- `EN_ATTENTE` : Demande envoyée
- `ACCEPTEE` : Mentor a accepté
- `REFUSEE` : Mentor a refusé
- `ANNULEE` : Jeune a annulé

**Page concernée** : `mentor_detail_page.dart` - bouton "Demander à être mentoré"

---

## ✅ ENDPOINTS DÉJÀ INTÉGRÉS (À NE PAS CRÉER)

### Authentification
- ✅ `POST /auth/login`
- ✅ `POST /auth/refresh`
- ✅ `POST /auth/logout`

### Profil Jeune
- ✅ `GET /jeunes/profile`
- ✅ `PUT /jeunes/modifier`

### Offres d'Emploi
- ✅ `GET /offres/lister`
- ✅ `GET /offres/{id}`

### Centres de Formation
- ✅ `GET /centres`
- ✅ `GET /centres/actifs`
- ✅ `GET /centres/{id}`
- ✅ `GET /centres/{id}/formations`

### Formations
- ✅ `GET /formations`
- ✅ `GET /formations/centre/{centreId}`
- ✅ `GET /formations/{id}`

### Inscriptions
- ✅ `POST /inscriptions/s-inscrire/{formationId}`
- ✅ `GET /inscriptions/mes-inscriptions`

### Mentors
- ✅ `GET /mentors`
- ✅ `GET /mentors/{id}`
- ✅ `GET /mentors/mes-mentors`

---

## 📋 FONCTIONNALITÉS À LAISSER DE CÔTÉ (DEMANDE UTILISATEUR)

### Messagerie / Chat
- ❌ `GET /messages/conversations`
- ❌ `GET /messages/conversations/{id}`
- ❌ `POST /messages/conversations/{id}/messages`

**Raison** : À implémenter plus tard

### Notifications
- ❌ `GET /notifications`
- ❌ `PUT /notifications/{id}/lire`
- ❌ `DELETE /notifications/{id}`

**Raison** : À implémenter plus tard

### CV et Compétences
- ❌ `POST /profil/cv`
- ❌ `GET /profil/competences`
- ❌ `POST /profil/competences`

**Raison** : Hors scope (demande explicite de l'utilisateur)

---

## 🔧 RECOMMANDATIONS TECHNIQUES BACKEND

### 1. Upload de Photo

**Option A : Stockage en Base de Données (Simple)**
```java
@PutMapping("/modifier-photo")
public ResponseEntity<?> modifierPhoto(@RequestBody PhotoDto dto, Principal principal) {
    String email = principal.getName();
    Jeune jeune = jeuneRepository.findByEmail(email);
    
    // Décoder Base64
    byte[] photoBytes = Base64.getDecoder().decode(dto.getPhotoBase64());
    
    // Valider taille (< 5MB)
    if (photoBytes.length > 5 * 1024 * 1024) {
        throw new BadRequestException("Photo trop volumineuse (max 5MB)");
    }
    
    // Sauvegarder en BLOB ou générer URL data:image
    String dataUrl = "data:image/jpeg;base64," + dto.getPhotoBase64();
    jeune.getUtilisateur().setUrlPhoto(dataUrl);
    
    utilisateurRepository.save(jeune.getUtilisateur());
    
    return ResponseEntity.ok(Map.of(
        "message", "Photo mise à jour",
        "urlPhoto", dataUrl
    ));
}
```

**Option B : Stockage Cloud (Recommandé pour production)**
```java
@PutMapping("/modifier-photo")
public ResponseEntity<?> modifierPhoto(@RequestBody PhotoDto dto, Principal principal) {
    String email = principal.getName();
    Jeune jeune = jeuneRepository.findByEmail(email);
    
    byte[] photoBytes = Base64.getDecoder().decode(dto.getPhotoBase64());
    
    // Upload vers S3, Google Cloud Storage, Azure Blob, etc.
    String photoUrl = storageService.uploadPhoto(photoBytes, "jeune_" + jeune.getId());
    
    jeune.getUtilisateur().setUrlPhoto(photoUrl);
    utilisateurRepository.save(jeune.getUtilisateur());
    
    return ResponseEntity.ok(Map.of(
        "message", "Photo mise à jour",
        "urlPhoto", photoUrl
    ));
}
```

**DTO** :
```java
public class PhotoDto {
    @NotBlank
    private String photoBase64;
    
    // getters/setters
}
```

**Important** : Le champ `urlPhoto` en base de données doit être de type `TEXT` ou `LONGTEXT` si vous stockez en data URL.

---

### 2. Demande de Mentorat

**Entité** :
```java
@Entity
@Table(name = "demandes_mentorat")
public class DemandeMentorat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "mentor_id", nullable = false)
    private Mentor mentor;
    
    @ManyToOne
    @JoinColumn(name = "jeune_id", nullable = false)
    private Jeune jeune;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutDemande statut = StatutDemande.EN_ATTENTE;
    
    @Column(columnDefinition = "TEXT")
    private String message;
    
    @CreationTimestamp
    private LocalDateTime dateCreation;
    
    // getters/setters
}

public enum StatutDemande {
    EN_ATTENTE, ACCEPTEE, REFUSEE, ANNULEE
}
```

**Contrôleur** :
```java
@PostMapping("/mentors/{mentorId}/demande-mentorat")
public ResponseEntity<?> demanderMentorat(
    @PathVariable Long mentorId,
    @RequestBody(required = false) DemandeDto dto,
    Principal principal
) {
    String email = principal.getName();
    Jeune jeune = jeuneRepository.findByEmail(email);
    Mentor mentor = mentorRepository.findById(mentorId)
        .orElseThrow(() -> new NotFoundException("Mentor non trouvé"));
    
    // Vérifier si une demande existe déjà
    Optional<DemandeMentorat> existante = demandeRepository
        .findByJeuneAndMentorAndStatut(jeune, mentor, StatutDemande.EN_ATTENTE);
    
    if (existante.isPresent()) {
        throw new BadRequestException("Vous avez déjà une demande en cours avec ce mentor");
    }
    
    DemandeMentorat demande = new DemandeMentorat();
    demande.setJeune(jeune);
    demande.setMentor(mentor);
    demande.setStatut(StatutDemande.EN_ATTENTE);
    demande.setMessage(dto != null ? dto.getMessage() : "");
    
    demande = demandeRepository.save(demande);
    
    // TODO: Envoyer notification au mentor
    
    return ResponseEntity.ok(demande);
}
```

---

## 📊 RÉSUMÉ

| Fonctionnalité | Endpoint | Statut | Priorité |
|---------------|----------|--------|----------|
| Upload photo | `POST /utilisateurs/photoprofil` | ✅ **FAIT** | ✅ Terminé |
| Demande mentorat | `POST /mentorings/create/{idM}/{idJ}` | ✅ **FAIT** | ✅ Terminé |
| Mes mentors | `GET /mentorings/jeune/{idJeune}` | ✅ **FAIT** | ✅ Terminé |
| Notifications | Basé sur mentorings | ✅ **FAIT** | ✅ Terminé |
| Messagerie | Multiple | ⏸️ Report | ⚪ Plus tard |

---

## ✅ PROCHAINES ÉTAPES

1. ✅ ~~Implémenter `POST /utilisateurs/photoprofil`~~ **FAIT**
2. ✅ ~~Intégrer l'upload de photo frontend~~ **FAIT**
3. ✅ ~~Implémenter `POST /mentorings/create/{idM}/{idJ}`~~ **FAIT**
4. ✅ ~~Intégrer la demande de mentorat frontend~~ **FAIT**
5. ✅ ~~Intégrer "Mes mentors" frontend~~ **FAIT**
6. **Tester l'upload de photo** (problème d'affichage URL - voir docs/probleme_photo_profil.md)
7. **Tester la demande de mentorat** et "Mes mentors"

**TOUS les endpoints nécessaires sont maintenant intégrés !** 🎉🎉🎉

**Reste à faire** : Corrections backend pour affichage photos (servir fichiers en HTTP)

---

**Auteur** : Assistant AI  
**Dernière mise à jour** : 10 novembre 2025, 23:30

