import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/formation_detail_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/centres_service.dart';

class CentreDetailPage extends StatefulWidget {
  const CentreDetailPage({super.key, required this.centreId});
  final int centreId;

  @override
  State<CentreDetailPage> createState() => _CentreDetailPageState();
}

class _CentreDetailPageState extends State<CentreDetailPage> {
  final CentresService _centres = CentresService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _centre;
  List<Map<String, dynamic>> _formations = [];

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
      _centre = await _centres.getById(widget.centreId);
      try {
        _formations = await _centres.getFormationsByCentre(widget.centreId);
      } catch (e) {
        // Pas de formations, on continue quand même
        _formations = [];
      }
      // Pas d'erreur si pas de formations, on affiche juste les infos du centre
      //Filter pour enlever les formations annuler
      _formations = _formations.where((f) => f['statut'] != 'ANNULER').toList();
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
    final u = _centre?['utilisateur'] ?? {};
    final centerData = {
      'logo': (u['urlPhoto'] ?? 'https://via.placeholder.com/150').toString(),
      'name': (u['nom'] ?? '—').toString(),
      'location': (_centre?['adresse'] ?? '—').toString(),
      'phone': (u['telephone'] ?? '—').toString(),
      'email': (u['email'] ?? '—').toString(),
      'website': '',
      'a_propos': (u['description'] ?? _centre?['description'] ?? '').toString(), // À propos du centre
    };

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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : Column(
                          children: [
                            _buildHeader(context, centerData),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _fetch,
                                child: _formations.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'Ce centre n\'a pas encore publié de formation.',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  itemCount: _formations.length,
                                  itemBuilder: (context, index) {
                                    final f = _formations[index];
                                    final centreInfo = f['centreFormation'] ?? {};
                                    final centreUtil = centreInfo['utilisateur'] ?? {};
                                    final dateDebut = f['date_debut']?.toString() ?? '';
                                    final dateFin = f['date_fin']?.toString() ?? '';
                                    final formation = {
                                      'title': (f['titre'] ?? '').toString(),
                                      'description': (f['description'] ?? '').toString(),
                                      'date': _formatDates(dateDebut, dateFin),
                                      'link': (f['urlFormation'] ?? '').toString(),
                                      'places': (f['nbrePlace'] ?? '—').toString(),
                                      'financing': '',
                                      'id': f['id'],
                                      'cout': f['cout'],
                                      'format': f['format'],
                                      'duree': f['duree'],
                                      'statut': (f['statut'] ?? '').toString(),
                                      'centreName': (centreUtil['nom'] ?? '').toString(),
                                      'centreLocation': (centreInfo['adresse'] ?? '').toString(),
                                    };
                                    return FormationCard(formation: formation);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Détail Centre',
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDates(String dateDebut, String dateFin) {
    if (dateDebut.isEmpty && dateFin.isEmpty) return '—';
    if (dateDebut.isEmpty) return 'Jusqu\'au $dateFin';
    if (dateFin.isEmpty) return 'À partir du $dateDebut';
    return 'Du $dateDebut au $dateFin';
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
          if (centerData['website']!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(centerData['website']!, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          ],
          // Section "À propos du centre"
          if (centerData['a_propos']!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'À propos du centre',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    centerData['a_propos']!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FormationCard extends StatelessWidget {
  final Map<String, dynamic> formation;
  const FormationCard({super.key, required this.formation});

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
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formation['centreName']?.toString() ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(formation['centreLocation']?.toString() ?? '—', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(formation['title']?.toString() ?? '—', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 5),
            Text(formation['description']?.toString() ?? '—'),
            const SizedBox(height: 10),      
            if (formation['cout'] != null)
              _buildInfoRow(Icons.attach_money, 'Coût: ${formation['cout']}'),
            if (formation['duree'] != null)
              _buildInfoRow(Icons.access_time, 'Durée: ${formation['duree']}'),
            if ((formation['financing']?.toString() ?? '').isNotEmpty)
              _buildInfoRow(Icons.help_outline, formation['financing']?.toString() ?? '—'),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormationDetailPage(formationId: formation['id']),
                      ),
                    );
                  },
                  child: const Text('Voir détails'),
                ),
                const SizedBox(width: 10),
                 if ((formation['statut']?.toString() ?? '') == 'EN_ATTENTE')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormationDetailPage(formationId: formation['id']),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("S'inscrire"),
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
