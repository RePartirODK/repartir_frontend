# Endpoint Backend Manquant : GET /api/mentors/profile

## 🎯 Objectif
Permettre au mentor connecté de récupérer son profil sans connaître son ID (comme pour `/jeunes/profile`).

---

## 📝 Code à ajouter

### 1. **MentorControllers.java**

Ajoutez cette méthode dans `MentorControllers.java` :

```java
@GetMapping("/profile")
@PreAuthorize("hasRole('MENTOR')")
@Operation(summary = "Récupérer le profil du mentor connecté")
public ResponseEntity<?> getMentorProfile(Principal principal) {
    try {
        String email = principal.getName(); // Email depuis le JWT
        Mentor mentor = mentorServices.getMentorByEmail(email);
        return ResponseEntity.ok(MentorResponseDto.fromEntity(mentor));
    } catch (EntityNotFoundException e) {
        return new ResponseEntity<>(
            "Mentor non trouvé",
            HttpStatus.NOT_FOUND
        );
    } catch (RuntimeException e) {
        return new ResponseEntity<>(
            e.getMessage(),
            HttpStatus.INTERNAL_SERVER_ERROR
        );
    }
}
```

**N'oubliez pas l'import :**
```java
import java.security.Principal;
```

---

### 2. **MentorServices.java**

Ajoutez cette méthode dans `MentorServices.java` :

```java
@Transactional(readOnly = true)
public Mentor getMentorByEmail(String email) {
    return mentorRepository.findByUtilisateur_Email(email)
        .orElseThrow(() -> new EntityNotFoundException("Mentor non trouvé avec l'email: " + email));
}
```

---

### 3. **MentorRepository.java**

Ajoutez cette méthode dans `MentorRepository.java` :

```java
Optional<Mentor> findByUtilisateur_Email(String email);
```

---

## 🔄 Équivalent Jeune (pour référence)

C'est exactement le même pattern que pour les jeunes :
- `/jeunes/profile` → récupère le jeune connecté via son email dans le JWT
- `/mentors/profile` → récupère le mentor connecté via son email dans le JWT

---

## ✅ Après modification

Une fois ces modifications ajoutées :
1. Redémarrez le backend Spring Boot
2. Reconnectez-vous avec un compte mentor dans le frontend
3. Le profil s'affichera correctement avec les vraies données !

---

## 🎯 Ce qui fonctionnera ensuite

- ✅ Page Accueil - Stats et mentorings
- ✅ Page Mentorés - Liste VALIDE
- ✅ Page Activité - Demandes EN_ATTENTE
- ✅ **Page Profil - Données réelles du mentor** ✨
- ✅ **Page Éditer Profil - Modification en base de données** ✨
- ✅ Accepter/Refuser demandes

