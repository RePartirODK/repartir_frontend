# ✅ TEST FINAL DU CHAT - Après correction backend

**Backend corrigé:** L'ID utilisateur est maintenant renvoyé dans la réponse de login ✅

---

## 🔄 **ÉTAPE 1: REDÉMARRER LE BACKEND**

```bash
# Arrêter le backend Spring Boot (Ctrl+C)
# Puis redémarrer
mvn spring-boot:run
# OU
./mvnw spring-boot:run
```

**Vérifier que le backend démarre sans erreur.**

---

## 🧪 **ÉTAPE 2: TESTER AVEC POSTMAN (Optionnel mais recommandé)**

```bash
POST http://localhost:8183/api/auth/login
Content-Type: application/json

{
  "email": "olala@gmail.com",
  "motDePasse": "votre_mot_de_passe"
}
```

**Réponse attendue (200 OK) :**
```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "uuid...",
  "email": "olala@gmail.com",
  "role": [{"authority": "ROLE_MENTOR"}],
  "id": 14  ← ✅ CE CHAMP DOIT ÊTRE LÀ
}
```

---

## 📱 **ÉTAPE 3: SE RECONNECTER DANS L'APP FLUTTER**

### **3.1 Se déconnecter**
1. Ouvrir l'app Flutter (Chrome)
2. Aller dans **Profil** (ou Menu)
3. Cliquer sur **Déconnexion**

### **3.2 Se reconnecter**
1. Entrer email: `olala@gmail.com` (mentor)
2. Entrer mot de passe
3. Cliquer sur **Se connecter**

### **3.3 Vérifier les logs Flutter**

Vous devriez voir dans la console :

```
✅ UserId sauvegardé depuis login: 14
```

**Si vous voyez :**
```
⚠️ Le backend ne renvoie pas l'ID utilisateur dans la réponse de login !
```
→ Le backend n'a pas été redémarré ou la correction n'a pas été appliquée.

---

## 💬 **ÉTAPE 4: TESTER LE CHAT**

### **Scénario 1: Mentor envoie un message au Jeune**

1. **Connecté en tant que MENTOR** (olala@gmail.com)
2. Aller dans l'onglet **"Message"**
3. Cliquer sur une conversation avec un jeune
4. **Envoyer un message:** "Bonjour !"

**Résultat attendu dans les logs :**
```
👤 UserId récupéré depuis storage: 14
💬 Message: "Bonjour !"
   senderId=14, senderName=basibi
   currentUserId=14
   isSentByMe=true  ← ✅ DOIT ÊTRE TRUE
```

**Résultat visuel attendu :**
- ✅ Message "Bonjour !" apparaît **À DROITE** en **BLEU** (comme WhatsApp)
- ✅ Avatar du mentor à droite

---

### **Scénario 2: Jeune répond au Mentor**

1. **Se déconnecter** du compte mentor
2. **Se connecter en tant que JEUNE** (l'email du jeune de la conversation)
3. Aller dans **"Mes Mentors"**
4. Cliquer sur l'icône chat 💬 du mentor
5. **Envoyer un message:** "Salut !"

**Résultat attendu dans les logs :**
```
👤 UserId récupéré depuis storage: 5
💬 Message: "Bonjour !"
   senderId=14, senderName=basibi
   currentUserId=5
   isSentByMe=false  ← ✅ Message du mentor
💬 Message: "Salut !"
   senderId=5, senderName=Dembele
   currentUserId=5
   isSentByMe=true  ← ✅ Mon message
```

**Résultat visuel attendu :**
- ✅ Message "Bonjour !" (du mentor) apparaît **À GAUCHE** en **GRIS**
- ✅ Message "Salut !" (du jeune) apparaît **À DROITE** en **BLEU**

---

### **Scénario 3: Retour sur le compte Mentor**

1. **Se reconnecter en tant que MENTOR**
2. Aller dans l'onglet **"Message"**
3. Ouvrir la même conversation

**Résultat visuel attendu :**
- ✅ Message "Bonjour !" (du mentor) → **À DROITE** en **BLEU**
- ✅ Message "Salut !" (du jeune) → **À GAUCHE** en **GRIS**

---

## 🎯 **CHECKLIST FINALE**

### **Backend**
- [x] Code modifié dans `AuthService.java`
- [x] ID ajouté dans la réponse de login
- [ ] Backend redémarré
- [ ] Testé avec Postman (optionnel)

### **Frontend**
- [ ] Se déconnecter de l'app
- [ ] Se reconnecter (pour recevoir l'ID)
- [ ] Vérifier log: `✅ UserId sauvegardé depuis login: XX`
- [ ] Tester chat côté Mentor
- [ ] Tester chat côté Jeune
- [ ] Vérifier affichage: messages envoyés à droite (bleu), messages reçus à gauche (gris)

---

## ❌ **SI ÇA NE FONCTIONNE PAS**

### **Problème 1: UserId toujours null**

**Symptôme:**
```
👤 UserId récupéré depuis storage: null
⚠️ Pas d'userId dans storage
```

**Solutions:**
1. Vérifier que le backend a bien été redémarré
2. Tester le login avec Postman pour confirmer que l'ID est dans la réponse
3. Se déconnecter/reconnecter dans Flutter

---

### **Problème 2: Tous les messages à gauche**

**Symptôme:**
```
isSentByMe=false  (pour tous les messages)
```

**Solutions:**
1. Vérifier que `currentUserId` n'est pas null
2. Vérifier que `senderId` correspond bien à l'ID dans la table `Utilisateur`
3. Se reconnecter pour récupérer le bon ID

---

### **Problème 3: senderId ne correspond pas**

**Symptôme:**
```
senderId=2 (ID du Mentor dans table Mentor)
currentUserId=14 (ID dans table Utilisateur)
isSentByMe=false (alors que c'est mon message)
```

**Solution:**
⚠️ **IMPORTANT:** Le backend doit utiliser l'ID de la table **`Utilisateur`** dans la table `Message.sender_id`, PAS l'ID de Mentor/Jeune.

**Vérifier dans `ChatService.java` (backend) :**
```java
Message message = new Message();
message.setSender(sender);  // sender = Utilisateur (pas Mentor ou Jeune)
```

---

## 🎊 **RÉSULTAT FINAL ATTENDU**

Après toutes ces étapes, votre chat devrait fonctionner comme **WhatsApp** :

✅ Messages envoyés → À droite, en bleu  
✅ Messages reçus → À gauche, en gris  
✅ Ordre chronologique (ancien en haut, nouveau en bas)  
✅ Scroll automatique vers le dernier message  
✅ WebSocket temps réel (messages instantanés)  
✅ Suppression de ses propres messages (long press)  
✅ Indicateur "En ligne / Hors ligne"  
✅ Photos de profil affichées  

---

**🚀 Redémarrez le backend et testez ! Envoyez-moi les logs si ça ne fonctionne pas !**


