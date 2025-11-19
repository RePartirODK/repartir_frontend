# Modifications Backend - Formations Gratuites

Ce document décrit toutes les modifications nécessaires côté backend pour implémenter la fonctionnalité des formations gratuites.

## 📋 Résumé des changements

L'objectif est de permettre aux centres de formation de publier des formations gratuites ou payantes. Quand une formation est gratuite, les jeunes peuvent s'inscrire directement sans paiement et leur inscription est automatiquement validée.

---

## 1. Modifications des Entités

### 1.1. Entité `Formation`

**Fichier:** `com.example.repartir_backend.entities.Formation`

**Ajout:**
```java
@Column(nullable = false)
private Boolean gratuit = false; // Par défaut, la formation est payante
```

**Méthode `toResponse()` - Mise à jour:**
```java
public ResponseFormation toResponse(){
    return new ResponseFormation(
        this.id,
        this.titre,
        this.description,
        this.date_debut,
        this.date_fin,
        this.getStatutActuel(),
        this.cout,
        this.nbre_place,
        this.format,
        this.duree,
        this.urlFormation,
        this.urlCertificat,
        this.centreFormation.getId(),
        this.motifAnnulation,
        this.gratuit  // ✅ AJOUTER CETTE LIGNE
    );
}
```

**Méthode `toFormation()` - Mise à jour:**
```java
public Formation toFormation(RequestFormation requestFormation) {
    Formation formation = new Formation();
    // ... autres champs ...
    formation.setGratuit(requestFormation.getGratuit() != null ? requestFormation.getGratuit() : false);
    return formation;
}
```

---

## 2. Modifications des DTOs

### 2.1. `RequestFormation`

**Fichier:** `com.example.repartir_backend.dto.RequestFormation`

**Ajout:**
```java
private Boolean gratuit; // null ou false = payant, true = gratuit
```

**Getters/Setters:**
```java
public Boolean getGratuit() {
    return gratuit;
}

public void setGratuit(Boolean gratuit) {
    this.gratuit = gratuit;
}
```

### 2.2. `ResponseFormation`

**Fichier:** `com.example.repartir_backend.dto.ResponseFormation`

**Ajout:**
```java
private Boolean gratuit;
```

**Constructeur - Mise à jour:**
```java
public ResponseFormation(
    int id,
    String titre,
    String description,
    LocalDateTime date_debut,
    LocalDateTime date_fin,
    Etat statut,
    Double cout,
    Integer nbrePlace,
    Format format,
    String duree,
    String urlFormation,
    String urlCertificat,
    int idCentre,
    String motifAnnulation,
    Boolean gratuit  // ✅ AJOUTER CE PARAMÈTRE
) {
    // ... initialisation des autres champs ...
    this.gratuit = gratuit;
}
```

---

## 3. Modifications des Services

### 3.1. `FormationServices`

**Fichier:** `com.example.repartir_backend.services.FormationServices`

**Méthode `createFormation()` - Mise à jour:**
```java
public Formation createFormation(RequestFormation requestFormation, int centreId) {
    CentreFormation centre = centreFormationRepository.findById(centreId)
            .orElseThrow(() -> new EntityNotFoundException("Centre de formation introuvable"));
    Formation formation = new Formation().toFormation(requestFormation);
    formation.setCentreFormation(centre);
    formation.setStatut(Etat.EN_ATTENTE);
    
    // ✅ NOUVEAU: Gérer le champ gratuit
    if (requestFormation.getGratuit() != null && requestFormation.getGratuit()) {
        formation.setGratuit(true);
        formation.setCout(0.0); // S'assurer que le coût est à 0 pour les formations gratuites
    } else {
        formation.setGratuit(false);
    }
    
    return formationRepository.save(formation);
}
```

**Méthode `updateFormation()` - Mise à jour:**
```java
public ResponseFormation updateFormation(int id, RequestFormation requestFormation) {
    Formation formation = formationRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Formation non trouvée"));
    
    // ... autres mises à jour ...
    
    // ✅ NOUVEAU: Mettre à jour le champ gratuit
    if (requestFormation.getGratuit() != null) {
        formation.setGratuit(requestFormation.getGratuit());
        if (requestFormation.getGratuit()) {
            formation.setCout(0.0); // Forcer le coût à 0 si gratuit
        }
    }
    
    Formation updatedFormation = formationRepository.save(formation);
    return updatedFormation.toResponse();
}
```

