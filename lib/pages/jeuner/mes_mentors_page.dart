import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/chat_contact.dart';
import 'package:repartir_frontend/pages/jeuner/chat_detail_page.dart';
import 'package:repartir_frontend/pages/jeuner/chat_list_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';

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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
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
                              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF3EB2FF)),
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
            ),
          ),
          
          // Header avec bouton retour et titre
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Mes Mentors',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}
