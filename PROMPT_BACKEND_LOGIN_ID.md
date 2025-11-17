# 🔧 BACKEND - Ajouter ID utilisateur dans réponse de login

**Objectif:** Le frontend a besoin de l'ID de l'utilisateur pour déterminer quels messages sont envoyés par lui (chat WhatsApp style).

---

## ❌ PROBLÈME ACTUEL

La réponse de login ne contient pas l'ID de l'utilisateur :

```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci...",
  "email": "olala@gmail.com",
  "role": [{"authority": "ROLE_MENTOR"}]
}
```

**Résultat:** Le frontend ne peut pas différencier les messages envoyés par l'utilisateur des messages reçus.

---

## ✅ SOLUTION

Ajouter le champ **`id`** dans la réponse JSON du login.

---

## 📝 CODE À MODIFIER

### **Fichier: AuthController.java (ou AuthService.java)**

```java
@PostMapping("/login")
public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
    try {
        // Authentification
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                loginRequest.getEmail(),
                loginRequest.getMotDePasse()
            )
        );
        
        SecurityContextHolder.getContext().setAuthentication(authentication);
        
        // Récupérer l'utilisateur depuis la base de données
        Utilisateur utilisateur = utilisateurRepository
            .findByEmail(loginRequest.getEmail())
            .orElseThrow(() -> new EntityNotFoundException("Utilisateur non trouvé"));
        
        // Générer les tokens JWT
        String accessToken = jwtServices.genererToken(utilisateur);
        String refreshToken = jwtServices.genererRefreshToken(utilisateur);
        
        // Construire la réponse avec l'ID
        Map<String, Object> response = new HashMap<>();
        response.put("access_token", accessToken);
        response.put("refresh_token", refreshToken);
        response.put("email", utilisateur.getEmail());
        response.put("role", utilisateur.getRoles());
        response.put("id", utilisateur.getId());  // ← AJOUTER CETTE LIGNE
        
        return ResponseEntity.ok(response);
        
    } catch (BadCredentialsException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
            .body("Email ou mot de passe incorrect");
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body("Erreur lors de la connexion: " + e.getMessage());
    }
}
```

---

## 🎯 RÉSULTAT ATTENDU

Après modification, la réponse de login doit ressembler à :

```json
{
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci...",
  "email": "olala@gmail.com",
  "role": [{"authority": "ROLE_MENTOR"}],
  "id": 14
}
```

---

## ⚠️ IMPORTANT

- **`id`** doit être l'ID de la table **`Utilisateur`** (pas l'ID de Mentor ou Jeune)
- C'est cet ID qui est utilisé dans la table **`Message`** comme `sender_id`

---

## 🧪 TESTER AVEC POSTMAN

```bash
POST http://localhost:8183/api/auth/login
Content-Type: application/json

{
  "email": "olala@gmail.com",
  "motDePasse": "votre_mot_de_passe"
}
```

**Vérifier que la réponse contient bien le champ `id`.**

---

## 📱 CÔTÉ FRONTEND

Une fois le backend corrigé, le frontend :
1. Recevra automatiquement l'ID lors du login
2. Le sauvegardera dans `secure_storage` avec la clé `user_id`
3. Pourra différencier les messages envoyés (à droite, bleu) des messages reçus (à gauche, gris)

---

**🎊 Après cette correction, le chat fonctionnera comme WhatsApp ! 🎊**