---

### 3.2. `InscriptionFormationServices` ⚠️ **MODIFICATION CRITIQUE**

**Fichier:** `com.example.repartir_backend.services.InscriptionFormationServices`

**Méthode `sInscrire()` - MODIFICATION COMPLÈTE:**

```java
@Transactional
public InscriptionResponseDto sInscrire(int formationId, boolean payerDirectement) {
    Jeune jeune = getCurrentJeune();
    Formation formation = formationRepository.findById(formationId)
            .orElseThrow(() -> new EntityNotFoundException("Formation non trouvée."));

    if (inscriptionFormationRepository.existsByJeuneAndFormation(jeune, formation)) {
        throw new IllegalStateException("Vous êtes déjà inscrit à cette formation.");
    }

    // Vérifier qu'il reste des places
    if(formation.getNbre_place() <= 0 && formation.getNbre_place() != null)
        throw new IllegalStateException("Il n'y a plus de places disponibles pour cette formation.");

    InscriptionFormation inscription = new InscriptionFormation();
    inscription.setJeune(jeune);
    inscription.setFormation(formation);
    inscription.setDateInscription(new Date());
    inscription.setDemandeParrainage(false);

    // ✅ NOUVEAU: Logique pour les formations gratuites
    boolean isGratuit = formation.getGratuit() != null && formation.getGratuit();
    
    if (isGratuit) {
        // Formation gratuite: inscription automatiquement validée
        inscription.setStatus(Etat.VALIDE);
        System.out.println("✅ Formation gratuite - Inscription validée automatiquement");
        
        // Décrémenter les places disponibles
        Integer places = formation.getNbre_place();
        if (places != null && places > 0) {
            formation.setNbre_place(places - 1);
            formationRepository.save(formation);
            System.out.println("✅ Place décrementée pour formation gratuite");
        }
    } else {
        // Formation payante: comportement actuel
        inscription.setStatus(Etat.EN_ATTENTE);
        
        // Si le jeune veut payer directement
        if (payerDirectement) {
            RequestPaiement requestPaiement = new RequestPaiement();
            requestPaiement.setIdJeune(jeune.getId());
            requestPaiement.setIdInscription(savedInscription.getId());
            requestPaiement.setMontant(formation.getCout());
            requestPaiement.setIdParrainage(null);
            paiementServices.creerPaiement(requestPaiement);
        }
    }

    InscriptionFormation savedInscription = inscriptionFormationRepository.save(inscription);
    
    // ✅ NOUVEAU: Envoyer un email de confirmation pour les formations gratuites
    if (isGratuit) {
        try {
            String emailDestinataire = jeune.getUtilisateur().getEmail();
            String nomJeune = jeune.getUtilisateur().getNom();
            String prenomJeune = jeune.getPrenom();
            String formationNom = formation.getTitre();
            
            // Utiliser le service d'email existant
            String pathInscription = "src/main/resources/templates/inscriptionreussi.html";
            mailSendServices.acceptionInscription(
                emailDestinataire,
                "Inscription confirmée - " + formationNom,
                prenomJeune + " " + nomJeune,
                formationNom,
                pathInscription
            );
            System.out.println("✅ Email de confirmation envoyé pour formation gratuite");
        } catch (Exception e) {
            System.err.println("❌ ERREUR ENVOI EMAIL FORMATION GRATUITE : " + e.getMessage());
            e.printStackTrace();
            // Ne pas faire échouer l'inscription si l'email échoue
        }
    }

    return InscriptionResponseDto.fromEntity(savedInscription);
}
```

**⚠️ IMPORTANT:** Vous devrez injecter `MailSendServices` dans `InscriptionFormationServices` si ce n'est pas déjà fait:

```java
private final MailSendServices mailSendServices;
```

Et dans le constructeur:
```java
public InscriptionFormationServices(
    // ... autres dépendances ...
    MailSendServices mailSendServices
) {
    // ...
    this.mailSendServices = mailSendServices;
}
```

