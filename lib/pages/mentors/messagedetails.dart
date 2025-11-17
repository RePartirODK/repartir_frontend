import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/chat_contact.dart';

// Modèle pour un message
class ChatMessage {
  final String text;
  final bool isSentByMe;
  final String time;

  ChatMessage({required this.text, required this.isSentByMe, required this.time});
}

// Page de détail d'une conversation
class MentorChatDetailPage extends StatefulWidget {
  final ChatContact contact;

  const MentorChatDetailPage({super.key, required this.contact});

  @override
  State<MentorChatDetailPage> createState() => _MentorChatDetailPageState();
}

class _MentorChatDetailPageState extends State<MentorChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  // Données factices pour la conversation
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Salut Ankur ! Quoi de neuf ?', isSentByMe: false, time: 'Hier 14:26'),
    ChatMessage(text: 'Oh, salut ! Tout va bien, je suis juste en train de sortir pour quelque chose', isSentByMe: true, time: 'Hier 14:38'),
    ChatMessage(text: 'Oui bien sûr, je serai là ce week-end avec mon frère', isSentByMe: true, time: 'Hier 14:50'),
    ChatMessage(text: 'Oui, je suis si contente 😀', isSentByMe: false, time: 'Hier 14:26'),
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: _controller.text, isSentByMe: true, time: 'Now'));
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  // AppBar personnalisée avec courbe
  PreferredSizeWidget _buildCustomAppBar() {
    const Color kPrimaryBlue = Color(0xFF2196F3);

    return PreferredSize(
      preferredSize: const Size.fromHeight(120.0), // Hauteur augmentée
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: kPrimaryBlue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blue[100], // Placeholder
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.contact.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour une bulle de message
  Widget _buildMessageBubble(ChatMessage message) {
    const Color kPrimaryBlue = Color(0xFF2196F3);
    const Color kPrimaryGreen = Color(0xFF4CAF50);

    final isSentByMe = message.isSentByMe;
    final contactAvatar = CircleAvatar(
      backgroundColor: Colors.blue[100], // Placeholder
      radius: 16,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            contactAvatar,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSentByMe ? kPrimaryBlue : kPrimaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: isSentByMe ? Colors.white : Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    // Icône "vu" retirée
                  ],
                ),
              ],
            ),
          ),
          if (isSentByMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Colors.grey, // Placeholder for user's avatar
              radius: 16,
            ),
          ],
        ],
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
                  hintText: 'Type your Message',
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
