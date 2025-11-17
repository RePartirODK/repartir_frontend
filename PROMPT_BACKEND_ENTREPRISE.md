# PROMPT BACKEND - Endpoint Entreprise Profile

Bonjour,

Le frontend tente d'accéder à l'endpoint **`GET /api/entreprises/profile`** pour récupérer le profil de l'entreprise connectée, mais cet endpoint n'existe pas encore et renvoie une erreur 500.

## Besoin : Créer l'endpoint GET `/entreprises/profile`

Cet endpoint doit fonctionner de la même manière que `/jeunes/profile` et `/mentors/profile`.

### Spécifications

**Route :** `GET /api/entreprises/profile`

**Authentification :** JWT Bearer token (rôle `ROLE_ENTREPRISE` requis)

**Fonctionnement :**
1. Récupérer l'email de l'utilisateur connecté depuis le JWT
2. Chercher l'entreprise correspondant à cet email
3. Retourner les informations du profil

### Code Java proposé

```java
@GetMapping("/profile")
public ResponseEntity<EntrepriseProfileResponse> getProfile(Authentication authentication) {
    try {
        String email = authentication.getName();
        
        Entreprise entreprise = entrepriseRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("Entreprise non trouvée"));
        
        EntrepriseProfileResponse response = new EntrepriseProfileResponse();
        response.setId(entreprise.getId());
        response.setNom(entreprise.getNom());
        response.setEmail(entreprise.getEmail());
        response.setUrlPhotoEntreprise(entreprise.getUrlPhotoEntreprise());
        response.setSecteurActivite(entreprise.getSecteurActivite());
        response.setAdresse(entreprise.getAdresse());
        response.setTelephone(entreprise.getTelephone());
        response.setDescription(entreprise.getDescription());
        
        return ResponseEntity.ok(response);
        
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(null);
    }
}
```

### Réponse JSON attendue

```json
{
  "id": 6,
  "nom": "Tech Corp",
  "email": "entre@gmail.com",
  "urlPhotoEntreprise": "http://localhost:8183/uploads/profile_entreprise_6.jpg",
  "secteurActivite": "Informatique",
  "adresse": "123 Rue de la Tech, Paris",
  "telephone": "+33123456789",
  "description": "Une entreprise technologique innovante spécialisée dans le développement web"
}
```

### DTO à créer (si nécessaire)

```java
public class EntrepriseProfileResponse {
    private Long id;
    private String nom;
    private String email;
    private String urlPhotoEntreprise;
    private String secteurActivite;
    private String adresse;
    private String telephone;
    private String description;
    
    // Getters et Setters
}
```

### Points importants

1. **Sécurité** : L'endpoint doit être accessible uniquement aux utilisateurs avec `ROLE_ENTREPRISE`
2. **Repository** : Utiliser `findByEmail(String email)` pour chercher l'entreprise
3. **Photo** : Si `urlPhotoEntreprise` est null, le frontend affichera une photo par défaut
4. **Cohérence** : Suivre la même structure que `/jeunes/profile` et `/mentors/profile`

### Configuration SecurityConfig

Vérifier que l'endpoint est bien autorisé dans `SecurityConfig.java` :

```java
.requestMatchers("/api/entreprises/profile").hasRole("ENTREPRISE")
```

Merci de créer cet endpoint pour que le module entreprise puisse fonctionner correctement ! 🙏