---

## 4. Migration de Base de Données

### 4.1. Script SQL (si vous utilisez une migration manuelle)

```sql
-- Ajouter la colonne 'gratuit' à la table 'formation'
ALTER TABLE formation 
ADD COLUMN gratuit BOOLEAN NOT NULL DEFAULT FALSE;

-- Optionnel: Mettre à jour les formations existantes avec cout = 0 pour les marquer comme gratuites
UPDATE formation 
SET gratuit = TRUE 
WHERE cout = 0 OR cout IS NULL;
```

### 4.2. Si vous utilisez JPA/Hibernate avec auto-update

Aucune action nécessaire, Hibernate créera automatiquement la colonne au démarrage si `hibernate.hbm2ddl.auto=update` est configuré.

---

## 5. Points d'attention

### 5.1. Validation

- ✅ Vérifier que si `gratuit = true`, alors `cout` doit être `0.0` ou `null`
- ✅ Vérifier que si `gratuit = false`, alors `cout` doit être > 0

**Suggestion de validation dans `FormationServices.createFormation()`:**
```java
if (requestFormation.getGratuit() != null && requestFormation.getGratuit()) {
    if (requestFormation.getCout() != null && requestFormation.getCout() > 0) {
        throw new IllegalArgumentException("Une formation gratuite ne peut pas avoir un coût supérieur à 0.");
    }
    formation.setCout(0.0);
    formation.setGratuit(true);
} else {
    if (requestFormation.getCout() == null || requestFormation.getCout() <= 0) {
        throw new IllegalArgumentException("Une formation payante doit avoir un coût supérieur à 0.");
    }
    formation.setGratuit(false);
}
```

### 5.2. Compatibilité avec le code existant

- ✅ Les formations existantes sans le champ `gratuit` seront considérées comme payantes (valeur par défaut: `false`)
- ✅ Le frontend envoie déjà le champ `gratuit` dans `RequestFormation`

### 5.3. Tests recommandés

1. ✅ Créer une formation gratuite et vérifier que l'inscription est automatiquement validée
2. ✅ Créer une formation payante et vérifier que le comportement actuel est préservé
3. ✅ Vérifier que les places sont bien décrémentées pour les formations gratuites
4. ✅ Vérifier que l'email de confirmation est envoyé pour les formations gratuites

---

## 6. Résumé des fichiers à modifier

1. ✅ `Formation.java` - Ajouter le champ `gratuit`
2. ✅ `RequestFormation.java` - Ajouter le champ `gratuit`
3. ✅ `ResponseFormation.java` - Ajouter le champ `gratuit`
4. ✅ `FormationServices.java` - Gérer le champ `gratuit` dans `createFormation()` et `updateFormation()`
5. ✅ `InscriptionFormationServices.java` - **MODIFIER** `sInscrire()` pour valider automatiquement les inscriptions aux formations gratuites
6. ✅ Migration SQL (si nécessaire)

---

## 7. Ordre d'implémentation recommandé

1. **Étape 1:** Ajouter le champ `gratuit` dans l'entité `Formation` et créer la migration SQL
2. **Étape 2:** Mettre à jour les DTOs (`RequestFormation` et `ResponseFormation`)
3. **Étape 3:** Mettre à jour `FormationServices` pour gérer le champ lors de la création/mise à jour
4. **Étape 4:** **MODIFIER** `InscriptionFormationServices.sInscrire()` pour la logique d'inscription automatique
5. **Étape 5:** Tester avec le frontend

---

## 8. Notes importantes

- ⚠️ **CRITIQUE:** La modification de `InscriptionFormationServices.sInscrire()` est la plus importante. C'est là que se fait la validation automatique des inscriptions aux formations gratuites.
- ✅ Les formations gratuites ne nécessitent **PAS** de paiement ni de demande de parrainage
- ✅ L'inscription aux formations gratuites doit être **automatiquement validée** (status = VALIDE)
- ✅ Les places doivent être **décrémentées** immédiatement pour les formations gratuites
- ✅ Un **email de confirmation** doit être envoyé pour les formations gratuites

---

**Date de création:** $(date)
**Version:** 1.0

