import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/formation_detail_page.dart';

class CentreDetailPage extends StatelessWidget {
  const CentreDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for the center and its formations
    final centerData = {
      'logo': 'https://via.placeholder.com/150',
      'name': 'ODC_MALI',
      'location': 'Bamako, Mali',
      'phone': '01 23 45 67 89',
      'email': 'contact@digitalcampus.fr',
      'website': 'www.orangedigitalcenter.tech'
    };
    final formations = List.generate(3, (index) => {
      'title': 'Formation Développeur Web',
      'description': 'Apprenez les bases du développement web avec HTML, CSS et JavaScript',
      'date': 'Du 15 Sept 2023 - au 15 Mars 2024',
      'link': 'En ligne www.formation-dev.com/web',
      'places': '5 places disponibles',
      'financing': 'Besoin de financement : Oui'
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 180,
            color: Colors.blue,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
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
              child: Column(
                children: [
                  _buildHeader(context, centerData),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: formations.length,
                      itemBuilder: (context, index) {
                        return FormationCard(formation: formations[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, String> centerData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(centerData['logo']!),
          ),
          const SizedBox(height: 10),
          Text(centerData['name']!, style: const TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(centerData['location']!, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, color: Colors.black54, size: 16),
              const SizedBox(width: 8),
              Text(centerData['phone']!, style: const TextStyle(color: Colors.black54)),
              const SizedBox(width: 20),
              const Icon(Icons.email, color: Colors.black54, size: 16),
              const SizedBox(width: 8),
              Text(centerData['email']!, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Text(centerData['website']!, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
        ],
      ),
    );
  }
}

class FormationCard extends StatelessWidget {
  final Map<String, String> formation;
  const FormationCard({Key? key, required this.formation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  // You might want a different logo for each formation or use the center's logo
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ODC_MALI", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Bamako, Mali", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(formation['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 5),
            Text(formation['description']!),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.date_range, formation['date']!),
            _buildInfoRow(Icons.link, formation['link']!),
            _buildInfoRow(Icons.group, formation['places']!),
            _buildInfoRow(Icons.help_outline, formation['financing']!),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FormationDetailPage()),
                    );
                  },
                  child: const Text('Voir détails'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("S'inscrire"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
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
          Expanded(child: Text(text, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}
