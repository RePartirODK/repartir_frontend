import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/response/response_parrain.dart';
import 'package:repartir_frontend/pages/parrains/jeunesparraines.dart';
import 'package:repartir_frontend/services/parrain_service.dart';
import 'package:repartir_frontend/services/parrainages_service.dart';
// Importez le composant de barre de navigation si dans un fichier séparé
// import 'custom_bottom_nav_bar.dart';

// Définition des couleurs
const Color primaryBlue = Color(0xFF2196F3);
const Color primaryGreen = Color(0xFF4CAF50);

class ParrainHomePage extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const ParrainHomePage({super.key, required this.onNavigate});

  @override
  State<ParrainHomePage> createState() => _ParrainHomePageState();
}

class _ParrainHomePageState extends State<ParrainHomePage> {
  // État pour la barre de navigation inférieure
  
  final ParrainService _parrainService = ParrainService();
  final ParrainagesService _parrainagesService = ParrainagesService();

  ResponseParrain? _parrain;
  bool _loading = true;
  String? _error;

  int _pendingDemands = 0;
  int _jeunesParraines = 0; // TODO: requires backend endpoint filtered by parrain
  String _donationsTotalLabel = '—'; // TODO: requires backend endpoint per parrain

  @override
  void initState() {
    super.initState();
    _loadData();
  }
 Future<void> _loadData() async {
    try {
      final p = await _parrainService.getCurrentParrain();
      // Load pending parrainage demands for current parrain
      int pending = 0;
      try {
        final demandes = await _parrainagesService.demandesEnAttente();
        pending = demandes.length;
      } catch (_) {
        // ignore if endpoint is role-protected or user not PARRAIN yet
      }

      // Load accepted parrainages count for current parrain
      int acceptedCount = 0;
      try {
        final accepted = await _parrainagesService.listerAcceptesPourMoi();
        acceptedCount = accepted.length;
      } catch (_) {
        // keep default if unauthorized or not a parrain yet
      }

      // Load donations total for current parrain
      String donationsLabel = '—';
      try {
        final total = await _parrainService.getTotalDonationsForMe();
        // format simply as integer or keep one decimal if needed
        donationsLabel = total.toStringAsFixed(0);
      } catch (_) {
        // keep default on error
      }

      setState(() {
        _parrain = p;
        _pendingDemands = pending;
        _jeunesParraines = acceptedCount;
        _donationsTotalLabel = donationsLabel;
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
      // Le corps de la page avec SingleChildScrollView pour le défilement
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Stack(
                        children: [
                          // --- Zone de Tête (Header) ---
                          CustomHeader(
                            title: 'Accueil',
                          ),
                          // --- 2. Logo (Positionné en haut à gauche) ---
                          Positioned(
                            height: 80,
                            width: 80,
                            top: 30,
                            left: 20,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                'assets/images/logo_repartir.png',
                                height: 300,
                                width: 300,
                              ),
                            ),
                          ),
                          // Padding pour le reste du contenu
                        ],
                      ),
                      
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Bienvenu parrain',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildProfileSection(),
                            const SizedBox(height: 40),
                            _buildStatsCards(),
                            const SizedBox(height: 40),
                            const Text(
                              'Actions',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildActionButton(
                              text: 'Donations',
                              color: primaryBlue.withValues(alpha: 0.2),
                              textColor: Colors.black,
                              onPressed: () {
                                widget.onNavigate(1);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildActionButton(
                              text: 'Jeunes déjà parrainés',
                              color: primaryBlue.withValues(alpha: 0.2),
                              textColor: Colors.black,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SponsoredYouthPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  /// -------------------------------------------
  /// WIDGETS DE COMPOSANTS DÉTAILLÉS
  /// -------------------------------------------

  
   /// Construit la section du profil (image, nom, statut).
  Widget _buildProfileSection() {
    final name = _parrain != null ? '${_parrain!.prenom} ${_parrain!.nom}' : '—';
    final sinceLabel = _parrain?.dateInscription != null
        ? 'Parrain depuis ${_parrain!.dateInscription!.year}'
        : 'Parrain';
    
    // Récupérer l'URL de la photo avec gestion améliorée
    String? photoUrl;
    if (_parrain?.urlPhoto != null && (_parrain!.urlPhoto ?? '').toString().trim().isNotEmpty) {
      photoUrl = (_parrain!.urlPhoto ?? '').toString().trim();
    } else if (_parrain?.utilisateur.urlPhoto != null && (_parrain!.utilisateur.urlPhoto ?? '').toString().trim().isNotEmpty) {
      photoUrl = (_parrain!.utilisateur.urlPhoto ?? '').toString().trim();
    }
    
    // Debug: Vérifier l'URL de la photo
    debugPrint('📸 Parrain accueil - Photo URL: $photoUrl');
    if (_parrain != null) {
      debugPrint('📸 Parrain accueil - urlPhoto: ${_parrain!.urlPhoto}');
      debugPrint('📸 Parrain accueil - utilisateur.urlPhoto: ${_parrain!.utilisateur.urlPhoto}');
    }
    
    return Center(
      child: Column(
        children: <Widget>[
          ProfileAvatar(
            photoUrl: photoUrl,
            radius: 50,
            isPerson: true,
            backgroundColor: primaryBlue,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            sinceLabel,
            style: const TextStyle(
              fontSize: 14,
              color: primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
   /// Construit les cartes de statistiques (Responsif avec Flexible).
  Widget _buildStatsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: _buildStatCard(title: 'Jeune parrainés', value: '$_jeunesParraines'),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: _buildStatCard(
            title: 'Donations totales',
            value: _donationsTotalLabel,
          ),
        ),
      ],
    );
  }
  /// Widget pour une carte de statistique individuelle.
  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour les boutons d'action.
  Widget _buildActionButton({
    required String text,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width *
          0.9, //90% de la largeur de l’écran
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
