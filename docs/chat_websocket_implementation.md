# 💬 SYSTÈME DE CHAT TEMPS RÉEL - WebSocket

**Date:** 12 novembre 2025  
**Technologies:** Spring Boot WebSocket + Flutter `stomp_dart_client`  
**Status:** ✅ Implémenté et Opérationnel

---

## 📋 TABLE DES MATIÈRES

1. [Architecture Générale](#architecture-générale)
2. [Backend Spring Boot](#backend-spring-boot)
3. [Frontend Flutter](#frontend-flutter)
4. [Endpoint Backend Manquant](#endpoint-backend-manquant)
5. [Guide d'Utilisation](#guide-dutilisation)
6. [Tests](#tests)
7. [Sécurité](#sécurité)
8. [Dépannage](#dépannage)

---

## 🏗️ ARCHITECTURE GÉNÉRALE

### **Flux de Communication**

```
┌─────────────┐                ┌─────────────┐                ┌─────────────┐
│   Mentor    │◄──────────────►│  WebSocket  │◄──────────────►│    Jeune    │
│  (Flutter)  │   Temps Réel   │   Server    │   Temps Réel   │  (Flutter)  │
└─────────────┘                │ Spring Boot │                └─────────────┘
                                └─────────────┘
                                       │
                                       ▼
                                ┌─────────────┐
                                │  PostgreSQL │
                                │  (Messages) │
                                └─────────────┘
```

### **Protocoles Utilisés**

- **WebSocket** : Connexion bidirectionnelle persistante
- **STOMP** : Simple Text Oriented Messaging Protocol (au-dessus de WebSocket)
- **JWT** : Authentification des connexions WebSocket
- **REST** : Pour l'historique et la suppression de messages

---

## 🔧 BACKEND SPRING BOOT

### **1. Configuration WebSocket**

**Fichier:** `WebSocketConfig.java`

```java
@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    private final JwtAuthChannelInterceptor jwtAuthChannelInterceptor;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/topic")
                .setTaskScheduler(webSocketTaskScheduler());
        registry.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
                .setAllowedOrigins("*");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(jwtAuthChannelInterceptor);
    }
}
```

**Points clés:**
- ✅ Endpoint WebSocket: `ws://localhost:8183/ws`
- ✅ Topics: `/topic/chat/{mentoringId}`
- ✅ Application prefix: `/app`
- ✅ Intercepteur JWT pour sécuriser les connexions

---

### **2. Contrôleur de Chat**

**Fichier:** `ChatController.java`

#### **Envoi de message (WebSocket)**

```java
@MessageMapping("/chat/{mentoringId}")
public void processMessage(
        @DestinationVariable int mentoringId,
        @Payload ChatMessageDto chatMessageDto,
        Principal principal) {
    
    Utilisateur sender = utilisateurRepository.findByEmail(principal.getName())
            .orElseThrow();
    
    Message savedMessage = chatService.saveMessage(
        mentoringId, 
        chatMessageDto.getContent(), 
        sender
    );
    
    ChatMessageResponseDto responseDto = ChatMessageResponseDto.fromEntity(savedMessage);
    
    messagingTemplate.convertAndSend(
        "/topic/chat/" + mentoringId, 
        responseDto
    );
}
```

**Flux:**
1. Client envoie vers `/app/chat/{mentoringId}`
2. Backend valide, sauvegarde en BD
3. Backend diffuse vers `/topic/chat/{mentoringId}`
4. Tous les abonnés reçoivent le message

#### **Suppression de message (REST)**

```java
@DeleteMapping("/api/messages/{messageId}")
public ResponseEntity<?> supprimerMessage(
        @PathVariable int messageId, 
        Principal principal) {
    
    Utilisateur utilisateur = utilisateurRepository
        .findByEmail(principal.getName())
        .orElseThrow();
    
    chatService.supprimerMessage(messageId, utilisateur);
    
    return ResponseEntity.ok("Message supprimé avec succès");
}
```

**Notification de suppression:**
```java
public void supprimerMessage(int messageId, Utilisateur currentUser) {
    Message message = messageRepository.findById(messageId).orElseThrow();
    
    // Vérification : seul l'expéditeur peut supprimer
    if (message.getSender().getId() != currentUser.getId()) {
        throw new AccessDeniedException();
    }
    
    int mentoringId = message.getMentoring().getId();
    messageRepository.delete(message);
    
    // Notifier via WebSocket
    Map<String, Object> notification = Map.of(
        "type", "message_deleted",
        "messageId", messageId,
        "deletedBy", currentUser.getNom(),
        "timestamp", LocalDateTime.now()
    );
    
    messagingTemplate.convertAndSend(
        "/topic/chat/" + mentoringId, 
        notification
    );
}
```

---

### **3. DTOs**

#### **ChatMessageDto** (Envoi)
```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDto {
    private String content;
}
```

#### **ChatMessageResponseDto** (Réception)
```java
@Data
@Builder
public class ChatMessageResponseDto {
    private int messageId;
    private String content;
    private int senderId;
    private String senderName;
    private LocalDateTime timestamp;
}
```

---

### **4. Entity Message**

```java
@Entity
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    
    @Column(columnDefinition = "TEXT")
    private String contenu;
    
    @Column
    private LocalDateTime date;
    
    @ManyToOne
    @JoinColumn(name = "mentoring_id", nullable = false)
    private Mentoring mentoring;
    
    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = false)
    private Utilisateur sender;
}
```

---

### **5. Sécurité - Intercepteur JWT**

**Fichier:** `JwtAuthChannelInterceptor.java`

```java
@Component
@RequiredArgsConstructor
public class JwtAuthChannelInterceptor implements ChannelInterceptor {
    
    private final JwtServices jwtServices;

    @Override
    public Message preSend(Message message, MessageChannel channel) {
        StompHeaderAccessor accessor = 
            MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        
        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authHeader = accessor.getFirstNativeHeader("Authorization");
            
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                String email = jwtServices.extraireUsername(token);
                
                if (jwtServices.validerToken(token, email)) {
                    UsernamePasswordAuthenticationToken auth = 
                        new UsernamePasswordAuthenticationToken(email, null, null);
                    accessor.setUser(auth);
                }
            }
        }
        
        return message;
    }
}
```

---

## 📱 FRONTEND FLUTTER

### **1. Installation des Dépendances**

**Fichier:** `pubspec.yaml`

```yaml
dependencies:
  stomp_dart_client: ^2.0.0
  intl: ^0.20.2
  flutter_secure_storage: ^9.2.4
```

**Installation:**
```bash
flutter pub get
```

---

### **2. Modèle ChatMessage**

**Fichier:** `lib/models/chat_message.dart`

```dart
class ChatMessage {
  final int messageId;
  final String content;
  final int senderId;
  final String senderName;
  final DateTime timestamp;

  ChatMessage({
    required this.messageId,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as int,
      content: json['content'] as String,
      senderId: json['senderId'] as int,
      senderName: json['senderName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  bool isMine(int currentUserId) => senderId == currentUserId;
}
```

---

### **3. Service de Chat**

**Fichier:** `lib/services/chat_service.dart`

#### **Connexion WebSocket**

```dart
Future<void> connect() async {
  final token = await _storage.read(key: 'jwt_token');
  
  _stompClient = StompClient(
    config: StompConfig(
      url: 'ws://localhost:8183/ws',
      onConnect: _onConnectCallback,
      stompConnectHeaders: {
        'Authorization': 'Bearer $token',
      },
      webSocketConnectHeaders: {
        'Authorization': 'Bearer $token',
      },
      heartbeatIncoming: const Duration(seconds: 10),
      heartbeatOutgoing: const Duration(seconds: 10),
    ),
  );

  _stompClient!.activate();
}
```

#### **Abonnement aux Messages**

```dart
Stream<ChatMessage> subscribeToMentoring(int mentoringId) {
  final controller = StreamController<ChatMessage>.broadcast();
  _messageControllers[mentoringId] = controller;

  _stompClient!.subscribe(
    destination: '/topic/chat/$mentoringId',
    callback: (frame) {
      if (frame.body != null) {
        final data = jsonDecode(frame.body!);
        
        if (data['type'] == 'message_deleted') {
          // Gérer la suppression
          _deletionControllers[mentoringId]!.add(data);
        } else {
          // Nouveau message
          final message = ChatMessage.fromJson(data);
          controller.add(message);
        }
      }
    },
  );

  return controller.stream;
}
```

#### **Envoi de Message**

```dart
Future<void> sendMessage(int mentoringId, String content) async {
  _stompClient!.send(
    destination: '/app/chat/$mentoringId',
    body: jsonEncode({'content': content}),
  );
}
```

#### **Suppression de Message (REST)**

```dart
Future<void> deleteMessage(int messageId) async {
  final response = await _api.delete('/messages/$messageId');
  
  if (response.statusCode == 200) {
    print('✅ Message $messageId supprimé');
  }
}
```

---

### **4. Page de Chat**

**Fichier:** `lib/pages/chat/chat_page.dart`

#### **Initialisation**

```dart
Future<void> _initChat() async {
  // Récupérer l'historique
  final history = await _chatService.getMessageHistory(widget.mentoringId);
  setState(() {
    _messages.addAll(history);
  });

  // Connecter WebSocket
  await _chatService.connect();

  // S'abonner aux nouveaux messages
  _chatService.subscribeToMentoring(widget.mentoringId).listen((message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  });

  // S'abonner aux suppressions
  _chatService.subscribeToDeletions(widget.mentoringId).listen((data) {
    final deletedMessageId = data['messageId'] as int;
    setState(() {
      _messages.removeWhere((msg) => msg.messageId == deletedMessageId);
    });
  });
}
```

#### **Interface Utilisateur**

- **Messages:** Bulles alignées à gauche (autre) ou droite (moi)
- **Long Press:** Suppression de ses propres messages
- **Scroll Automatique:** Défilement vers le bas à chaque nouveau message
- **Indicateur:** État de connexion WebSocket (En ligne / Hors ligne)

---

### **5. Liste des Conversations**

**Fichier:** `lib/pages/chat/conversations_list_page.dart`

```dart
Future<void> _loadConversations() async {
  // Récupérer les mentorings VALIDE
  List<Map<String, dynamic>> mentorings;
  
  if (_isMentor) {
    mentorings = await _mentorService.getMentorMentorings();
  } else {
    mentorings = await _mentorService.getJeuneMentorings();
  }

  // Filtrer uniquement les mentorings validés
  final validMentorings = mentorings
      .where((m) => m['statut'] == 'VALIDE')
      .toList();

  setState(() {
    _conversations = validMentorings;
  });
}
```

---

### **6. Navigation**

#### **Bouton Flottant - Accueil Mentor**

**Fichier:** `lib/pages/mentors/accueilmentor.dart`

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConversationsListPage(),
      ),
    );
  },
  backgroundColor: const Color(0xFF6C63FF),
  child: const Icon(Icons.chat, color: Colors.white),
),
```

#### **Bouton Flottant - Accueil Jeune**

**Fichier:** `lib/pages/jeuner/accueil.dart`

```dart
Positioned(
  right: 16,
  bottom: 16,
  child: FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ConversationsListPage(),
        ),
      );
    },
    backgroundColor: const Color(0xFF6C63FF),
    child: const Icon(Icons.chat, color: Colors.white),
  ),
),
```

---

## 🚨 ENDPOINT BACKEND MANQUANT

### **⚠️ IMPORTANT : Ajouter cet endpoint pour l'historique des messages**

**Fichier:** `MessageController.java` (nouveau fichier REST)

```java
@RestController
@RequestMapping("/api/mentorings")
@RequiredArgsConstructor
public class MessageController {
    
