import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/detail_offre_commune_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';

class OffreListPage extends StatelessWidget {
  const OffreListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for job offers
    final offres = [
      {
        'titre': 'Stage Marketing Digital',
        'type_contrat': 'Stage',
        'entreprise': 'DigitalBoost',
        'lieu': 'Bamako, Mali',
        'datePublication': '01-01-2024',
        'description': 'Stage de 6 mois en marketing digital au sein d\'une agence dynamique. Vous participerez à la gestion des campagnes publicitaires et au développement de stratégies marketing innovantes.',
        'competence': 'Marketing Digital, Réseaux sociaux, Analytics',
        'date_debut': '2025-01-15 09:00:00.000000',
        'date_fin': '2025-07-15 18:00:00.000000',
        'lien_postuler': 'https://www.youtube.com/watch?v=e9J6sI5YBOo&list=RDHGBek8t3x5I&index=5',
        'logo': 'https://via.placeholder.com/150',
      },
      {
        'titre': 'Offres Menuiserie',
        'type_contrat': 'CDD',
        'entreprise': 'FMP',
        'lieu': 'Bamako, Mali',
        'datePublication': '01-01-2024',
        'description': 'Permettre aux jeunes de voir toutes les offres liées à la menuiserie et de postuler directement via le lien du site de l\'entreprise.',
        'competence': 'Menuiserie, Travail du bois, Assemblage',
        'date_debut': '2025-02-01 09:00:00.000000',
        'date_fin': '2025-08-01 18:00:00.000000',
        'lien_postuler': 'https://www.youtube.com/watch?v=e9J6sI5YBOo&list=RDHGBek8t3x5I&index=5',
        'logo': 'https://via.placeholder.com/150',
      }
    ];

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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                itemCount: offres.length,
                itemBuilder: (context, index) {
                  return OffreCard(offre: offres[index]);
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
              title: 'Offres d\'emploi',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

class OffreCard extends StatelessWidget {
  final Map<String, dynamic> offre;
  const OffreCard({Key? key, required this.offre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(offre['logo']),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offre['entreprise'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(offre['lieu'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(offre['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text(offre['description'], style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.date_range, 'Du ${_formatDate(offre['date_debut'])} au ${_formatDate(offre['date_fin'])}'),
            _buildInfoRow(Icons.work_outline, offre['type_contrat']),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailOffreCommunePage(offre: offre),
                    ),
                  );
                },
                child: const Text('Voir détails'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  String? _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      // Parse la date au format "2025-12-01 21:00:00.000000"
      final DateTime date = DateTime.parse(dateString);
      // Formate en français
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString; // Retourne la chaîne originale si le parsing échoue
    }
  }
}
