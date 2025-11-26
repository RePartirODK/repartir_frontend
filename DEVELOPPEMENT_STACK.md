# 🛠️ SLIDE 8 : DÉVELOPPEMENT - STACK TECHNIQUE

---

## 📋 MÉTHODOLOGIE DE DÉVELOPPEMENT

### **Méthode Agile (Scrum)**

#### **Approche Itérative**
- **Sprints de 2 semaines** : Développement par itérations courtes
- **Daily stand-ups** : Synchronisation quotidienne de l'équipe
- **Backlog priorisé** : Gestion des tâches par ordre d'importance
- **Rétrospectives** : Amélioration continue après chaque sprint

#### **Pratiques de Développement**
- **Code review** : Validation du code par les pairs
- **Versioning Git** : Gestion des versions avec branches
- **Tests continus** : Validation à chaque étape
- **Documentation** : Maintien de la documentation à jour

#### **Avantages**
- Flexibilité et adaptation rapide aux changements
- Livraison continue de fonctionnalités
- Communication constante entre développeurs
- Qualité de code améliorée

---

## 💻 LANGAGES, TECHNOLOGIES & FRAMEWORKS

### **Frontend**

#### **Flutter (Dart)**
- **Langage** : Dart 3.9.2
- **Framework** : Flutter multiplateforme
- **Avantages** : 
  - Une seule base de code pour Android, iOS et Web
  - Performance native
  - Interface moderne et responsive

#### **Gestion d'État**
- **Riverpod 3.0.3** : Gestion réactive de l'état
- **Flutter Secure Storage 9.2.4** : Stockage sécurisé des données sensibles

#### **Navigation & Routing**
- **Go Router 16.3.0** : Navigation déclarative
- **Smooth Page Indicator 1.1.0** : Indicateurs de pages

#### **Communication**
- **HTTP 1.5.0** : Requêtes REST API
- **STOMP Dart Client 2.0.0** : WebSocket pour chat temps réel
- **HTTP Parser 4.0.2** : Parsing des réponses HTTP

#### **UI/UX**
- **Image Picker 1.0.7** : Sélection d'images (profil, photos)
- **URL Launcher 6.3.2** : Ouverture de liens externes
- **Intl 0.20.2** : Internationalisation (FR/EN)
- **Flutter Localizations** : Support multilingue

#### **Utilitaires**
- **Shared Preferences 2.2.3** : Stockage local simple
- **Path Provider 2.1.1** : Accès aux chemins système

---

### **Backend**

#### **Spring Boot**
- **Framework** : Spring Boot (Java)
- **Architecture** : REST API + WebSocket
- **Avantages** :
  - Écosystème robuste et mature
  - Sécurité intégrée
  - Scalabilité

#### **Base de Données**
- **PostgreSQL** : Base de données relationnelle
- **ORM** : JPA/Hibernate pour la persistance
- **Avantages** :
  - Fiabilité et performance
  - Support des transactions
  - Relations complexes

#### **Communication Temps Réel**
- **WebSocket** : Connexion bidirectionnelle persistante
- **STOMP Protocol** : Simple Text Oriented Messaging Protocol
- **Avantages** :
  - Chat en temps réel
  - Notifications instantanées
  - Faible latence

---

## 🔐 MÉTHODES DE SÉCURITÉ

### **Authentification JWT (JSON Web Token)**

#### **Fonctionnement**
- **Génération** : Token créé après authentification réussie
- **Stockage** : Flutter Secure Storage (chiffré)
- **Validation** : Vérification à chaque requête API
- **Expiration** : Tokens avec durée de vie limitée

#### **Avantages**
- **Stateless** : Pas de session serveur
- **Scalable** : Fonctionne avec plusieurs serveurs
- **Sécurisé** : Signature cryptographique
- **Mobile-friendly** : Adapté aux applications mobiles

### **Sécurité des Données**

#### **Stockage Sécurisé**
- **Flutter Secure Storage** : Chiffrement des données sensibles
- **Tokens JWT** : Stockage sécurisé des credentials
- **Pas de mots de passe en clair** : Hashage côté serveur

#### **Communication Sécurisée**
- **HTTPS** : Toutes les communications chiffrées
- **Headers sécurisés** : Protection contre les attaques
- **Validation des entrées** : Protection contre injection

### **Gestion des Rôles**
- **RBAC (Role-Based Access Control)** : Contrôle d'accès par rôle
- **Permissions** : JEUNE, MENTOR, PARRAIN, CENTRE, ENTREPRISE
- **Validation backend** : Vérification des permissions à chaque endpoint

---

## 🔌 API & INTÉGRATION

### **API REST**

