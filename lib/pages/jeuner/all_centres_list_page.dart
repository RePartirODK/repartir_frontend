import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/centre_detail_page.dart';

class AllCentresListPage extends StatelessWidget {
  const AllCentresListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for all centres
    final centres = [
      {
        'logo': 'https://placehold.co/150/EFEFEF/333333?text=ODC',
        'name': 'ODC_MALI',
        'location': 'Bamako, Mali',
        'description': 'L\'Orange Digital Center (ODC) est un écosystème entièrement dédié au développement des compétences numériques et à l\'innovation.',
      },
      {
        'logo': 'https://placehold.co/150/EFEFEF/333333?text=KA',
        'name': 'Kabako_Academies',
        'location': 'Bamako, Mali',
        'description': 'Kabakoo Academies est une initiative panafricaine qui vise à réinventer l\'éducation et la formation professionnelle en Afrique.',
      },
      {
        'logo': 'https://placehold.co/150/EFEFEF/333333?text=DB',
        'name': 'DigitalBoost',
        'location': 'Ségou, Mali',
        'description': 'DigitalBoost est un centre de formation spécialisé dans le marketing digital et la gestion des réseaux sociaux.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 160,
            color: Colors.blue,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: BackButton(color: Colors.white),
            ),
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
                      'Tous les centres',
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
                        itemCount: centres.length,
                        itemBuilder: (context, index) {
                          final centre = centres[index];
                          return CentreListItemCard(centre: centre);
                        },
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
}

class CentreListItemCard extends StatelessWidget {
  final Map<String, dynamic> centre;

  const CentreListItemCard({Key? key, required this.centre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text(centre['description']),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CentreDetailPage()),
                  );
                },
                child: const Text('Voir le centre'),
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
    );
  }
}
