import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/chat_detail_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';

// Modèle simple pour représenter un contact de chat
class ChatContact {
  final String name;
  final String lastMessage;
  final String imageUrl;

  ChatContact({required this.name, required this.lastMessage, required this.imageUrl});
}

// Page qui affiche la liste des conversations
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // Données factices pour la liste des chats
  final List<ChatContact> _allContacts = [
    ChatContact(name: 'Fatoumata Diawara', lastMessage: 'À bientôt pour ton entretien !', imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=FD'),
    ChatContact(name: 'Bakary Diallo', lastMessage: 'Super ! Merci pour ton aide', imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=BD'),
    ChatContact(name: 'Djibril Maiga', lastMessage: 'J\'ai trouvé un stage intéressant pour toi', imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=DM'),
    ChatContact(name: 'Amadou Diallo', lastMessage: 'On se retrouve à la bibliothèque ?', imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=AD'),
    ChatContact(name: 'Madjess Sylla', lastMessage: 'N\'oublie pas de préparer ton CV', imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=MS'),
    ChatContact(name: 'Ibrahim S Diallo', lastMessage: 'Voici le lien pour la formation', imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=ID'),
  ];

  List<ChatContact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredContacts = _allContacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        return contact.name.toLowerCase().contains(query);
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
              child: Padding(
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
                        hintText: 'Rechercher...',
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
                  // Liste des contacts
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filteredContacts.length,
                      separatorBuilder: (context, index) => const Divider(indent: 80, height: 1),
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(contact.imageUrl),
                          ),
                          title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(contact.lastMessage, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailPage(contact: contact),
                              ),
                            );
                          },
                        );
                      },
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
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}
