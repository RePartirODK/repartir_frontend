import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/detail_offre_commune_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/offre_service.dart';
import 'package:repartir_frontend/models/offre_emploi.dart';

class OffreListPage extends StatefulWidget {
  const OffreListPage({Key? key}) : super(key: key);

  @override
  State<OffreListPage> createState() => _OffreListPageState();
}

class _OffreListPageState extends State<OffreListPage> {
  final OffreService _offreService = OffreService();
  List<OffreEmploi> _offres = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOffres();
  }

  Future<void> _loadOffres() async {
    try {
      final offres = await _offreService.listerOffres();
      setState(() {
        _offres = offres;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $_errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_errorMessage ?? 'Erreur inconnue'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadOffres,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _offres.isEmpty
                          ? const Center(child: Text('Aucune offre disponible'))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                              itemCount: _offres.length,
                              itemBuilder: (context, index) {
                                return OffreCard(offre: _offres[index]);
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
  final OffreEmploi offre;
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
            if (offre.nomEntreprise != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.business, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offre.nomEntreprise!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            if (offre.nomEntreprise != null) const SizedBox(height: 12),
            Text(offre.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text(offre.description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            if (offre.dateDebut != null && offre.dateFin != null)
              _buildInfoRow(Icons.date_range, 'Du ${_formatDate(offre.dateDebut!)} au ${_formatDate(offre.dateFin!)}'),
            if (offre.typeContrat != null)
              _buildInfoRow(Icons.work_outline, offre.typeContrat!),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page de détail avec l'ID de l'offre
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailOffreCommunePage(
                        offreId: offre.id,
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
