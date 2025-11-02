# 🔧 Prompt pour Cursor Backend

```
J'ai besoin que tu corriges une erreur Hibernate dans l'endpoint GET /api/jeunes/profile.

## ❌ Erreur actuelle

L'endpoint génère cette erreur :
```
Could not write JSON: failed to lazily initialize a collection of role: 
com.example.repartir_backend.entities.Utilisateur.userDomaineList: 
could not initialize proxy - no Session
```

## 🔍 Cause

L'entité `Utilisateur` a une collection `userDomaineList` en mode Lazy Loading. Quand Jackson serialise en JSON, il essaie d'accéder à cette collection après la fermeture de la session Hibernate.

## ✅ Solution demandée

Ajoute l'annotation `@JsonIgnore` sur la propriété `userDomaineList` dans la classe `Utilisateur.java` :

```java
@OneToMany(mappedBy = "utilisateur", fetch = FetchType.LAZY)
@JsonIgnore  // AJOUTER CETTE ANNOTATION
private List<UserDomaine> userDomaineList;
```

Cette annotation empêche Jackson de sérialiser cette collection et corrige l'erreur.

Teste ensuite l'endpoint GET /api/jeunes/profile avec un token JWT valide.
```

