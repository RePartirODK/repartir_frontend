# PROMPT BACKEND - Upload Photo Entreprise

Bonjour,

Le frontend envoie correctement la photo via l'endpoint `/api/utilisateurs/photoprofil`, mais le champ `urlPhotoEntreprise` reste `null` dans la réponse de `/api/entreprises/profile`.

## Problème

Après l'upload d'une photo de profil par une entreprise, le backend ne met pas à jour le champ `urlPhotoEntreprise` de l'entité Entreprise.

```json
// Réponse actuelle de /entreprises/profile
{
  "id": 2,
  "nom": "OKLM",
  "email": "entre@gmail.com",
  "urlPhotoEntreprise": null,  // ❌ Reste null après upload
  "secteurActivite": null,
  "adresse": "456 Avenue des Entreprises, 69000 Lyon",
  "telephone": "01937766",
  "description": null
}
```

## Solution requise

### 1. Vérifier l'endpoint d'upload de photo

Dans le contrôleur `UtilisateurController` (ou similaire), l'endpoint `POST /utilisateurs/photoprofil` doit :

1. Recevoir le fichier et l'email
2. Identifier le type d'utilisateur (Entreprise, Jeune, Mentor, etc.)
3. Sauvegarder le fichier
4. **Mettre à jour le champ `urlPhotoEntreprise` dans la base de données**

### Exemple de code Java

```java
@PostMapping("/photoprofil")
public ResponseEntity<String> uploadPhoto(
    @RequestParam("file") MultipartFile file,
    @RequestParam("email") String email
) {
    try {
        // 1. Sauvegarder le fichier
        String fileName = fileStorageService.storeFile(file);
        String fileUrl = "http://localhost:8183/uploads/" + fileName;
        
        // 2. Chercher l'entreprise par email
        Optional<Entreprise> entrepriseOpt = entrepriseRepository.findByEmail(email);
        
        if (entrepriseOpt.isPresent()) {
            Entreprise entreprise = entrepriseOpt.get();
            
            // 3. Mettre à jour l'URL de la photo
            entreprise.setUrlPhotoEntreprise(fileUrl);
            entrepriseRepository.save(entreprise);
            
            return ResponseEntity.ok("Photo mise à jour avec succès");
        }
        
        // Gérer aussi les autres types d'utilisateurs (Jeune, Mentor)
        // ... code similaire pour Jeune et Mentor
        
        return ResponseEntity.badRequest().body("Utilisateur non trouvé");
        
    } catch (Exception e) {
        return ResponseEntity.status(500).body("Erreur lors de l'upload: " + e.getMessage());
    }
}
```

### 2. Vérifier l'entité Entreprise

Assurez-vous que l'entité `Entreprise` a bien le champ :

```java
@Entity
public class Entreprise {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String nom;
    private String email;
    private String urlPhotoEntreprise;  // ✅ Ce champ doit exister
    private String secteurActivite;
    private String adresse;
    private String telephone;
    private String description;
    
    // Getters et Setters
}
```

### 3. Vérifier le repository

```java
public interface EntrepriseRepository extends JpaRepository<Entreprise, Long> {
    Optional<Entreprise> findByEmail(String email);
}
```

## Réponse attendue après correction

Après l'upload de la photo, l'endpoint `/entreprises/profile` devrait retourner :

```json
{
  "id": 2,
  "nom": "OKLM",
  "email": "entre@gmail.com",
  "urlPhotoEntreprise": "http://localhost:8183/uploads/profile_entreprise_2_1234567890.jpg",  // ✅
  "secteurActivite": null,
  "adresse": "456 Avenue des Entreprises, 69000 Lyon",
  "telephone": "01937766",
  "description": null
}
```

## Note importante

Cette même logique doit fonctionner pour :
- ✅ Jeunes → `urlPhotoJeune` 
- ✅ Mentors → `urlPhotoMentor`
- ⚠️ Entreprises → `urlPhotoEntreprise` (à corriger)

Merci de corriger ce problème pour que les entreprises puissent voir leur photo de profil après l'upload ! 🙏


