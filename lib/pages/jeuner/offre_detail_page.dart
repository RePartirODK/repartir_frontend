import 'package:flutter/material.dart';

class OffreDetailPage extends StatelessWidget {
  const OffreDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for job details
    final offreDetails = {
      'logo': 'https://via.placeholder.com/150',
      'company': 'FMP',
      'location': 'Bamako, Mali',
      'description_title': 'Description',
      'description_body': 'Nous recherchons un menuisier expérimenté et passionné par la création de meubles modernes et durables. Le candidat travaillera sur la fabrication, l\'assemblage et la finition de produits en bois dans notre atelier à Bamako. Vous intégrerez une équipe dynamique dédiée à l\'innovation artisanale et au design écologique.',
      'competences_title': 'Compétences requises',
      'competences_body': '• Maîtrise des outils de coupe, rabotage, ponçage et assemblage\n• Connaissance des matériaux bois, composites et vernis\n• Savoir lire et interpréter les plans techniques\n• Esprit d\'équipe, précision et sens du détail\n• Expérience dans la fabrication de meubles sur mesure ou agencements intérieurs\n• Capacité à respecter les normes de sécurité et les délais de production',
      'dates_title': 'Dates',
      'dates_body': 'Du 15 septembre 2023 au 15 décembre 2023',
      'type': 'CDD',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 180,
            color: Colors.blue,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: BackButton(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, offreDetails),
                    const SizedBox(height: 20),
                    _buildSection(offreDetails['description_title']!, offreDetails['description_body']!),
                    const SizedBox(height: 20),
                    _buildSection(offreDetails['competences_title']!, offreDetails['competences_body']!),
                    const SizedBox(height: 20),
                    _buildSection(offreDetails['dates_title']!, offreDetails['dates_body']!, icon: Icons.date_range),
                    const SizedBox(height: 20),
                    _buildInfoBox(offreDetails),
                     const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Afficher un message ou naviguer vers une page de candidature
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité de candidature en développement'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          
                          // Ou si vous voulez naviguer vers une autre page :
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => CandidaturePage(), // Remplacer par votre page de candidature
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Postuler"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, String> details) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(details['logo']!),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details['company']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(details['location']!, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 10),
         Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(content, style: const TextStyle(fontSize: 16, height: 1.5))),
          ],
        ),
      ],
    );
  }

   Widget _buildInfoBox(Map<String, String> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(details['type']!),
        ],
      ),
    );
  }
}
