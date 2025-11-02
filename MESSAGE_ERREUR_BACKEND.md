# 🚨 Erreur Backend - Endpoint GET /api/jeunes/profile

## ❌ Problème détecté

L'endpoint `GET /api/jeunes/profile` génère une erreur Hibernate :

```
Could not write JSON: failed to lazily initialize a collection of role: 
com.example.repartir_backend.entities.Utilisateur.userDomaineList: 
could not initialize proxy - no Session
```

## 🔍 Cause du problème

L'entité `Utilisateur` a une relation `@OneToMany` avec `userDomaineList` en **mode Lazy Loading**.

Quand Spring serialise l'objet en JSON avec Jackson, il essaie d'accéder à cette collection **après la fermeture de la session Hibernate**, ce qui provoque l'erreur.

## ✅ Solutions possibles

### Solution 1 : Ajouter @JsonIgnore (RECOMMANDÉ)

Dans votre entité `Utilisateur.java` :

```java
@Entity
public class Utilisateur {
    
    // ... vos autres champs ...
    
    @OneToMany(mappedBy = "utilisateur", fetch = FetchType.LAZY)
    @JsonIgnore  // 👈 AJOUTER CETTE ANNOTATION
    private List<UserDomaine> userDomaineList;
    
    // ... reste du code ...
}
```

Cette solution empêche Jackson de sérialiser cette collection.

---

### Solution 2 : Utiliser un DTO (Data Transfer Object)

Créer un DTO spécifique pour la réponse du profil qui n'inclut **PAS** `userDomaineList` :

```java
public class UtilisateurProfilDTO {
    private Long id;
    private String nom;
    private String email;
    private String telephone;
    private String urlPhoto;
    private String role;
    private String etat;
    private Boolean estActive;
    private String dateCreation;
    
    // Constructeur, getters/setters...
}
```

Ensuite, dans votre controller/service :

```java
@GetMapping("/profile")
public ResponseEntity<JeuneProfilDTO> getProfile(Authentication authentication) {
    Utilisateur utilisateur = // ... récupérer l'utilisateur
    
    // Convertir en DTO (sans userDomaineList)
    UtilisateurProfilDTO dto = new UtilisateurProfilDTO();
    // ... mapper les champs manuellement ou avec MapStruct
    
    return ResponseEntity.ok(jeuneProfilDTO);
}
```

---

### Solution 3 : Utiliser @JsonIgnoreProperties

Vous pouvez aussi ignorer plusieurs propriétés en une fois :

```java
@Entity
@JsonIgnoreProperties({"userDomaineList", "autreCollection"})  // 👈
public class Utilisateur {
    // ...
}
```

---

### Solution 4 : Activer le fetch (ATTENTION : performance)

Si vous avez vraiment besoin de `userDomaineList` dans la réponse :

```java
@OneToMany(mappedBy = "utilisateur", fetch = FetchType.EAGER)  // 👈 EAGER au lieu de LAZY
private List<UserDomaine> userDomaineList;
```

⚠️ **Attention** : EAGER peut causer des problèmes de performance si la liste est grande !

---

## 🎯 Solution RECOMMANDÉE

**Solution 1 : `@JsonIgnore`**

C'est la solution la plus simple et la plus rapide à implémenter. Ajoutez juste `@JsonIgnore` sur la propriété `userDomaineList` dans votre entité `Utilisateur`.

---

## 📋 Checklist de correction

- [ ] Ouvrir `Utilisateur.java`
- [ ] Trouver la propriété `userDomaineList`
- [ ] Ajouter l'annotation `@JsonIgnore` ou `@JsonIgnoreProperties`
- [ ] Redémarrer le backend
- [ ] Tester `GET /api/jeunes/profile`

---

## 🔗 Documentation

- Jackson `@JsonIgnore` : https://www.baeldung.com/jackson-ignore-properties-on-serialization
- Hibernate Lazy Loading : https://www.baeldung.com/hibernate-lazy-eager-loading

---

**Date :** 2025-01-20
**Impact :** Bloque l'affichage du profil jeune
**Priorité :** HAUTE

