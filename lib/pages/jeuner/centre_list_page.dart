import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/centre_detail_page.dart';
import 'package:repartir_frontend/pages/jeuner/formation_detail_page.dart';

class CentreListPage extends StatelessWidget {
  const CentreListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 160,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
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
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Formations',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: 2, // Number of centres
                        itemBuilder: (context, index) {
                          // Replace with your data model
                          final centres = [
                            {
                              'logo': 'https://via.placeholder.com/150',
                              'name': 'ODC_MALI',
                              'location': 'Bamako, Mali',
                              'formation': 'Formation Développeur Web',
                              'description': 'Apprenez les bases du développement web avec HTML, CSS et JavaScript',
                              'date': 'Du 15 Sept 2023 - au 15 Mars 2024',
                              'link': 'En ligne www.formation-dev.com/web',
                              'places': '5 places disponibles',
                              'price': 'Scolarité : 1.100.000cfa',
                            },
                            {
                              'logo': 'https://via.placeholder.com/150',
                              'name': 'Kabako_Academies',
                              'location': 'Bamako, Mali',
                              'formation': 'Web Design',
                              'description': '6 mois de formation globale en webdesign, marketing digital, conception d\'applications, et entrepreneuriat IA travers Kabakoo',
                              'date': 'Du 15 Sept 2023 - au 15 Mars 2024',
                              'link': 'En ligne www.formation-dev.com/web',
                              'places': '3 places disponibles',
                            },
                          ];
                          final centre = centres[index];
                          return CentreCard(centre: centre);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CentreCard extends StatelessWidget {
  final Map<String, dynamic> centre;

  const CentreCard({Key? key, required this.centre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CentreDetailPage()),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(centre['logo']),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(centre['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(centre['location'], style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Text(centre['formation'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 5),
              Text(centre['description']),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.date_range, centre['date']),
              _buildInfoRow(Icons.link, centre['link']),
              _buildInfoRow(Icons.group, centre['places']),
              if (centre.containsKey('price'))
                _buildInfoRow(Icons.attach_money, centre['price']),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FormationDetailPage()),
                    );
                  },
                  child: const Text('Voir détails'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              )
            ],
          ),
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
