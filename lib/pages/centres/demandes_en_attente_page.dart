// NEW_FILE_CODE
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/response/response_inscription.dart';
import 'package:repartir_frontend/pages/centres/voirappliquant.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/jeune_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

const Color kPrimaryColor = Color(0xFF3EB2FF);

class DemandesEnAttentePage extends StatefulWidget {
  const DemandesEnAttentePage({super.key});

  @override
  State<DemandesEnAttentePage> createState() => _DemandesEnAttentePageState();
}

class _DemandesEnAttentePageState extends State<DemandesEnAttentePage> {
  final CentreService _centreService = CentreService();
  final JeuneService _jeuneService = JeuneService();
  final SecureStorageService _storage = SecureStorageService();

  bool _loading = true;
  String? _error;
  List<ResponseInscription> _all = [];
  List<ResponseInscription> _pending = [];
  final Map<String, String?> _photoUrlByJeuneName = {}; // Cache pour les photos

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
      final centreId = int.tryParse(await _storage.getUserId() ?? '0') ?? 0;
      if (centreId == 0) throw Exception('Centre introuvable');
      
      // Charger les inscriptions et les jeunes en parallèle
      final items = await _centreService.getCentreInscriptions(centreId);
      
      // Charger les jeunes pour obtenir les photos
      try {
        final jeunes = await _jeuneService.listAll();
        for (final j in jeunes) {
          final utilisateur = j['utilisateur'] as Map<String, dynamic>? ?? {};
          final prenom = (j['prenom'] ?? '').toString();
          final nom = (utilisateur['nom'] ?? '').toString();
          final fullName = (prenom.isNotEmpty || nom.isNotEmpty) ? '$prenom $nom'.trim() : '';
          if (fullName.isNotEmpty) {
            final urlPhoto = (utilisateur['urlPhoto'] ?? '').toString();
            _photoUrlByJeuneName[fullName] = urlPhoto.isNotEmpty ? urlPhoto : null;
          }
        }
      } catch (e) {
        debugPrint('Failed to load jeunes for photos: $e');
      }

      // Only inscriptions in EN_ATTENTE AND formation not ANNULER
      final pending = items.where((e) {
        final isPending = (e.status.toUpperCase() == 'EN_ATTENTE');
        final notCancelled = ((e.formationStatut ?? '').toUpperCase() != 'ANNULER');
        return isPending && notCancelled;
      }).toList();
      setState(() {
        _all = items;
        _pending = pending;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : _error != null
              ? Center(child: Text('Erreur: ${_error!}'))
              : Column(
                  children: [
                    CustomHeader(title: "Demandes en attente", showBackButton: true),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetch,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          children: [
                            _buildCounter(),
                            const SizedBox(height: 12),
                            if (_pending.isEmpty)
                              const Text("Aucune inscription en attente", style: TextStyle(color: Colors.black54))
                            else
                              ..._pending.map(_buildInscriptionCard),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCounter() {
    return Row(
      children: [
        const Icon(Icons.hourglass_top, color: kPrimaryColor),
        const SizedBox(width: 8),
        Text(
          "${_pending.length} en attente",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
      ],
    );
  }

  Widget _buildInscriptionCard(ResponseInscription insc) {
    // Utiliser urlPhotoJeune de l'inscription, sinon chercher dans le cache
    final photoUrl = insc.urlPhotoJeune ?? _photoUrlByJeuneName[insc.nomJeune];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            ProfileAvatar(
              photoUrl: photoUrl,
              radius: 24,
              isPerson: true,
              backgroundColor: Colors.grey[200]!,
              iconColor: kPrimaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insc.nomJeune, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(insc.titreFormation, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplicantProfilePage(inscription: insc),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Voir'),
            ),
          ],
        ),
      ),
    );
  }
}