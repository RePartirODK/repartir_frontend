import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/services/formations_service.dart';
import 'package:repartir_frontend/services/inscriptions_service.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/parrainages_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/api_service.dart';
import 'package:repartir_frontend/services/paiement_service.dart';
import 'package:repartir_frontend/pages/jeuner/paiement_page.dart';

class FormationDetailPage extends StatefulWidget {
  const FormationDetailPage({super.key, this.formationId});
  final int? formationId;

  @override
  State<FormationDetailPage> createState() => _FormationDetailPageState();
}

class _FormationDetailPageState extends State<FormationDetailPage> {
  final FormationsService _formations = FormationsService();
  final InscriptionsService _inscriptions = InscriptionsService();
  final ParrainagesService _parrainages = ParrainagesService();
  final ProfileService _profile = ProfileService();
  final ApiService _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _formation;

  @override
  void initState() {
    super.initState();
    if (widget.formationId != null) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
    });
    try {
      // Vérifier si l'utilisateur est connecté
      final isConnected = await _api.hasToken();
      if (!isConnected) {
        throw Exception(
          'Vous devez être connecté pour voir les détails de la formation. Veuillez vous connecter.',
        );
      }

      _formation = await _formations.details(widget.formationId!);

      // If canceled, do not display the page
      if (_formation != null &&
          (_formation!['statut']?.toString().toUpperCase() == 'ANNULER')) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cette formation a été annulée.')),
          );
        }
        return;
      }

      // Si la formation a un idCentre, récupérer les détails du centre
      if (_formation != null && _formation!['idCentre'] != null) {
        try {
          final centreId = _formation!['idCentre'];
          final centreDetails = await CentresService().getById(centreId);

          // Ajouter les détails du centre à la formation
          _formation!['centre'] = centreDetails;
          debugPrint('Centre récupéré avec succès: ${centreDetails['nom']}');
        } catch (e) {
          debugPrint('Erreur lors de la récupération du centre: $e');
        }
      }
    } catch (e) {
      // Éviter d'afficher le token JWT dans l'erreur
      String errorMsg = '$e';
      if (errorMsg.contains('JWT') || errorMsg.contains('eyJ')) {
        errorMsg = 'Erreur d\'authentification. Veuillez vous reconnecter.';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mapper les données réelles de la formation
    final f = _formation ?? {};
    final centreInfo = f['centre'] ?? f['centreFormation'] ?? {};
    final centreUtil = centreInfo['utilisateur'] ?? {};
    final dateDebut = _formatDate(f['date_debut']);
    final dateFin = _formatDate(f['date_fin']);
    final statut = (f['statut'] ?? '').toString();
    // Récupérer le nom du centre (essayer plusieurs chemins)
    String centerName = '';
    if (centreUtil['nom'] != null &&
        centreUtil['nom'].toString().trim().isNotEmpty) {
      centerName = centreUtil['nom'].toString().trim();
    } else if (centreInfo['nom'] != null &&
        centreInfo['nom'].toString().trim().isNotEmpty) {
      centerName = centreInfo['nom'].toString().trim();
    }

    // Récupérer l'email du centre (essayer plusieurs chemins)
    String centerEmail = '';
    if (centreUtil['email'] != null &&
        centreUtil['email'].toString().trim().isNotEmpty) {
      centerEmail = centreUtil['email'].toString().trim();
    } else if (centreInfo['email'] != null &&
        centreInfo['email'].toString().trim().isNotEmpty) {
      centerEmail = centreInfo['email'].toString().trim();
    }

    final formationDetails = {
      'title': (f['titre'] ?? '—').toString(),
      'center_name': centerName.isNotEmpty ? centerName : '—',
      'center_email': centerEmail.isNotEmpty ? centerEmail : '—',
      'description_title': 'Description',
      'description_body': (f['description'] ?? '—').toString(),
      'dates_title': 'Dates',
      'dates_body': (dateDebut.isNotEmpty || dateFin.isNotEmpty)
          ? 'Du $dateDebut au $dateFin'
          : '—',
      'places': (f['nbrePlace'] ?? '—').toString(),
      'sourcing': '—',
      'type': (f['format'] ?? '—').toString(),
      'cout': f['cout'],
      'duree': f['duree'],
      'urlFormation': f['urlFormation'],
    };

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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(formationDetails),
                      const SizedBox(height: 30),
                      _buildSection(
                        formationDetails['description_title']!,
                        formationDetails['description_body']!,
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        formationDetails['dates_title']!,
                        formationDetails['dates_body']!,
                        icon: Icons.date_range,
                      ),
                      const SizedBox(height: 20),
                      _buildInfoBox(formationDetails),
                      const SizedBox(height: 30),

                      if (statut == 'EN_ATTENTE')
                        Center(
                          child: ElevatedButton(
                            onPressed: _loading || widget.formationId == null
                                ? null
                                : () {
                                    // Vérifier d'abord si l'utilisateur a déjà une inscription
                                    _verifierEtInscrire();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3EB2FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("S'inscrire"),
                          ),
                        ),
                    ],
                  ),
                ),
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
              title: 'Détail Formation',
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  void _showInscriptionChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close this dialog
                    _showConditionsDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Demander à être parrainé'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close this dialog
                    // Naviguer vers la page de paiement
                    _naviguerVersPaiement();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3EB2FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Payer ma formation'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConditionsDialog(BuildContext context) {
    bool accepted = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                'Conditions de parrainage',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text(
                      'En acceptant, vous reconnaissez que si un parrain vous est attribué, vous avez l\'obligation de suivre votre formation jusqu\'à la fin.',
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'En cas d\'abandon injustifié, vous devrez rembourser les fonds versés par le parrain.',
                    ),
                    const SizedBox(height: 20),
                    const Text('Acceptez-vous ces conditions ?'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Radio<bool>(
                        //   value: true,
                        //   groupValue: accepted,
                        //   onChanged: (bool? value) {
                        //     setState(() {
                        //       accepted = value ?? false;
                        //     });
                        //   },
                        // ),
                        //const Expanded(child: Text('J\'accepte les conditions')),
                        RadioGroup<bool>(
                          groupValue: accepted,
                          onChanged: (bool? value) {
                            setState(() {
                              accepted = value ?? false;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Radio<bool>(value: true),
                              Text('J\'accepte les conditions'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: accepted
                      ? () async {
                          Navigator.of(context).pop();
                          await _inscrire(
                            payerDirectement: false,
                            demanderParrainage: true,
                          );
                        }
                      : null, // Button is disabled if conditions are not accepted
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3EB2FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Oui, je confirme'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    bool avecParrainage, {
    bool isGratuit = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isGratuit
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône animée
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isGratuit ? Colors.green : Color(0xFF3EB2FF),
                    boxShadow: [
                      BoxShadow(
                        color: (isGratuit ? Colors.green : Colors.blue)
                            .withValues(alpha: 0.3),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    isGratuit ? Icons.celebration : Icons.check_circle,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 25),
                // Titre
                Text(
                  isGratuit
                      ? '🎉 Inscription confirmée !'
                      : avecParrainage
                      ? 'Demande envoyée'
                      : 'Inscription réussie',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: isGratuit
                        ? Colors.green.shade800
                        : Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                // Message principal
                Text(
                  isGratuit
                      ? 'Félicitations ! Vous êtes maintenant inscrit à cette formation gratuite.'
                      : avecParrainage
                      ? 'Votre demande de parrainage a bien été prise en compte.'
                      : 'Vous êtes maintenant inscrit à cette formation.',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Message secondaire
                Text(
                  isGratuit
                      ? 'Vous recevrez bientôt tous les détails par email. Bonne formation !'
                      : avecParrainage
                      ? 'Nous vous contacterons très bientôt pour la suite du processus.'
                      : 'Vous recevrez une confirmation par email.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Bouton de fermeture
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGratuit ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Parfait !',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Popup d'erreur en haut de l'écran
  void _showErrorPopup(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () {
                    overlayEntry.remove();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Retirer automatiquement après 4 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Widget _buildHeader(Map<String, dynamic> details) {
    // Récupérer la photo, nom et email du centre depuis les données de la formation
    final f = _formation ?? {};

    // DEBUG: Afficher toutes les clés disponibles
    debugPrint('=== DEBUG FORMATION ===');
    debugPrint('Formation keys: ${f.keys.toList()}');

    // Le centre est maintenant directement dans f['centre'] (ajouté par _fetch)
    final centreInfo = f['centre'] ?? {};
    debugPrint('Centre keys: ${centreInfo.keys.toList()}');

    // Vérifier si le centre a un utilisateur
    final centreUtil = centreInfo['utilisateur'] ?? {};

    debugPrint('CentreUtil keys: ${centreUtil.keys.toList()}');
    debugPrint('=== END DEBUG ===');

    // Récupérer le logo (essayer plusieurs chemins)
    String logoUrl = '';
    if (centreUtil['urlPhoto'] != null &&
        centreUtil['urlPhoto'].toString().trim().isNotEmpty) {
      logoUrl = centreUtil['urlPhoto'].toString().trim();
    } else if (centreInfo['logoUrl'] != null &&
        centreInfo['logoUrl'].toString().trim().isNotEmpty) {
      logoUrl = centreInfo['logoUrl'].toString().trim();
    } else if (centreInfo['urlPhoto'] != null &&
        centreInfo['urlPhoto'].toString().trim().isNotEmpty) {
      logoUrl = centreInfo['urlPhoto'].toString().trim();
    }

    // Récupérer le nom du centre
    String centreName = '';
    if (centreInfo['nom'] != null &&
        centreInfo['nom'].toString().trim().isNotEmpty) {
      centreName = centreInfo['nom'].toString().trim();
      debugPrint('✅ Nom trouvé: $centreName');
    } else if (centreUtil['nom'] != null &&
        centreUtil['nom'].toString().trim().isNotEmpty) {
      centreName = centreUtil['nom'].toString().trim();
      debugPrint('✅ Nom trouvé dans centreUtil: $centreName');
    } else {
      debugPrint('❌ NOM PAS TROUVÉ');
      debugPrint('centreInfo[nom]: ${centreInfo['nom']}');
      debugPrint('centreUtil[nom]: ${centreUtil['nom']}');
    }

    // Récupérer l'email du centre
    String centreEmail = '';
    if (centreInfo['email'] != null &&
        centreInfo['email'].toString().trim().isNotEmpty) {
      centreEmail = centreInfo['email'].toString().trim();
      print('✅ Email trouvé: $centreEmail');
    } else if (centreUtil['email'] != null &&
        centreUtil['email'].toString().trim().isNotEmpty) {
      centreEmail = centreUtil['email'].toString().trim();
      print('✅ Email trouvé dans centreUtil: $centreEmail');
    } else {
      print('❌ EMAIL PAS TROUVÉ');
      print('centreInfo[email]: ${centreInfo['email']}');
      print('centreUtil[email]: ${centreUtil['email']}');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileAvatar(
            photoUrl: logoUrl.isNotEmpty ? logoUrl : null,
            radius: 50,
            isPerson: false,
            backgroundColor: Colors.blue[100],
<<<<<<< HEAD
            iconColor: Colors.blue,
=======
            backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
            onBackgroundImageError: logoUrl.isNotEmpty
                ? (_, __) {
                    // Si l'image ne charge pas, on garde juste le fond coloré
                  }
                : null,
            child: logoUrl.isEmpty
                ? const Icon(Icons.business, size: 40, color: Colors.blue)
                : null,
>>>>>>> main
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nom du centre en premier (en gros et bleu)
                Text(
                  centreName.isNotEmpty ? centreName : 'Centre de formation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: centreName.isNotEmpty
                        ? const Color(0xFF3EB2FF)
                        : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                // Email du centre en dessous
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        centreEmail.isNotEmpty
                            ? centreEmail
                            : 'Email non disponible',
                        style: TextStyle(
                          color: centreEmail.isNotEmpty
                              ? Colors.grey[700]
                              : Colors.grey[400],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox(Map<String, dynamic> details) {
    final List<Widget> rows = [];

    rows.add(
      _buildInfoBoxRow(
        'Places disponibles',
        (details['places'] ?? '—').toString(),
        Icons.group,
      ),
    );

    // Afficher le coût seulement si la formation n'est pas gratuite
    final isGratuit =
        _formation?['gratuit'] == true ||
        (details['cout'] as num?)?.toDouble() == 0.0;

    if (!isGratuit && details['cout'] != null) {
      rows.add(const Divider());
      rows.add(
        _buildInfoBoxRow(
          'Coût',
          (details['cout'] ?? '—').toString(),
          Icons.attach_money,
        ),
      );
    } else if (isGratuit) {
      rows.add(const Divider());
      rows.add(_buildInfoBoxRow('Coût', 'Gratuit', Icons.attach_money));
    }

    if (details['type'] != null && details['type'] != '—') {
      rows.add(const Divider());
      rows.add(
        _buildInfoBoxRow(
          'Type de formation',
          (details['type'] ?? '—').toString(),
          Icons.school,
        ),
      );
    }

    if (details['duree'] != null) {
      rows.add(const Divider());
      rows.add(
        _buildInfoBoxRow(
          'Durée',
          (details['duree'] ?? '—').toString(),
          Icons.access_time,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildInfoBoxRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  void _naviguerVersPaiement() {
    if (widget.formationId == null || _formation == null) return;

    // Récupérer le montant total de la formation
    final montantTotal = (_formation!['cout'] as num?)?.toDouble() ?? 0.0;
    final titre = _formation!['titre']?.toString() ?? 'Formation';

    if (montantTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer le montant de la formation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Naviguer vers la page de paiement
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaiementPage(
          formationId: widget.formationId!,
          formationTitre: titre,
          montantTotal: montantTotal,
        ),
      ),
    );
  }

<<<<<<< HEAD
  // Vérifier l'inscription existante avant d'afficher le dialogue de choix
  Future<void> _verifierEtInscrire() async {
    if (widget.formationId == null) return;
    
    setState(() => _loading = true);
    
    // Vérifier si la formation est gratuite
    final isGratuit = _formation?['gratuit'] == true || 
                      (_formation?['cout'] as num?)?.toDouble() == 0.0;
    
    // Vérifier TOUJOURS si l'utilisateur a déjà une inscription (gratuite ou payante)
    try {
      debugPrint('🔍 Vérification des inscriptions existantes avant affichage du dialogue...');
      final mesInscriptions = await _inscriptions.mesInscriptions();
      final inscriptionExistante = mesInscriptions.firstWhere(
        (insc) => insc['formation']?['id'] == widget.formationId,
        orElse: () => <String, dynamic>{},
      );
      
      if (inscriptionExistante.isNotEmpty) {
        // L'utilisateur a déjà une inscription
        final statut = inscriptionExistante['statut']?.toString() ?? 'INCONNU';
        final statutLibelle = _getStatutLibelle(statut);
        final demandeParrainage = inscriptionExistante['demandeParrainage'] == true;
        final idInscription = inscriptionExistante['id'];
        
        debugPrint('ℹ️ Inscription existante trouvée avec statut: $statut');
        
        // Vérifier s'il y a des paiements pour cette inscription
        bool aDesPaiements = false;
        try {
          final PaiementService paiementService = PaiementService();
          final paiements = await paiementService.getPaiementsByInscription(idInscription);
          aDesPaiements = paiements.isNotEmpty;
          debugPrint('💰 Paiements trouvés: ${paiements.length}');
        } catch (e) {
          debugPrint('⚠️ Erreur lors de la vérification des paiements: $e');
        }
        
        if (mounted) {
          setState(() => _loading = false);
          _showInscriptionExistanteDialog(
            statutLibelle, 
            statut, 
            aDesPaiements: aDesPaiements,
            demandeParrainage: demandeParrainage,
            isGratuit: isGratuit,
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la vérification des inscriptions: $e');
      // Continuer avec l'inscription normale si la vérification échoue
    }
    
    // Si pas d'inscription existante, continuer avec le processus normal
    if (mounted) {
      setState(() => _loading = false);
      
      if (isGratuit) {
        // Inscription directe pour les formations gratuites
        _inscrire(payerDirectement: false, demanderParrainage: false);
      } else {
        // Afficher le dialogue de choix pour les formations payantes
        _showInscriptionChoiceDialog(context);
      }
    }
  }

  Future<void> _inscrire({required bool payerDirectement, bool demanderParrainage = false}) async {
=======
  Future<void> _inscrire({
    required bool payerDirectement,
    bool demanderParrainage = false,
  }) async {
>>>>>>> main
    if (widget.formationId == null) return;

    setState(() => _loading = true);

    // Vérifier si la formation est gratuite
<<<<<<< HEAD
    final isGratuit = _formation?['gratuit'] == true || 
                      (_formation?['cout'] as num?)?.toDouble() == 0.0;
    
    // Vérifier TOUJOURS si l'utilisateur a déjà une inscription (gratuite ou payante)
    try {
      debugPrint('🔍 Vérification des inscriptions existantes...');
      final mesInscriptions = await _inscriptions.mesInscriptions();
      final inscriptionExistante = mesInscriptions.firstWhere(
        (insc) => insc['formation']?['id'] == widget.formationId,
        orElse: () => <String, dynamic>{},
      );
      
      if (inscriptionExistante.isNotEmpty) {
        // L'utilisateur a déjà une inscription
        final statut = inscriptionExistante['statut']?.toString() ?? 'INCONNU';
        final statutLibelle = _getStatutLibelle(statut);
        final demandeParrainage = inscriptionExistante['demandeParrainage'] == true;
        final idInscription = inscriptionExistante['id'];
        
        debugPrint('ℹ️ Inscription existante trouvée avec statut: $statut');
        
        // Vérifier s'il y a des paiements pour cette inscription
        bool aDesPaiements = false;
        try {
          final PaiementService paiementService = PaiementService();
          final paiements = await paiementService.getPaiementsByInscription(idInscription);
          aDesPaiements = paiements.isNotEmpty;
          debugPrint('💰 Paiements trouvés: ${paiements.length}');
        } catch (e) {
          debugPrint('⚠️ Erreur lors de la vérification des paiements: $e');
        }
        
        if (mounted) {
          setState(() => _loading = false);
          _showInscriptionExistanteDialog(
            statutLibelle, 
            statut, 
            aDesPaiements: aDesPaiements,
            demandeParrainage: demandeParrainage,
            isGratuit: isGratuit,
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la vérification des inscriptions: $e');
      // Continuer avec l'inscription normale si la vérification échoue
    }
    
=======
    final isGratuit =
        _formation?['gratuit'] == true ||
        (_formation?['cout'] as num?)?.toDouble() == 0.0;

>>>>>>> main
    try {
      // 1. S'inscrire à la formation
      debugPrint('📝 Inscription à la formation ${widget.formationId}...');
      await _inscriptions.sInscrire(
        widget.formationId!,
        payerDirectement: payerDirectement,
      );
      debugPrint('✅ Inscription réussie');

      // 2. Si demande de parrainage, créer la demande
      if (demanderParrainage) {
        debugPrint('💰 Création de la demande de parrainage...');
        final me = await _profile.getMe();
        final jeuneId = me['id'] as int;

        await _parrainages.creerDemande(
          idJeune: jeuneId,
          idFormation: widget.formationId!,
          idParrain:
              null, // Null = le jeune ne choisit pas de parrain spécifique
        );
        debugPrint('✅ Demande de parrainage créée');
      }

      if (mounted) {
        _showSuccessDialog(context, demanderParrainage, isGratuit: isGratuit);
      }
    } on Exception catch (e) {
      final errorMsg = e.toString();
      debugPrint('❌ Erreur inscription: $errorMsg');

      // Vérifier si c'est une erreur "déjà inscrit"
      if (errorMsg.contains('409') ||
          errorMsg.contains('déjà inscrit') ||
          errorMsg.toLowerCase().contains('already') ||
          errorMsg.toLowerCase().contains('déjà')) {
        // Pour les formations payantes, on a déjà vérifié avant, mais si on arrive ici,
        // c'est que le backend a aussi détecté l'inscription
        if (mounted) {
<<<<<<< HEAD
          // Essayer de récupérer le statut de l'inscription existante
          try {
            final mesInscriptions = await _inscriptions.mesInscriptions();
            final inscriptionExistante = mesInscriptions.firstWhere(
              (insc) => insc['formation']?['id'] == widget.formationId,
              orElse: () => <String, dynamic>{},
            );
            
            if (inscriptionExistante.isNotEmpty) {
              final statut = inscriptionExistante['statut']?.toString() ?? 'INCONNU';
              final statutLibelle = _getStatutLibelle(statut);
              _showInscriptionExistanteDialog(statutLibelle, statut);
              return;
            }
          } catch (_) {
            // Si on ne peut pas récupérer le statut, afficher le message générique
          }
          
          _showErrorPopup(
            context,
            'Vous êtes déjà inscrit à cette formation.',
          );
=======
          _showErrorPopup(context, 'Vous êtes déjà inscrit à cette formation.');
>>>>>>> main
        }
        return;
      }

      // Si l'erreur est "déjà inscrit" (409) ET qu'on veut faire une demande de parrainage
      if (errorMsg.contains('409') &&
          errorMsg.contains('déjà inscrit') &&
          demanderParrainage) {
        debugPrint(
          'ℹ️ Déjà inscrit - Tentative de création du parrainage uniquement...',
        );
        try {
          final me = await _profile.getMe();
          final jeuneId = me['id'] as int;

          await _parrainages.creerDemande(
            idJeune: jeuneId,
            idFormation: widget.formationId!,
            idParrain: null,
          );
          debugPrint(
            '✅ Demande de parrainage créée pour inscription existante',
          );

          if (mounted) _showSuccessDialog(context, true);
          return;
        } catch (parrainageError) {
          debugPrint('❌ Erreur création parrainage: $parrainageError');
          if (mounted) {
            _showErrorPopup(
              context,
              'Erreur lors de la demande de parrainage: ${parrainageError.toString().replaceAll('Exception: ', '')}',
            );
          }
        }
      } else {
        // Autre erreur - afficher en popup en haut
        if (mounted) {
          String cleanError = errorMsg
              .replaceAll('Exception: ', '')
              .replaceAll('HttpException: ', '')
              .replaceAll('FormatException: ', '');

          _showErrorPopup(context, cleanError);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

<<<<<<< HEAD
  // Convertir le statut en libellé lisible
  String _getStatutLibelle(String statut) {
    switch (statut.toUpperCase()) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'VALIDE':
        return 'Validée';
      case 'REFUSE':
        return 'Refusée';
      case 'TERMINE':
        return 'Terminée';
      case 'ANNULER':
        return 'Annulée';
      default:
        return statut;
    }
  }

  // Popup informatif pour inscription existante - Version améliorée et personnalisée
  void _showInscriptionExistanteDialog(
    String statutLibelle, 
    String statut, {
    bool aDesPaiements = false,
    bool demandeParrainage = false,
    bool isGratuit = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Déterminer la couleur et l'icône selon le statut
        Color couleurStatut;
        Color couleurStatutFoncee;
        IconData iconeStatut;
        String titre;
        String message;
        List<Widget> badges = [];
        
        switch (statut.toUpperCase()) {
          case 'VALIDE':
            couleurStatut = Colors.green;
            couleurStatutFoncee = Colors.green[800]!;
            iconeStatut = Icons.check_circle;
            titre = '🎉 Inscription validée !';
            if (isGratuit) {
              message = 'Félicitations ! Votre inscription à cette formation gratuite a été validée. Vous pouvez maintenant suivre votre formation.';
            } else if (aDesPaiements) {
              message = 'Excellent ! Votre inscription a été validée après confirmation de votre paiement. Vous pouvez maintenant suivre votre formation.';
            } else if (demandeParrainage) {
              message = 'Parfait ! Votre inscription a été validée grâce à votre demande de parrainage. Vous pouvez maintenant suivre votre formation.';
            } else {
              message = 'Votre inscription à cette formation a été validée. Vous pouvez suivre votre formation.';
            }
            break;
          case 'EN_ATTENTE':
            couleurStatut = Colors.orange;
            couleurStatutFoncee = Colors.orange[800]!;
            iconeStatut = Icons.hourglass_empty;
            titre = '⏳ Inscription en attente';
            if (isGratuit) {
              message = 'Votre inscription à cette formation gratuite est en cours de traitement. Vous serez notifié une fois qu\'elle sera validée.';
            } else if (aDesPaiements) {
              message = 'Votre paiement a été enregistré et votre inscription est en attente de validation par l\'administration. Vous recevrez une notification une fois validée.';
            } else if (demandeParrainage) {
              message = 'Votre demande de parrainage a été prise en compte. Votre inscription est en attente de validation. Vous serez notifié une fois qu\'elle sera traitée.';
            } else {
              message = 'Votre inscription est en attente de validation. Vous serez notifié une fois qu\'elle sera traitée.';
            }
            break;
          case 'REFUSE':
            couleurStatut = Colors.red;
            couleurStatutFoncee = Colors.red[800]!;
            iconeStatut = Icons.cancel;
            titre = '❌ Inscription refusée';
            message = 'Votre inscription à cette formation a été refusée. Si vous pensez qu\'il s\'agit d\'une erreur, veuillez contacter le support.';
            break;
          default:
            couleurStatut = Colors.blue;
            couleurStatutFoncee = Colors.blue[800]!;
            iconeStatut = Icons.info;
            titre = 'ℹ️ Inscription existante';
            message = 'Vous avez déjà une inscription à cette formation.';
        }
        
        // Ajouter des badges selon le contexte
        if (aDesPaiements) {
          badges.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payment, color: Colors.blue, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Paiement effectué',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (demandeParrainage) {
          badges.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.purple, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Parrainage demandé',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (isGratuit) {
          badges.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Formation gratuite',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  couleurStatut.withValues(alpha: 0.05),
                  couleurStatut.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de statut avec animation
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: couleurStatut,
                    boxShadow: [
                      BoxShadow(
                        color: couleurStatut.withValues(alpha: 0.3),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    iconeStatut,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 25),
                
                // Titre
                Text(
                  titre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: couleurStatutFoncee,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                
                // Message personnalisé
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Badges contextuels
                if (badges.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: badges,
                  ),
                  const SizedBox(height: 15),
                ],
                
                // Badge de statut principal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: couleurStatut.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: couleurStatut.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconeStatut, color: couleurStatut, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Statut: $statutLibelle',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: couleurStatutFoncee,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Bouton de fermeture
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: couleurStatut,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Compris, merci !',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
=======
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
>>>>>>> main
}
