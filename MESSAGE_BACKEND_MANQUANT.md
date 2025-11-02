# 📋 Message pour le Backend

Salut ! 👋

J'ai analysé toute la documentation des APIs que tu m'as fournie. C'est excellent ! 🚀

La plupart des fonctionnalités sont déjà implémentées, mais il me manque **3 endpoints prioritaires** pour compléter l'intégration côté Flutter :

## 🔴 Endpoints manquants (Priorité HAUTE)

### 1. GET /api/jeunes/profile
**Besoin:** Récupérer le profil complet du jeune connecté (pas juste modifier)
- Permet d'afficher le profil actuel du jeune sur la page de profil
- Doit retourner les mêmes données que PUT /api/jeunes/modifier mais en lecture seule

**Réponse attendue:**
```json
{
  "id": 1,
  "a_propos": "Je suis passionné par le développement web...",
  "genre": "HOMME",
  "age": 22,
  "prenom": "Jean",
  "niveau": "Bac+3",
  "urlDiplome": "https://example.com/diplome.pdf",
  "utilisateur": {
    "id": 10,
    "nom": "Dupont",
    "email": "jeune@example.com",
    "telephone": "+33612345678",
    "urlPhoto": "https://example.com/photo.jpg",
    "role": "JEUNE",
    "etat": "VALIDE",
    "estActive": true,
    "dateCreation": "2024-01-15T10:30:00"
  }
}
```

---

### 2. GET /api/formations/jeune/{jeuneId} ou GET /api/inscriptions/jeune/{jeuneId}
**Besoin:** Récupérer les formations auxquelles un jeune est inscrit
- Utilisé dans la page "Mes formations"
- Doit retourner les inscriptions avec leur statut

**Réponse attendue:**
```json
[
  {
    "id": 1,
    "formation": {
      "id": 1,
      "titre": "Formation Java Spring Boot",
      "description": "Formation complète sur Spring Boot...",
      "centre": {
        "id": 1,
        "nom": "Centre de Formation Tech",
        "logo": "https://example.com/photos/centre_1.jpg"
      },
      "date_debut": "2024-03-01T09:00:00",
      "date_fin": "2024-03-15T17:00:00"
    },
    "statut": "ACCEPTEE",
    "dateInscription": "2024-01-20T14:30:00.000+00:00",
    "demandeParrainage": false
  }
]
```

**Statuts possibles:** EN_ATTENTE, ACCEPTEE, EN_COURS, TERMINEE, ANNULEE

---

### 3. GET /api/offres/{id}
**Besoin:** Obtenir les détails complets d'une offre par ID
- Nécessaire pour la page de détails d'offre
- Retourner les mêmes champs que dans la liste mais avec plus de détails

**Réponse attendue:**
```json
{
  "id": 1,
  "titre": "Développeur Full Stack",
  "description": "Nous recherchons un développeur full stack...",
  "competence": "Java, Spring Boot, React, TypeScript",
  "type_contrat": "CDI",
  "lienPostuler": "https://example.com/postuler/123",
  "dateDebut": "2024-02-01T00:00:00.000+00:00",
  "dateFin": "2024-03-01T00:00:00.000+00:00",
  "nomEntreprise": "TechCorp",
  "adresseEntreprise": "123 Rue de la Tech, Paris",
  "secteur": "Informatique"
}
```

---

## 🟡 Optionnel (Priorité MOYENNE)

### 4. GET /api/jeunes/dashboard
**Besoin:** Endpoint pour récupérer les statistiques et données récentes
- Utilisé sur la page d'accueil du jeune
- Retourner des statistiques et des données récentes

**Réponse attendue:**
```json
{
  "statistiques": {
    "offresPostulees": 5,
    "formationsInscrites": 3,
    "mentorsActifs": 2,
    "formationsTerminees": 1
  },
  "offresRecent": [
    {
      "id": 1,
      "titre": "Développeur Full Stack",
      "entreprise": "TechCorp",
      "datePublication": "2024-01-20T10:00:00"
    }
  ],
  "formationsRecent": [
    {
      "id": 1,
      "titre": "Formation Java Spring Boot",
      "centre": "Centre de Formation Tech",
      "dateDebut": "2024-03-01T09:00:00"
    }
  ]
}
```

---

## ✅ Note importante

Tous ces endpoints doivent nécessiter l'authentification avec le token JWT :
```
Authorization: Bearer <access_token>
```

Et vérifier que l'utilisateur a bien le rôle `JEUNE` ou `ADMIN`.

---

## 🙏

Merci beaucoup ! Avec ces 3 endpoints prioritaires, je pourrai compléter l'intégration côté Flutter. 

Si tu as des questions ou si certains endpoints existent déjà sous un autre nom, fais-moi signe !

🚀