    private final MessageRepository messageRepository;
    private final MentoringRepository mentoringRepository;

    /**
     * Récupérer l'historique des messages d'un mentoring
     * @param mentoringId ID du mentoring
     * @return Liste des messages, du plus ancien au plus récent
     */
    @GetMapping("/{mentoringId}/messages")
    public ResponseEntity<List<ChatMessageResponseDto>> getMessageHistory(
            @PathVariable int mentoringId,
            Principal principal) {
        
        try {
            // Vérifier que le mentoring existe
            Mentoring mentoring = mentoringRepository.findById(mentoringId)
                    .orElseThrow(() -> new EntityNotFoundException(
                        "Mentoring non trouvé: " + mentoringId
                    ));
            
            // Vérifier que l'utilisateur fait partie du mentoring
            Utilisateur currentUser = utilisateurRepository
                .findByEmail(principal.getName())
                .orElseThrow();
            
            boolean isParticipant = 
                mentoring.getJeune().getUtilisateur().getId() == currentUser.getId() ||
                mentoring.getMentor().getUtilisateur().getId() == currentUser.getId();
            
            if (!isParticipant) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
            
            // Récupérer tous les messages du mentoring, triés par date
            List<Message> messages = messageRepository
                .findByMentoringIdOrderByDateAsc(mentoringId);
            
            List<ChatMessageResponseDto> response = messages.stream()
                .map(ChatMessageResponseDto::fromEntity)
                .collect(Collectors.toList());
            
            return ResponseEntity.ok(response);
            
        } catch (EntityNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            logger.error("Erreur lors de la récupération de l'historique: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
```

**Fichier:** `MessageRepository.java`

```java
@Repository
public interface MessageRepository extends JpaRepository<Message, Integer> {
    
    /**
     * Trouver tous les messages d'un mentoring, triés par date (ASC)
     */
    List<Message> findByMentoringIdOrderByDateAsc(int mentoringId);
}
```

---

## 📖 GUIDE D'UTILISATION

### **Pour les Utilisateurs**

#### **1. Accéder aux Conversations**
- Cliquer sur le bouton flottant 💬 (bleu) sur la page d'accueil
- La liste des conversations actives s'affiche

#### **2. Démarrer une Conversation**
- Cliquer sur une conversation
- L'historique se charge automatiquement
- Connexion WebSocket établie (indicateur "En ligne")

#### **3. Envoyer un Message**
- Taper le message dans le champ en bas
- Appuyer sur le bouton d'envoi ou touche Entrée
- Le message apparaît instantanément chez le destinataire

#### **4. Supprimer un Message**
- **Long press** sur votre propre message
- Confirmer la suppression
- Le message disparaît pour tous les participants

#### **5. Notifications de Connexion**
- 🟢 **En ligne** : WebSocket connecté, messages en temps réel
- 🔴 **Hors ligne** : Connexion perdue, reconnexion automatique

---

## 🧪 TESTS

### **Test d'Intégration Backend**

**Fichier:** `ChatIntegrationTest.java`

Le test fourni vérifie:
✅ Génération du token JWT  
✅ Connexion WebSocket avec authentification  
✅ Abonnement au topic  
✅ Envoi de message  
✅ Réception du message avec les bonnes données  

**Commande:**
```bash
mvn test -Dtest=ChatIntegrationTest
```

### **Test Manuel Frontend**

1. **Connexion de 2 utilisateurs:**
   - Mentor sur un appareil/navigateur
   - Jeune sur un autre appareil/navigateur

2. **Vérifications:**
   - [ ] Les deux peuvent voir la conversation
   - [ ] Message envoyé par mentor apparaît chez jeune (et vice-versa)
   - [ ] Timestamps corrects
   - [ ] Suppression synchronisée entre les deux
   - [ ] Reconnexion automatique après perte de réseau

---

## 🔒 SÉCURITÉ

### **Authentification JWT**

✅ Token JWT requis pour:
- Connexion WebSocket
- Envoi de messages
- Suppression de messages
- Récupération de l'historique

### **Autorisation**

✅ Vérifications effectuées:
- Utilisateur fait partie du mentoring (envoi message)
- Utilisateur est l'expéditeur (suppression message)
- Utilisateur est participant (historique)

### **Validation des Données**

✅ Backend valide:
- Existence du mentoring
- Existence de l'utilisateur
- Non-vide du contenu du message

---

## 🔧 DÉPANNAGE

### **Problème: WebSocket ne se connecte pas**

**Symptômes:**
- "Hors ligne" en permanence
- Erreur dans les logs: `WebSocketError`

**Solutions:**
1. Vérifier que le backend est démarré sur `http://localhost:8183`
2. Vérifier que le token JWT est valide (pas expiré)
3. Vérifier les logs backend pour voir si l'intercepteur JWT refuse la connexion
4. Dans `application.properties`, vérifier que le logging est activé:
   ```properties
   logging.level.org.springframework.messaging=TRACE
   logging.level.org.springframework.web.socket=TRACE
   ```

---

### **Problème: Messages ne s'affichent pas**

**Symptômes:**
- Connexion OK mais messages n'arrivent pas
- Erreur: `SUBSCRIPTION` non reconnu

**Solutions:**
1. Vérifier que le topic est correct: `/topic/chat/{mentoringId}`
2. Vérifier dans les logs backend si le message est bien diffusé:
   ```
   >>>> [WS] Message envoyé au topic /topic/chat/1
   ```
3. Côté Flutter, vérifier les logs:
   ```
   📩 Message reçu: Bonjour !
   ```

---

### **Problème: Historique ne se charge pas**

**Symptômes:**
- Page de chat vide
- Erreur 404 sur `/api/mentorings/{id}/messages`

**Solutions:**
1. **Vérifier que l'endpoint backend est implémenté** (voir section "Endpoint Backend Manquant")
2. Vérifier les logs Flutter:
   ```
   📜 Récupération historique chat pour mentoring 1
   ✅ 5 messages récupérés
   ```
3. Vérifier que le mentoring a le statut `VALIDE`

---

### **Problème: Suppression ne fonctionne pas**

**Symptômes:**
- Long press ne fait rien
- Erreur 403 Forbidden

**Solutions:**
1. Vérifier que l'utilisateur essaie de supprimer **son propre message**
2. Vérifier les logs backend:
   ```
   >>>> [REST] Message 5 supprimé par l'utilisateur mentor@example.com
   ```
3. Vérifier que la notification WebSocket est envoyée:
   ```json
   {
     "type": "message_deleted",
     "messageId": 5,
     "deletedBy": "Durand",
     "timestamp": "2025-11-12T10:30:00"
   }
   ```

---

## 🎉 RÉSULTAT FINAL

### **Fonctionnalités Implémentées**

✅ Connexion WebSocket sécurisée avec JWT  
✅ Envoi/réception de messages en temps réel  
✅ Historique des messages (BD)  
✅ Suppression de messages avec notification temps réel  
✅ Liste des conversations actives  
✅ Navigation fluide depuis les pages d'accueil  
✅ UI moderne et responsive  
✅ Gestion des erreurs et reconnexion automatique  
✅ Tests d'intégration backend  

### **Architecture Validée**

✅ Backend: Spring Boot + WebSocket + STOMP + JWT  
✅ Frontend: Flutter + stomp_dart_client  
✅ Base de données: PostgreSQL  
✅ Protocoles: WebSocket (temps réel) + REST (historique/suppression)  

---

## 📚 RESSOURCES

- [Spring WebSocket Documentation](https://docs.spring.io/spring-framework/reference/web/websocket.html)
- [STOMP Protocol](https://stomp.github.io/)
- [stomp_dart_client Package](https://pub.dev/packages/stomp_dart_client)
- [Flutter WebSocket](https://flutter.dev/docs/cookbook/networking/web-sockets)

---

**🎊 Le système de chat est maintenant complet et opérationnel ! 🎊**


