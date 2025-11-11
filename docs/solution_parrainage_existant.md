# Solution : Demande de parrainage pour inscription existante

## 🐛 Problème

Le jeune est déjà inscrit à une formation et souhaite faire une demande de parrainage, mais le backend retourne :
```
HTTP 409: Vous êtes déjà inscrit à cette formation.
```

## ✅ Solution Backend

Votre backend a déjà la méthode `activerDemandeParrainage(int inscriptionId)` mais elle n'est **pas exposée** comme endpoint.

### Ajouter cet endpoint dans `InscriptionFormationControllers.java` :

```java
@PutMapping("/{inscriptionId}/demander-parrainage")
@PreAuthorize("hasRole('JEUNE')")
@Operation(
    summary = "Activer la demande de parrainage pour une inscription existante",
    description = "Permet au jeune de transformer son inscription en demande de parrainage."
)
@ApiResponses({
    @ApiResponse(responseCode = "200", description = "Demande de parrainage activée"),
    @ApiResponse(responseCode = "403", description = "Accès refusé"),
    @ApiResponse(responseCode = "404", description = "Inscription non trouvée"),
    @ApiResponse(responseCode = "400", description = "Demande déjà existante")
})
public ResponseEntity<InscriptionResponseDto> demanderParrainage(
        @PathVariable int inscriptionId
) throws AccessDeniedException {
    InscriptionResponseDto inscriptionDto = 
        inscriptionFormationServices.activerDemandeParrainage(inscriptionId);
    return ResponseEntity.ok(inscriptionDto);
}
```

## 🔄 Flux recommandé

### Scénario 1 : Nouvelle inscription avec parrainage
```
1. Jeune clique "S'inscrire" → "Demander à être parrainé"
2. POST /inscriptions/s-inscrire/{formationId}?payerDirectement=false
3. inscription.demandeParrainage = false (par défaut)
4. POST /parrainages/creer avec {idJeune, idFormation, idParrain=null}
5. Création du Parrainage en base
```

### Scénario 2 : Inscription existante → Ajouter parrainage
```
1. Jeune déjà inscrit clique "S'inscrire" 
2. Backend retourne 409 "Déjà inscrit"
3. Frontend détecte 409
4. Propose "Voulez-vous faire une demande de parrainage ?"
5. PUT /inscriptions/{inscriptionId}/demander-parrainage
6. inscription.demandeParrainage = true
7. POST /parrainages/creer (même flux)
```

## 📝 Alternative simple

Si vous ne voulez pas ajouter de nouvel endpoint, modifiez le service backend pour qu'il gère automatiquement :

```java
@Transactional
public InscriptionResponseDto sInscrire(int formationId, boolean payerDirectement) {
    Jeune jeune = getCurrentJeune();
    Formation formation = formationRepository.findById(formationId)
            .orElseThrow(() -> new EntityNotFoundException("Formation non trouvée."));

    // ✅ MODIFIER ICI : Vérifier si inscription existe déjà
    InscriptionFormation inscription = inscriptionFormationRepository
        .findByJeuneAndFormation(jeune, formation)
        .orElse(null);
    
    if (inscription != null) {
        // Inscription existe déjà, retourner l'inscription existante
        return InscriptionResponseDto.fromEntity(inscription);
    }
    
    // Sinon, créer une nouvelle inscription
    inscription = new InscriptionFormation();
    inscription.setJeune(jeune);
    inscription.setStatus(Etat.EN_ATTENTE);
    inscription.setFormation(formation);
    inscription.setDateInscription(new Date());
    inscription.setDemandeParrainage(false);
    
    // ... reste du code
}
```

Cela évitera l'erreur 409 et retournera simplement l'inscription existante.

