import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:repartir_frontend/pages/jeuner/chat_detail_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/services/mentor_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/chat_service.dart';
import 'package:repartir_frontend/models/conversation_info.dart';

// Page qui affiche la liste des conversations
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with WidgetsBindingObserver {
  final MentorService _mentorService = MentorService();
  final ProfileService _profileService = ProfileService();
  final ChatService _chatService = ChatService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  List<ConversationInfo> _allConversations = [];
  List<ConversationInfo> _filteredConversations = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  int? _currentUserId;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_filterContacts);
    _loadConversations();
    
    // Recharger la liste toutes les 3 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadConversations();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recharger quand l'app revient au premier plan
      _loadConversations();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    // Ne pas recharger si déjà en train de charger
    if (_isLoading && _allConversations.isNotEmpty) return;
    
    if (_allConversations.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      // Récupérer le profil pour avoir l'ID jeune
      final profile = await _profileService.getMe();
      final jeuneId = profile['id'] as int;
      
      // Récupérer l'ID utilisateur pour compter les messages non lus
      final userIdStr = await _storage.read(key: 'user_id');
      _currentUserId = userIdStr != null ? int.tryParse(userIdStr) : null;

      // Récupérer les mentorings du jeune
      final mentorings = await _mentorService.getJeuneMentorings(jeuneId);

      // Filtrer uniquement les mentorings VALIDE (conversations actives)
      final validMentorings = mentorings
          .where((m) => m['statut'] == 'VALIDE')
          .toList();

      // Enrichir chaque conversation avec le dernier message et les messages non lus
      final List<ConversationInfo> enrichedConversations = [];
      
      for (var mentoring in validMentorings) {
        final mentoringId = mentoring['id'] as int;
        final mentorName = '${mentoring['prenomMentor'] ?? ''} ${mentoring['nomMentor'] ?? ''}'.trim();
        final urlPhotoMentor = (mentoring['urlPhotoMentor'] ?? '').toString().trim();
        
        // Debug: Vérifier les données récupérées
        debugPrint('📸 Chat liste - Mentor: $mentorName, Photo: $urlPhotoMentor');
        
        // Récupérer l'historique des messages
        final messages = await _chatService.getMessageHistory(mentoringId);
        
        String? lastMessage;
        DateTime? lastMessageTime;
        int unreadCount = 0;
        
        if (messages.isNotEmpty) {
          final lastMsg = messages.last;
          lastMessage = lastMsg.content;
          lastMessageTime = lastMsg.timestamp;
          
          // Récupérer le timestamp du dernier message lu pour cette conversation
          final lastReadStr = await _storage.read(key: 'last_read_$mentoringId');
          DateTime? lastReadTime;
          if (lastReadStr != null) {
            try {
              lastReadTime = DateTime.parse(lastReadStr);
            } catch (e) {
              debugPrint('⚠️ Erreur parsing lastReadTime: $e');
            }
          } else {
            // Première utilisation : marquer tout comme déjà lu
            // (on ne compte pas les anciens messages comme "non lus")
            lastReadTime = DateTime.now();
            await _storage.write(
              key: 'last_read_$mentoringId',
              value: lastReadTime.toIso8601String(),
            );
          }
          
          // Compter uniquement les messages reçus APRÈS le dernier message lu
          if (_currentUserId != null) {
            unreadCount = messages.where((msg) {
              // Message de l'autre personne (pas moi)
              final isFromOther = msg.senderId != _currentUserId!;
              
              // Message plus récent que le dernier message lu
              final isUnread = msg.timestamp.isAfter(lastReadTime!);
              
              return isFromOther && isUnread;
            }).length;
          }
        }
        
        enrichedConversations.add(ConversationInfo(
          mentoringId: mentoringId,
          contactName: mentorName,
          contactPhoto: urlPhotoMentor,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          unreadCount: unreadCount,
          mentoring: mentoring,
        ));
      }
      
      // Trier par dernier message (le plus récent en haut)
      enrichedConversations.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      setState(() {
        _allConversations = enrichedConversations;
        _filteredConversations = enrichedConversations;
        _isLoading = false;
      });

      debugPrint('✅ ${_allConversations.length} conversations chargées et triées');
    } catch (e) {
      debugPrint('❌ Erreur chargement conversations: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConversations = _allConversations.where((conversation) {
        return conversation.contactName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenu principal
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _allConversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune conversation active',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // Barre de recherche
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher un mentor...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Liste des conversations
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: _loadConversations,
                                  child: ListView.separated(
                                    itemCount: _filteredConversations.length,
                                    separatorBuilder: (context, index) => const Divider(indent: 80, height: 1),
                                    itemBuilder: (context, index) {
                                      final conversation = _filteredConversations[index];
                                      
                                      return _buildConversationTile(conversation);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          
          // Header avec titre
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: 'Chats',
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ConversationInfo conversation) {
    // Formater le temps du dernier message
    String timeText = '';
    if (conversation.lastMessageTime != null) {
      final now = DateTime.now();
      final diff = now.difference(conversation.lastMessageTime!);
      
      if (diff.inDays == 0) {
        // Aujourd'hui: afficher l'heure
        timeText = DateFormat('HH:mm').format(conversation.lastMessageTime!);
      } else if (diff.inDays == 1) {
        timeText = 'Hier';
      } else if (diff.inDays < 7) {
        // Cette semaine: afficher le jour
        timeText = DateFormat('EEEE', 'fr_FR').format(conversation.lastMessageTime!);
      } else {
        // Plus ancien: afficher la date
        timeText = DateFormat('dd/MM/yy').format(conversation.lastMessageTime!);
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          ProfileAvatar(
            photoUrl: conversation.contactPhoto,
            radius: 28,
            isPerson: true,
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
            iconColor: const Color(0xFF6C63FF),
          ),
          // Badge pour messages non lus
          if (conversation.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  conversation.unreadCount > 99 
                      ? '99+' 
                      : '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.contactName,
        style: TextStyle(
          fontWeight: conversation.unreadCount > 0 
              ? FontWeight.bold 
              : FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage ?? 'Aucun message',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: conversation.unreadCount > 0 
                    ? Colors.black87
                    : Colors.grey[600],
                fontWeight: conversation.unreadCount > 0 
                    ? FontWeight.w500 
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeText,
            style: TextStyle(
              color: conversation.unreadCount > 0 
                  ? const Color(0xFF6C63FF)
                  : Colors.grey[500],
              fontSize: 12,
              fontWeight: conversation.unreadCount > 0 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              mentoringId: conversation.mentoringId,
              contactName: conversation.contactName,
              contactPhoto: conversation.contactPhoto,
            ),
          ),
        );
        
        // Recharger après retour du chat
        if (result == true || mounted) {
          await _loadConversations();
        }
      },
    );
  }
}
