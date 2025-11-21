import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/centre_detail_page.dart';
import 'package:repartir_frontend/pages/jeuner/formation_detail_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/api_service.dart';

class CentreListPage extends StatefulWidget {
  const CentreListPage({super.key});

  @override
  State<CentreListPage> createState() => _CentreListPageState();
}

class _CentreListPageState extends State<CentreListPage> {
  final CentresService _centres = CentresService();
  final ApiService _api = ApiService();
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
      // Vérifier si l'utilisateur est connecté
      final isConnected = await _api.hasToken();
      if (!isConnected) {
        throw Exception(
          'Vous devez être connecté pour voir les centres de formation. Veuillez vous connecter.',
        );
      }

      final all = await _centres.listAll();
      // Filtrer les centres actifs
      final centresActifs = all.where((c) {
        final u = c['utilisateur'] ?? {};
        return u['estActive'] == true;
      }).toList();

      // Récupérer TOUTES les formations de TOUS les centres actifs
      final List<Map<String, dynamic>> toutesFormations = [];
      for (final centre in centresActifs) {
        try {
          final formations = await _centres.getFormationsByCentre(centre['id']);
          // Exclude canceled formations (statut or status == ANNULER)
          final activeFormations = formations.where((f) {
            final raw = f['statut'] ?? f['status'];
            final s = (raw ?? '').toString().toUpperCase();
            return s != 'ANNULER';
          }).toList();
          // Pour chaque formation, ajouter les infos du centre
          for (final formation in activeFormations) {
            // Vérifier que la formation appartient bien à ce centre
            final centreFormationId =
                formation['centreFormation']?['id'] ??
                formation['centre']?['id'];
            if (centreFormationId == centre['id'] ||
                centreFormationId == null) {
              // Ajouter les infos du centre à la formation
              formation['centreInfo'] = {
                'id': centre['id'],
                'nom': centre['utilisateur']?['nom'] ?? '',
                'logo': centre['utilisateur']?['urlPhoto'] ?? '',
                'adresse': centre['adresse'] ?? '',
              };
              toutesFormations.add(formation);
            }
          }
        } catch (e) {
          // Ignorer les erreurs pour ce centre et continuer
        }
      }

      _items = toutesFormations;
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!))
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final f =
                                _items[index]; // f est maintenant une formation
                            final centreInfo = f['centreInfo'] ?? {};
                            final dateDebut = _formatDate(f['date_debut']);
                            final dateFin = _formatDate(f['date_fin']);
                            final card = {
                              'logo':
                                  (centreInfo['logo'] ??
                                          'https://via.placeholder.com/150')
                                      .toString(),
                              'name': (centreInfo['nom'] ?? 'Centre')
                                  .toString(),
                              'location': (centreInfo['adresse'] ?? '—')
                                  .toString(),
                              'formation': (f['titre'] ?? '').toString(),
                              'description': (f['description'] ?? '')
                                  .toString(),
                              'date':
                                  (dateDebut.isNotEmpty || dateFin.isNotEmpty)
                                  ? 'Du $dateDebut - au $dateFin'
                                  : '',
                              'link': (f['urlFormation'] ?? '').toString(),
                              'places': (f['nbrePlace'] ?? '').toString(),
                              'price': (f['cout'] != null)
                                  ? 'Scolarité : ${f['cout']}'
                                  : null,
                              'id': centreInfo['id'],
                              'formationId': f['id'], // ID de la formation
                            };
                            return CentreCard(centre: card);
                          },
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(title: 'Centres de formation', height: 150),
          ),
        ],
      ),
    );
  }
}

String _formatDate(dynamic raw) {
  if (raw == null) return '';
  try {
    final dt = raw is DateTime ? raw : DateTime.parse(raw.toString());
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd/$mm/$yyyy';
  } catch (_) {
    return raw.toString();
  }
}

class CentreCard extends StatelessWidget {
  final Map<String, dynamic> centre;

  const CentreCard({super.key, required this.centre});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CentreDetailPage(centreId: centre['id']),
          ),
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
                      Text(
                        centre['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.black, size: 16),
                          const SizedBox(width: 4),
                          Text(centre['location'], style: const TextStyle(color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              if (centre['formation']?.toString().isNotEmpty ?? false) ...[
                Text(
                  centre['formation'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              if (centre['description']?.toString().isNotEmpty ?? false) ...[
                Text(centre['description']),
                const SizedBox(height: 10),
              ],
              if (centre['date']?.toString().isNotEmpty ?? false)
                _buildInfoRow(Icons.date_range, _formatDate(centre['date'])),
              if (centre['link']?.toString().isNotEmpty ?? false)
                _buildInfoRow(Icons.link, centre['link']),
              if (centre['places']?.toString().isNotEmpty ?? false)
                _buildInfoRow(
                  Icons.group,
                  '${centre['places']} places disponibles',
                ),
              if (centre.containsKey('price') && centre['price'] != null)
                _buildInfoRow(Icons.attach_money, centre['price']),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Sur l'onglet Formations, toujours rediriger vers le détail de la formation
                    final formationId = centre['formationId'];
                    if (formationId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FormationDetailPage(formationId: formationId),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3EB2FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Voir détails'),
                ),
              ),
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
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
