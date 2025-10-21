import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/chat_detail_page.dart';
import 'package:repartir_frontend/pages/jeuner/chat_list_page.dart';

class MesMentorsPage extends StatelessWidget {
  const MesMentorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for mentors
    final mentors = [
      {
        'name': 'Booba Diallo',
        'speciality': 'Développeur Flutter',
        'avatar': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Amadou Diallo',
        'speciality': 'Designer UX/UI',
        'avatar': 'https://via.placeholder.com/150',
      }
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Mes Mentors'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final mentor = mentors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(mentor['avatar']!),
              ),
              title: Text(mentor['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(mentor['speciality']!),
              trailing: IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        contact: ChatContact(
                          name: mentor['name']!,
                          imageUrl: mentor['avatar']!,
                          lastMessage: '', // Last message is not available here
                        ),
                      ),
                    ),
                  );
                },
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          );
        },
      ),
    );
  }
}
