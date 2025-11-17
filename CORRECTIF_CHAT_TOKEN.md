# 🔧 CORRECTIF - Token JWT manquant

**Date:** 12 novembre 2025  
**Problème:** `Exception: Token JWT manquant` lors de la connexion WebSocket

---

## ❌ **PROBLÈME IDENTIFIÉ**

### **Erreur 1: Mauvaise clé pour le token JWT**

**Fichier:** `lib/services/chat_service.dart`

```dart
// ❌ AVANT (erreur)
final token = await _storage.read(key: 'jwt_token');
```

**Le token est sauvegardé sous la clé `access_token` et non `jwt_token` !**

### **Erreur 2: Mauvaise clé pour le userId**

**Fichier:** `lib/pages/jeuner/chat_detail_page.dart`

```dart
// ❌ AVANT (erreur)
final userIdStr = await _storage.read(key: 'userId');
```

**Le userId est sauvegardé sous la clé `user_id` et non `userId` !**

---

## ✅ **CORRECTIONS APPLIQUÉES**

### **1. lib/services/chat_service.dart**

```dart
// ✅ APRÈS (corrigé)
final token = await _storage.read(key: 'access_token');
if (token == null) {
  throw Exception('Token JWT manquant');
}

print('💬 Token récupéré: ${token.substring(0, 20)}...');
```

### **2. lib/pages/jeuner/chat_detail_page.dart**

```dart
// ✅ APRÈS (corrigé)
final userIdStr = await _storage.read(key: 'user_id');
_currentUserId = userIdStr != null ? int.tryParse(userIdStr) : null;

print('👤 UserId récupéré: $_currentUserId');
```

---

## 📋 **CLÉS DU SECURE STORAGE**

Voici les **bonnes clés** définies dans `SecureStorageService`:

| Donnée | Clé | Méthode |
|--------|-----|---------|
| Token d'accès | `access_token` | `getAccessToken()` |
| Token de refresh | `refresh_token` | `getRefresToken()` |
| Rôle utilisateur | `user_role` | `getUserRole()` |
| Email utilisateur | `user_email` | `getUserEmail()` |
| ID utilisateur | `user_id` | `getUserId()` |

---

## 🎯 **RÉSULTAT ATTENDU**

Après correction, dans les logs vous devriez voir:

```
💬 Token récupéré: eyJhbGciOiJIUzI1NiJ...
💬 Connexion WebSocket en cours...
✅ Connecté au WebSocket
👤 UserId récupéré: 2
📜 Récupération historique chat pour mentoring 6
✅ 0 messages récupérés
📡 Abonnement au topic /topic/chat/6
```

---

## ⚠️ **RAPPEL**

Si le userId n'est toujours pas trouvé après ces corrections, **se reconnecter une fois** pour que le `auth_service.dart` le sauvegarde automatiquement lors du login.

---

**🎊 Le chat WebSocket devrait maintenant fonctionner ! 🎊**