#### **Endpoints Principaux**
- **Authentification** : `/api/auth/login`, `/api/auth/register`
- **Formations** : `/api/formations`, `/api/formations/{id}`
- **Inscriptions** : `/api/inscriptions`, `/api/inscriptions/s-inscrire/{id}`
- **Parrainages** : `/api/parrainages/creer`, `/api/parrainages/demandes-en-attente`
- **Paiements** : `/api/paiements/creer`, `/api/paiements/valider`
- **Mentorings** : `/api/mentorings`, `/api/mentorings/{id}/messages`
- **Offres d'emploi** : `/api/offres`, `/api/offres/{id}`
- **Centres** : `/api/centres`, `/api/centres/me`
- **Utilisateurs** : `/api/utilisateurs/v1`, `/api/utilisateurs/register`

#### **Format des Réponses**
- **JSON** : Format standard pour toutes les réponses
- **Codes HTTP** : 200 (succès), 201 (créé), 400 (erreur), 401 (non autorisé), 404 (non trouvé), 500 (erreur serveur)

### **WebSocket API**

#### **Endpoints WebSocket**
- **Connexion** : `/ws` avec authentification JWT
- **Chat** : `/app/chat/{mentoringId}` (envoi)
- **Réception** : `/user/queue/messages` (réception)
- **Notifications** : `/user/queue/notifications`

#### **Protocole STOMP**
- **Subscribe** : Abonnement aux canaux de messages
- **Send** : Envoi de messages en temps réel
- **Disconnect** : Déconnexion propre

---

## 🛠️ OUTILS UTILISÉS

### **Développement**

#### **IDE & Éditeurs**
- **VS Code / Android Studio** : Environnement de développement
- **Flutter SDK** : Framework de développement
- **Dart SDK** : Langage de programmation

#### **Versioning**
- **Git** : Contrôle de version
- **GitHub** : Hébergement et collaboration
- **GitHub Projects** : Gestion de projet (Kanban)

#### **Design**
- **Figma** : Conception UI/UX et prototypage
- **Material Design** : Guidelines de design

### **Tests & Qualité**

#### **Tests API**
- **Postman** : Tests et documentation des endpoints
- **Insomnia** : Alternative pour tests API

#### **Tests Code**
- **Flutter Test** : Tests unitaires et widget
- **Integration Tests** : Tests d'intégration

### **Communication & Collaboration**

#### **Communication**
- **Slack / Discord** : Communication équipe
- **GitHub Issues** : Suivi des bugs et fonctionnalités

#### **Documentation**
- **Markdown** : Documentation technique
- **Swagger/OpenAPI** : Documentation API (si disponible)

### **Déploiement**

#### **Build & Compilation**
- **Flutter Build** : Compilation Android/iOS/Web
- **Gradle** : Build système Android
- **Xcode** : Build système iOS

#### **Distribution**
- **Google Play Store** : Distribution Android
- **Apple App Store** : Distribution iOS
- **Web Hosting** : Déploiement web

---

## 📊 ARCHITECTURE TECHNIQUE

### **Stack Complet**

```
┌─────────────────────────────────────────┐
│         FRONTEND (Flutter/Dart)         │
│  - Riverpod (State Management)          │
│  - HTTP Client (REST API)               │
│  - STOMP Client (WebSocket)             │
│  - Secure Storage (JWT)                 │
└──────────────┬──────────────────────────┘
               │ HTTPS / WebSocket
               ▼
┌─────────────────────────────────────────┐
│      BACKEND (Spring Boot/Java)        │
│  - REST API                             │
│  - WebSocket Server (STOMP)             │
│  - JWT Authentication                   │
│  - Security Layer                       │
└──────────────┬──────────────────────────┘
               │ JDBC
               ▼
┌─────────────────────────────────────────┐
│      BASE DE DONNÉES (PostgreSQL)       │
│  - Tables relationnelles                │
│  - Transactions                         │
│  - Indexes & Performance                │
└─────────────────────────────────────────┘
```

---

## ✅ RÉSUMÉ TECHNIQUE

### **Frontend**
- **Langage** : Dart 3.9.2
- **Framework** : Flutter
- **State Management** : Riverpod
- **Communication** : HTTP + WebSocket (STOMP)

### **Backend**
- **Framework** : Spring Boot (Java)
- **API** : REST + WebSocket
- **Base de données** : PostgreSQL

### **Sécurité**
- **Authentification** : JWT (JSON Web Token)
- **Stockage** : Flutter Secure Storage
- **Communication** : HTTPS
- **Contrôle d'accès** : RBAC (Role-Based Access Control)

### **Outils**
- **Versioning** : Git/GitHub
- **Gestion projet** : GitHub Projects
- **Design** : Figma
- **Tests API** : Postman
- **Communication** : Slack/Discord

---

**Date de création** : 2025  
**Stack** : Flutter + Spring Boot + PostgreSQL  
**Sécurité** : JWT + HTTPS + Secure Storage


