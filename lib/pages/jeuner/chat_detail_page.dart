import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../services/api_service.dart';
import '../../services/profile_service.dart';

// Page de détail d'une conversation
class ChatDetailPage extends StatefulWidget {
  final int mentoringId;
  final String contactName;
  final String contactPhoto;

  const ChatDetailPage({
    super.key,
    required this.mentoringId,
    required this.contactName,
    required this.contactPhoto,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isConnecting = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    setState(() {
      _isLoading = true;
      _isConnecting = true;
    });

    try {
      // Récupérer l'ID de l'utilisateur courant (ID dans la table Utilisateur)
      final userIdStr = await _storage.read(key: 'user_id');
      _currentUserId = userIdStr != null ? int.tryParse(userIdStr) : null;
      
      debugPrint('👤 UserId récupéré depuis storage: $_currentUserId');
      
      // Si pas d'userId dans storage, essayer de le récupérer depuis le profil via API
      if (_currentUserId == null) {
        debugPrint('⚠️ Pas d\'userId dans storage, tentative de récupération depuis le profil...');
        try {
          // Essayer de récupérer depuis le profil utilisateur via ProfileService
          final ProfileService profileService = ProfileService();
          final profile = await profileService.getMe();
          
          // Le profil peut contenir l'ID directement ou dans utilisateur
          if (profile.containsKey('utilisateur')) {
            final utilisateur = profile['utilisateur'] as Map<String, dynamic>?;
            if (utilisateur != null && utilisateur.containsKey('id')) {
              _currentUserId = utilisateur['id'] as int?;
            }
          } else if (profile.containsKey('id')) {
            // Certains profils ont l'ID directement
            _currentUserId = profile['id'] as int?;
          }
          
          if (_currentUserId != null) {
            await _storage.write(key: 'user_id', value: _currentUserId.toString());
            debugPrint('✅ UserId récupéré depuis le profil: $_currentUserId');
          } else {
            debugPrint('⚠️ Profil récupéré mais aucun ID utilisateur trouvé');
          }
        } catch (e) {
          debugPrint('❌ Impossible de récupérer l\'userId depuis le profil: $e');
        }
      }
      
      if (_currentUserId == null) {
        debugPrint('❌ CRITIQUE: Aucun userId disponible. Les messages ne pourront pas être différenciés.');
      }

      // Récupérer l'historique des messages
      final history = await _chatService.getMessageHistory(widget.mentoringId);
      setState(() {
        _messages.addAll(history);
        _isLoading = false;
      });

      // Marquer tous les messages comme lus
      await _markAsRead();

      // Connecter au WebSocket
      await _chatService.connect();
      setState(() {
        _isConnecting = false;
      });

      // S'abonner aux nouveaux messages
      _chatService.subscribeToMentoring(widget.mentoringId).listen((message) {
        setState(() {
          // Vérifier si c'est un message optimiste à remplacer
          final optimisticIndex = _messages.indexWhere(
            (msg) => msg.messageId == -1 && 
                     msg.content == message.content &&
                     msg.senderId == message.senderId
          );
          
          if (optimisticIndex != -1) {
            // Remplacer le message optimiste par le vrai message du serveur
            _messages[optimisticIndex] = message;
          } else {
            // Vérifier qu'on n'ajoute pas un doublon
            final exists = _messages.any((msg) => msg.messageId == message.messageId);
            if (!exists) {
              _messages.add(message);
            }
          }
        });
        _scrollToBottom();
        // Marquer comme lu quand un nouveau message arrive
        _markAsRead();
      });

      // S'abonner aux suppressions de messages
      _chatService.subscribeToDeletions(widget.mentoringId).listen((data) {
        final deletedMessageId = data['messageId'] as int;
        setState(() {
          _messages.removeWhere((msg) => msg.messageId == deletedMessageId);
        });
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Erreur initialisation chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: $e')),
        );
      }
      setState(() {
        _isLoading = false;
        _isConnecting = false;
      });
    }
  }

  /// Marquer tous les messages de cette conversation comme lus
  Future<void> _markAsRead() async {
    if (_messages.isEmpty) return;
    
    // Sauvegarder le timestamp du dernier message
    final lastMessage = _messages.last;
    await _storage.write(
      key: 'last_read_${widget.mentoringId}',
      value: lastMessage.timestamp.toIso8601String(),
    );
    
    debugPrint('✅ Messages marqués comme lus pour mentoring ${widget.mentoringId}');
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Vérifier que nous avons un userId
    if (_currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Impossible de déterminer votre identité. Veuillez vous reconnecter.')),
        );
      }
      return;
    }

