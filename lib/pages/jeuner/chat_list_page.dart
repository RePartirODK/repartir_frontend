import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/chat_detail_page.dart';

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
    ChatContact(name: 'Fatoumata Diawara', lastMessage: 'À bientôt pour ton entretien !', imageUrl: 'assets/images/user1.png'),
    ChatContact(name: 'Bakary Diallo', lastMessage: 'Super ! Merci pour ton aide', imageUrl: 'assets/images/user2.png'),
    ChatContact(name: 'Djibril Maiga', lastMessage: 'J\'ai trouvé un stage intéressant pour toi', imageUrl: 'assets/images/user3.png'),
    ChatContact(name: 'Amadou Diallo', lastMessage: 'On se retrouve à la bibliothèque ?', imageUrl: 'assets/images/user4.png'),
    ChatContact(name: 'Madjess Sylla', lastMessage: 'N\'oublie pas de préparer ton CV', imageUrl: 'assets/images/user5.png'),
    ChatContact(name: 'Ibrahim S Diallo', lastMessage: 'Voici le lien pour la formation', imageUrl: 'assets/images/user6.png'),
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
    return Stack(
      children: [
        // Arrière-plan de la page, par défaut en blanc pour éviter les bandes grises
        Container(color: Colors.white),

        // En-tête bleu
        Container(
          height: 160,
          decoration: const BoxDecoration(
            color: Color(0xFF2196F3),
          ),
        ),

        // Contenu principal scrollable avec la courbe
        Padding(
          padding: const EdgeInsets.only(top: 80.0), // Décale le début de la carte blanche
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Titre "Chats"
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                            backgroundColor: Colors.blue[100], // Placeholder pour l'avatar
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
      ],
    );
  }
}
