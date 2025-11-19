import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/centre_detail_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/centres_service.dart';

class AllCentresListPage extends StatefulWidget {
  const AllCentresListPage({super.key});

  @override
  State<AllCentresListPage> createState() => _AllCentresListPageState();
}

class _AllCentresListPageState extends State<AllCentresListPage> {
  final CentresService _centres = CentresService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _centres.listAll();
      // Filtrer les centres actifs
      final centresActifs = all.where((c) {
        final u = c['utilisateur'] ?? {};
        return u['estActive'] == true;
      }).toList();
      
      // Filtrer pour ne garder QUE les centres qui ont publié au moins une formation
      final List<Map<String, dynamic>> centresAvecFormations = [];
      for (final centre in centresActifs) {
        try {
          final formations = await _centres.getFormationsByCentre(centre['id']);
          // Vérifier que le centre a des formations ET qu'elles appartiennent bien à ce centre
          if (formations.isNotEmpty) {
            // Vérifier que la première formation appartient bien à ce centre
            final premiereFormation = formations.first;
            final centreFormationId = premiereFormation['centreFormation']?['id'] ?? 
                                     premiereFormation['centre']?['id'];
            if (centreFormationId == centre['id'] || centreFormationId == null) {
              centresAvecFormations.add(centre);
            }
          }
        } catch (e) {
          // Pas de formation pour ce centre, on ne l'ajoute pas
        }
      }
      
      _items = centresAvecFormations;
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //-----------------------CONTENU PRINCIPAL--------------------------
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final c = _items[index];
                              final u = c['utilisateur'] ?? {};
                              final centre = {
                                'logo': (u['urlPhoto'] ?? 'https://via.placeholder.com/150').toString(),
                                'name': (u['nom'] ?? '—').toString(),
                                'location': (c['adresse'] ?? '—').toString(),
                                'description': (u['description'] ?? '').toString(), // À propos du centre, pas l'agrément
                                'id': c['id'],
                              };
                              return CentreListItemCard(centre: centre);
                            },
                          ),
                        ),
            ),
          ),
          //-----------------------HEADER-------------------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Tous les centres',
              height: 150,
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
            if ((centre['description'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Text(centre['description']),
            ],
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CentreDetailPage(centreId: centre['id']),
                    ),
                  );
                },
                child: const Text('Voir le centre'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3EB2FF),
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
