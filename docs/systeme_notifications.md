# Système de Notifications - Espace Jeune

Date : 11 novembre 2025

## 📱 Vue d'ensemble

Le système de notifications permet au jeune d'être informé des changements de statut de ses demandes de mentorat.

## 🔔 Fonctionnement

### Comment ça marche ?

1. **Le jeune crée une demande de mentorat** → Statut = `EN_ATTENTE`
2. **Le mentor accepte** → Statut = `VALIDE` → Email envoyé + Notification frontend
3. **Le mentor refuse** → Statut = `REFUSE` → Email envoyé + Notification frontend

### Notification automatique :

- ✅ Pas besoin d'endpoint backend spécifique pour les notifications
- ✅ Les notifications sont générées à partir des **mentorings** existants
- ✅ Détection automatique des nouveaux statuts (comparaison avec dernière vue)
- ✅ Badge rouge avec compteur sur l'icône 🔔

## 📊 États des mentorings

| Statut | Description | Icône | Couleur |
|--------|-------------|-------|---------|
| `EN_ATTENTE` | Demande envoyée, en attente de réponse | ⏰ | Bleu |
| `VALIDE` | Demande acceptée par le mentor | ✅ | Vert |
| `REFUSE` | Demande refusée par le mentor | ❌ | Rouge |

## 🎨 Interface Notifications

### Badge sur l'icône :
```
🔔 [5]  ← Badge rouge avec nombre de nouvelles notifications
```

### Page de notifications :
```
┌─────────────────────────────────┐
│ ✅ Demande acceptée 🎉  [Nouveau]│
│ Votre demande de mentorat avec  │
│ Jean Dupont a été acceptée !    │
│ Il y a 2h                        │
├─────────────────────────────────┤
│ ⏰ Demande en attente           │
│ Votre demande avec Marie...     │
│ Il y a 1j                        │
└─────────────────────────────────┘
```

## 🔧 Implémentation

### Services créés :

**`NotificationsService`** :
- `getNotifications()` : Récupère toutes les notifications depuis les mentorings
- `countNewNotifications()` : Compte les nouvelles notifications non vues
- `markAllAsSeen()` : Marque toutes comme vues (sauvegarde dans storage)

**Stockage local** :
- Utilise `flutter_secure_storage` pour sauvegarder les derniers statuts vus
- Clé : `last_seen_mentorings`
- Format : `{"mentoringId": "statut"}`

### Pages créées :

**`NotificationsPage`** :
- Liste toutes les notifications
- Pull-to-refresh pour actualiser
- Badge "Nouveau" sur les notifications non vues
- Formatage des dates ("Il y a 2h", "Il y a 1j")
- Icônes et couleurs selon le type

### Intégration :

**`AccueilPage`** :
- Badge rouge avec compteur sur l'icône 🔔
- Navigation vers `NotificationsPage` au clic
- Rechargement du compteur après retour
- Badge masqué si 0 notification

## 📋 Flux complet

### 1. Création de demande

```
Jeune clique "Demander à être mentoré"
  ↓
POST /mentorings/create/{idMentor}/{idJeune}
  ↓
Statut = EN_ATTENTE
  ↓
Notification : "Demande en attente" (bleu)
```

### 2. Acceptation par le mentor

```
Mentor clique "Accepter"
  ↓
PATCH /mentorings/{id}/accepter
  ↓
Statut = VALIDE
  ↓
Email envoyé au jeune
  ↓
Badge 🔔 [1] apparaît
  ↓
Jeune ouvre notifications
  ↓
Notification : "Demande acceptée 🎉" (vert)
```

### 3. Refus par le mentor

```
Mentor clique "Refuser"
  ↓
PATCH /mentorings/{id}/refuser
  ↓
Statut = REFUSE
  ↓
Email envoyé au jeune
  ↓
Badge 🔔 [1] apparaît
  ↓
Notification : "Demande refusée" (rouge)
```

## 🔐 Sécurité

- ✅ Seul le **MENTOR** peut accepter/refuser (`@PreAuthorize("hasRole('MENTOR')")`)
- ✅ Le jeune peut seulement **voir** ses notifications
- ✅ Les notifications sont privées (basées sur l'ID du jeune connecté)

## 📝 Endpoints utilisés

| Action | Endpoint | Qui | Résultat |
|--------|----------|-----|----------|
| Créer demande | `POST /mentorings/create/{idM}/{idJ}` | Jeune | EN_ATTENTE |
| Voir mes notifications | `GET /mentorings/jeune/{idJ}` | Jeune | Liste mentorings |
| Accepter | `PATCH /mentorings/{id}/accepter` | Mentor | VALIDE + email |
| Refuser | `PATCH /mentorings/{id}/refuser` | Mentor | REFUSE + email |

## 🎯 Avantages

✅ **Pas d'endpoint supplémentaire** : Réutilise les mentorings existants  
✅ **Temps réel** : Badge mis à jour à chaque ouverture de l'app  
✅ **Persistant** : Les statuts vus sont sauvegardés localement  
✅ **Simple** : Pas besoin de base de données notifications séparée  
✅ **Emails** : Le backend envoie déjà des emails en parallèle  

## 🚀 Évolutions futures possibles

- [ ] Polling automatique toutes les 30 secondes
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Notifications pour d'autres événements (inscriptions, offres)
- [ ] Historique des notifications
- [ ] Supprimer individuellement
- [ ] Filtres par type

---

**Auteur** : Assistant AI  
**Date** : 11 novembre 2025, 00:45