    // Créer un message optimiste (affiché immédiatement)
    final optimisticMessage = ChatMessage(
      messageId: -1, // ID temporaire négatif pour identifier les messages optimistes
      content: text,
      senderId: _currentUserId!,
      senderName: 'Moi',
      timestamp: DateTime.now(),
    );

    // Ajouter le message optimiste immédiatement
    setState(() {
      _messages.add(optimisticMessage);
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Envoyer le message via WebSocket
      await _chatService.sendMessage(widget.mentoringId, text);
    } catch (e) {
      // En cas d'erreur, retirer le message optimiste
      setState(() {
        _messages.removeWhere((msg) => msg.messageId == -1 && msg.content == text);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'envoi: $e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le message'),
        content: const Text('Voulez-vous vraiment supprimer ce message ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _chatService.deleteMessage(message.messageId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de suppression: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun message.\nCommencez la conversation !',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message, index);
                      },
                    ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  // AppBar personnalisée avec courbe
  PreferredSizeWidget _buildCustomAppBar() {
    const Color kPrimaryBlue = Color(0xFF2196F3);

    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: kPrimaryBlue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            boxShadow: [], // Pas d'ombre
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: widget.contactPhoto.isNotEmpty && widget.contactPhoto.startsWith('http')
                        ? NetworkImage(widget.contactPhoto)
                        : null,
                    child: widget.contactPhoto.isEmpty || !widget.contactPhoto.startsWith('http')
                        ? const Icon(Icons.person, color: Colors.blue, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contactName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _chatService.isConnected ? 'En ligne' : 'Hors ligne',
                          style: TextStyle(
                            color: _chatService.isConnected
                                ? Colors.greenAccent
                                : Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour une bulle de message
  Widget _buildMessageBubble(ChatMessage message, int index) {
    const Color kPrimaryBlue = Color(0xFF2196F3);
    const Color kPrimaryGreen = Color(0xFF4CAF50);

    // Déterminer si le message est envoyé par l'utilisateur actuel
    // Pour les messages optimistes (messageId == -1), on vérifie aussi le senderId
    final isSentByMe = _currentUserId != null && 
                       (message.isMine(_currentUserId!) || 
                        (message.messageId == -1 && message.senderId == _currentUserId));
    
    // 🔍 Debug: Afficher les IDs pour comprendre le problème (seulement pour les premiers messages)
    if (index < 3) {
      final preview = message.content.length > 20 
          ? '${message.content.substring(0, 20)}...' 
          : message.content;
      debugPrint('💬 Message[$index]: "$preview"');
      debugPrint('   messageId=${message.messageId}, senderId=${message.senderId}, senderName=${message.senderName}');
      debugPrint('   currentUserId=$_currentUserId');
      debugPrint('   isSentByMe=$isSentByMe');
    }
    
    final contactAvatar = CircleAvatar(
      backgroundColor: Colors.blue[100],
      backgroundImage: widget.contactPhoto.isNotEmpty && widget.contactPhoto.startsWith('http')
          ? NetworkImage(widget.contactPhoto)
          : null,
      
      radius: 16,
      child: widget.contactPhoto.isEmpty || !widget.contactPhoto.startsWith('http')
          ? const Icon(Icons.person, color: Colors.blue, size: 14)
          : null,
    );

    return GestureDetector(
      onLongPress: isSentByMe ? () => _deleteMessage(message) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar à gauche pour les messages reçus
            if (!isSentByMe) ...[
              contactAvatar,
              const SizedBox(width: 8),
            ],
            // Bulle de message
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSentByMe ? kPrimaryBlue : kPrimaryGreen,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isSentByMe ? 18 : 4),
                        bottomRight: Radius.circular(isSentByMe ? 4 : 18),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isSentByMe ? Colors.white : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
            // Avatar à droite pour les messages envoyés
            if (isSentByMe) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: Colors.blueGrey,
                radius: 16,
                child: Icon(Icons.person, color: Colors.white, size: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget pour le champ de saisie de texte
  Widget _buildMessageComposer() {
    const Color kPrimaryBlue = Color(0xFF2196F3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600]),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Tapez votre message',
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
