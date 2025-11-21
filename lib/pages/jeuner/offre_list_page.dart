import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/detail_offre_commune_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/offers_service.dart';

class OffreListPage extends StatefulWidget {
  const OffreListPage({super.key});

  @override
  State<OffreListPage> createState() => _OffreListPageState();
}

class _OffreListPageState extends State<OffreListPage> {
  final OffersService _offersService = OffersService();
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
      final list = await _offersService.search();
      _items = list.map((m) {
        return <String, dynamic>{
          'id': m['id'],
          'titre': m['titre'] ?? '',
          'type_contrat': m['type_contrat']?.toString() ?? '',
          'entreprise': m['nomEntreprise'] ?? '',
          'lieu': m['adresseEntreprise']?.toString() ?? '',
          'datePublication': '',
          'description': m['description'] ?? '',
          'lien_postuler': m['lienPostuler'] ?? '',
          'logo': 'https://via.placeholder.com/150',
          'date_debut': m['dateDebut']?.toString(),
          'date_fin': m['dateFin']?.toString(),
          'competence': m['competence']?.toString() ?? '',
        };
      }).toList();
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
          //------------LISTE DES OFFRES-------------------------
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
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          24.0,
                          16.0,
                          16.0,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return OffreCard(offre: _items[index]);
                        },
                      ),
                    ),
            ),
          ),
          //------------HEADER---------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Offres d\'emploi',
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}

class OffreCard extends StatelessWidget {
  final Map<String, dynamic> offre;
  const OffreCard({super.key, required this.offre});

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
                    Text(
                      offre['entreprise'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          offre['lieu'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              offre['titre'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              offre['description'],
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.date_range,
              'Du ${_formatDate(offre['date_debut'])} au ${_formatDate(offre['date_fin'])}',
            ),
            _buildInfoRow(Icons.work_outline, offre['type_contrat']),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailOffreCommunePage(offre: offre),
                    ),
                  );
                },
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                ),
                child: const Text('Voir détails'),
              ),
            ),
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
            child: Text(text, style: TextStyle(color: Colors.grey[700])),
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
