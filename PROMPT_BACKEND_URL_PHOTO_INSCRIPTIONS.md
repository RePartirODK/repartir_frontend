# Prompt Backend : Ajouter urlPhotoJeune dans les réponses d'inscriptions

## 🎯 Objectif

Les endpoints qui retournent des inscriptions doivent inclure la photo de profil du jeune (`urlPhotoJeune`) pour que les centres de formation puissent voir les photos des appliquants.

## 📋 Endpoints concernés

Les endpoints suivants doivent retourner `urlPhotoJeune` dans chaque inscription :

1. **`GET /inscriptions/centre/{centreId}`** - Liste des inscriptions d'un centre
2. **`GET /inscriptions/formation/{formationId}`** - Liste des inscriptions d'une formation

## ✅ Format de réponse attendu

Chaque objet `Inscription` dans la réponse doit inclure `urlPhotoJeune` :

```json
[
  {
    "id": 1,
    "nomJeune": "Booba Diallo",
    "titreFormation": "Formation en développement web",
    "dateInscription": "2025-11-18T01:40:00",
    "demandeParrainage": false,
    "status": "VALIDE",
    "certifie": false,
    "idFormation": 1,
    "formationStatut": "EN_COURS",
    "urlPhotoJeune": "http://localhost:8183/uploads/photos/user_1.png"  // ← À AJOUTER
  }
]
```

## 🔧 Solution à implémenter

### Option 1 : Modifier le DTO de réponse

**Fichier : `InscriptionResponseDto.java` ou similaire**

```java
public class InscriptionResponseDto {
    private Long id;
    private String nomJeune;
    private String titreFormation;
    private LocalDateTime dateInscription;
    private Boolean demandeParrainage;
    private String status;
    private Boolean certifie;
    private Long idFormation;
    private String formationStatut;
    private String urlPhotoJeune;  // ← AJOUTER CE CHAMP
    
    // Constructeur, getters, setters...
    
    // Dans la méthode de mapping depuis l'entité Inscription
    public static InscriptionResponseDto fromEntity(Inscription inscription) {
        InscriptionResponseDto dto = new InscriptionResponseDto();
        // ... mapping des autres champs ...
        
        // ✅ Récupérer l'URL de photo du jeune
        if (inscription.getJeune() != null && 
            inscription.getJeune().getUtilisateur() != null) {
            dto.setUrlPhotoJeune(inscription.getJeune().getUtilisateur().getUrlPhoto());
        }
        
        return dto;
    }
}
```

### Option 2 : Utiliser une projection JPA

Si vous utilisez une projection, ajoutez le champ :

```java
public interface InscriptionProjection {
    Long getId();
    String getNomJeune();
    String getTitreFormation();
    // ... autres champs ...
    String getUrlPhotoJeune();  // ← AJOUTER
}
```

Et dans la requête :

```java
@Query("SELECT i.id as id, " +
       "i.jeune.utilisateur.nom as nomJeune, " +
       "i.formation.titre as titreFormation, " +
       "i.jeune.utilisateur.urlPhoto as urlPhotoJeune, " +  // ← AJOUTER
       "// ... autres champs ... " +
       "FROM Inscription i WHERE i.centre.id = :centreId")
List<InscriptionProjection> findByCentreId(@Param("centreId") Long centreId);
```

## 🧪 Test à effectuer

1. Appeler `GET /inscriptions/centre/{centreId}`
2. Vérifier que chaque inscription contient `urlPhotoJeune`
3. Vérifier que l'URL est au format correct : `http://localhost:8183/uploads/photos/user_X.png`

## 📝 Checklist

- [ ] `InscriptionResponseDto` contient le champ `urlPhotoJeune`
- [ ] Le mapping depuis l'entité `Inscription` inclut `urlPhotoJeune`
- [ ] `GET /inscriptions/centre/{centreId}` retourne `urlPhotoJeune`
- [ ] `GET /inscriptions/formation/{formationId}` retourne `urlPhotoJeune`
- [ ] Testé : Les URLs sont correctes et accessibles

## 🔍 Vérification

Après correction, une réponse d'inscription doit ressembler à :

```json
{
  "id": 1,
  "nomJeune": "Booba Diallo",
  "urlPhotoJeune": "http://localhost:8183/uploads/photos/user_1.png",
  // ... autres champs
}
```

**Note** : Si le jeune n'a pas de photo, `urlPhotoJeune` peut être `null` ou une chaîne vide. Le frontend affichera l'icône par défaut dans ce cas.


