# Endpoints nécessaires pour les mentors (côté jeune)

## Base URL
`http://localhost:8183/api`

## Endpoints utilisés

### 1. Lister tous les mentors
- **Méthode:** `GET`
- **Chemin:** `/mentors`
- **Auth:** Non requis (mais recommandé)
- **Réponse:** Liste de mentors
```json
[
  {
    "id": 1,
    "utilisateur": {
      "prenom": "Fatoumata",
      "nom": "Diawara",
      "urlPhoto": "https://..."
    },
    "specialite": "Entrepreneuriat",
    "domaine": "Entrepreneuriat",
    "anneesExperience": 8,
    "description": "...",
    "a_propos": "..."
  }
]
```

### 2. Obtenir un mentor par ID
- **Méthode:** `GET`
- **Chemin:** `/mentors/{id}`
- **Auth:** Non requis
- **Réponse:** Détails complets du mentor

### 3. Obtenir les mentors en contact avec le jeune
- **Méthode:** `GET`
- **Chemin:** `/mentors/mes-mentors`
- **Auth:** **REQUIS** (Bearer token)
- **Réponse:** Liste de mentors avec lesquels le jeune est en contact

## Vérifications côté backend

Assurez-vous que:
1. ✅ `GET /api/mentors` existe et retourne une liste de mentors
2. ✅ `GET /api/mentors/{id}` existe et retourne les détails d'un mentor
3. ✅ `GET /api/mentors/mes-mentors` existe et nécessite une authentification
4. ✅ Les endpoints sont accessibles (pas de 403 Forbidden)
5. ✅ La structure de réponse correspond à ce qui est attendu dans le frontend

## Structure de données attendue

Chaque mentor doit avoir:
- `id`: identifiant numérique
- `utilisateur`: objet avec `prenom`, `nom`, `urlPhoto`
- `specialite` ou `domaine`: spécialité du mentor
- `anneesExperience`: nombre d'années d'expérience
- `description` ou `a_propos`: description du mentor

