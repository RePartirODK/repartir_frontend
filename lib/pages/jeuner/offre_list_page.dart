import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/offre_detail_page.dart';

class OffreListPage extends StatelessWidget {
  const OffreListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for job offers
    final offres = [
      {
        'logo': 'https://via.placeholder.com/150',
        'company': 'DigitalBoost',
        'location': 'Bamako, Mali',
        'title': 'Stage Marketing Digital',
        'description': 'Stage de 6 mois en marketing digital au sein d\'une agence dynamique. Vous participerez à la gestion des campagnes publicitaires et à...',
        'date': 'Du 15 Sept 2023 au 15 Mars 2024',
        'link': 'lien www.formation-dev.com/web',
      },
      {
        'logo': 'https://via.placeholder.com/150',
        'company': 'FMP',
        'location': 'Bamako, Mali',
        'title': 'Offres Menuiserie',
        'description': 'Permettre aux jeunes de voir toutes les offres liées à la menuiserie et de postuler directement via le lien du site de l\'entreprise.',
        'date': 'Du 15 Sept 2023 au 15 Mars 2024',
        'link': 'En ligne www.formation-dev.com/web',
      }
    ];

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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 30.0, bottom: 20.0, left: 16.0),
                    child: Text(
                      'Offres',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: offres.length,
                      itemBuilder: (context, index) {
                        return OffreCard(offre: offres[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
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
                    Text(offre['company'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(offre['location'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(offre['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text(offre['description'], style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.date_range, offre['date']),
            _buildInfoRow(Icons.link, offre['link']),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OffreDetailPage()),
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
    final defaultStyle = TextStyle(color: Colors.grey[700]);
    final linkStyle = const TextStyle(
        color: Colors.blue, decoration: TextDecoration.underline);

    Widget textWidget;

    if (icon == Icons.link) {
      int splitIndex = text.indexOf(' ');
      if (splitIndex != -1) {
        String prefix = text.substring(0, splitIndex + 1);
        String link = text.substring(splitIndex + 1);
        textWidget = RichText(
          text: TextSpan(
            style: defaultStyle,
            children: <TextSpan>[
              TextSpan(text: prefix),
              TextSpan(text: link, style: linkStyle),
            ],
          ),
        );
      } else {
        // Fallback in case there's no space
        textWidget = Text(text, style: linkStyle);
      }
    } else {
      textWidget = Text(text, style: defaultStyle);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(width: 8),
          Expanded(child: textWidget),
        ],
      ),
    );
  }
}
