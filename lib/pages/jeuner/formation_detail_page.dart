
import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/formations_service.dart';
import 'package:repartir_frontend/services/inscriptions_service.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/parrainages_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/api_service.dart';
import 'package:repartir_frontend/pages/jeuner/paiement_page.dart';

class FormationDetailPage extends StatefulWidget {
  const FormationDetailPage({Key? key, this.formationId}) : super(key: key);
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
  String? _error;
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
      _error = null;
    });
    try {
      // Vérifier si l'utilisateur est connecté
      final isConnected = await _api.hasToken();
      if (!isConnected) {
        throw Exception('Vous devez être connecté pour voir les détails de la formation. Veuillez vous connecter.');
      }
      
      _formation = await _formations.details(widget.formationId!);
      
      // If canceled, do not display the page
      if (_formation != null && (_formation!['statut']?.toString().toUpperCase() == 'ANNULER')) {
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
          print('Centre récupéré avec succès: ${centreDetails['nom']}');
        } catch (e) {
          print('Erreur lors de la récupération du centre: $e');
        }
      }
    } catch (e) {
      // Éviter d'afficher le token JWT dans l'erreur
      String errorMsg = '$e';
      if (errorMsg.contains('JWT') || errorMsg.contains('eyJ')) {
        errorMsg = 'Erreur d\'authentification. Veuillez vous reconnecter.';
      }
      _error = errorMsg;
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
    final dateDebut = f['date_debut']?.toString() ?? '';
    final dateFin = f['date_fin']?.toString() ?? '';
    final statut = (f['statut'] ?? '').toString();
    // Récupérer le nom du centre (essayer plusieurs chemins)
    String centerName = '';
    if (centreUtil['nom'] != null && centreUtil['nom'].toString().trim().isNotEmpty) {
      centerName = centreUtil['nom'].toString().trim();
    } else if (centreInfo['nom'] != null && centreInfo['nom'].toString().trim().isNotEmpty) {
      centerName = centreInfo['nom'].toString().trim();
    }
    
    // Récupérer l'email du centre (essayer plusieurs chemins)
    String centerEmail = '';
    if (centreUtil['email'] != null && centreUtil['email'].toString().trim().isNotEmpty) {
      centerEmail = centreUtil['email'].toString().trim();
    } else if (centreInfo['email'] != null && centreInfo['email'].toString().trim().isNotEmpty) {
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
      backgroundColor: Colors.grey[200],
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
                color: Colors.grey[200],
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
                      _buildSection(formationDetails['description_title']!,
                          formationDetails['description_body']!),
                      const SizedBox(height: 20),
                      _buildSection(formationDetails['dates_title']!,
                          formationDetails['dates_body']!,
                          icon: Icons.date_range),
                      const SizedBox(height: 20),
                      _buildInfoBox(formationDetails),
                      const SizedBox(height: 30),
                      
                      
                  if (statut == 'EN_ATTENTE')
                        Center(
                          child: ElevatedButton(
                            onPressed: _loading || widget.formationId == null
                                ? null
                                : () {
                                    _showInscriptionChoiceDialog(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
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
              height: 120,
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
                    backgroundColor: Colors.blue,
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
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('En acceptant, vous reconnaissez que si un parrain vous est attribué, vous avez l\'obligation de suivre votre formation jusqu\'à la fin.'),
                    const SizedBox(height: 10),
                    const Text('En cas d\'abandon injustifié, vous devrez rembourser les fonds versés par le parrain.'),
                    const SizedBox(height: 20),
                    const Text('Acceptez-vous ces conditions ?'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: accepted,
                          onChanged: (bool? value) {
                            setState(() {
                              accepted = value ?? false;
                            });
                          },
                        ),
                        const Expanded(child: Text('J\'accepte les conditions')),
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
                          await _inscrire(payerDirectement: false, demanderParrainage: true);
                        }
                      : null, // Button is disabled if conditions are not accepted
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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

  void _showSuccessDialog(BuildContext context, bool avecParrainage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                avecParrainage ? 'Demande envoyée' : 'Inscription réussie',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                avecParrainage
                    ? 'Votre demande de parrainage a bien été prise en compte.'
                    : 'Vous êtes maintenant inscrit à cette formation.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                avecParrainage
                    ? 'Nous vous contacterons très bientôt pour la suite du processus.'
                    : 'Vous recevrez une confirmation par email.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Fermer'),
              )
            ],
          ),
        );
      },
    );
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
    if (centreUtil['urlPhoto'] != null && centreUtil['urlPhoto'].toString().trim().isNotEmpty) {
      logoUrl = centreUtil['urlPhoto'].toString().trim();
    } else if (centreInfo['logoUrl'] != null && centreInfo['logoUrl'].toString().trim().isNotEmpty) {
      logoUrl = centreInfo['logoUrl'].toString().trim();
    } else if (centreInfo['urlPhoto'] != null && centreInfo['urlPhoto'].toString().trim().isNotEmpty) {
      logoUrl = centreInfo['urlPhoto'].toString().trim();
    }
    
    // Récupérer le nom du centre
    String centreName = '';
    if (centreInfo['nom'] != null && centreInfo['nom'].toString().trim().isNotEmpty) {
      centreName = centreInfo['nom'].toString().trim();
      debugPrint('✅ Nom trouvé: $centreName');
    } else if (centreUtil['nom'] != null && centreUtil['nom'].toString().trim().isNotEmpty) {
      centreName = centreUtil['nom'].toString().trim();
      debugPrint('✅ Nom trouvé dans centreUtil: $centreName');
    } else {
      debugPrint('❌ NOM PAS TROUVÉ');
      debugPrint('centreInfo[nom]: ${centreInfo['nom']}');
      debugPrint('centreUtil[nom]: ${centreUtil['nom']}');
    }
    
    // Récupérer l'email du centre
    String centreEmail = '';
    if (centreInfo['email'] != null && centreInfo['email'].toString().trim().isNotEmpty) {
      centreEmail = centreInfo['email'].toString().trim();
      print('✅ Email trouvé: $centreEmail');
    } else if (centreUtil['email'] != null && centreUtil['email'].toString().trim().isNotEmpty) {
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
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[100],
            backgroundImage: logoUrl.isNotEmpty
                ? NetworkImage(logoUrl) 
                : null,
            onBackgroundImageError: logoUrl.isNotEmpty
                ? (_, __) {
                    // Si l'image ne charge pas, on garde juste le fond coloré
                  }
                : null,
            child: logoUrl.isEmpty 
                ? const Icon(Icons.business, size: 40, color: Colors.blue) 
                : null,
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
                    color: centreName.isNotEmpty ? const Color(0xFF3EB2FF) : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                // Email du centre en dessous
              Row(
                children: [
                    const Icon(Icons.email_outlined, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        centreEmail.isNotEmpty ? centreEmail : 'Email non disponible',
                        style: TextStyle(
                          color: centreEmail.isNotEmpty ? Colors.grey[700] : Colors.grey[400],
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
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
                child: Text(content,
                    style: const TextStyle(fontSize: 16, height: 1.5))),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox(Map<String, dynamic> details) {
    final List<Widget> rows = [];
    
    rows.add(_buildInfoBoxRow('Places disponibles', (details['places'] ?? '—').toString(), Icons.group));
    
    if (details['cout'] != null) {
      rows.add(const Divider());
      rows.add(_buildInfoBoxRow('Coût', (details['cout'] ?? '—').toString(), Icons.attach_money));
    }
    
    if (details['type'] != null && details['type'] != '—') {
      rows.add(const Divider());
      rows.add(_buildInfoBoxRow('Type de formation', (details['type'] ?? '—').toString(), Icons.school));
    }
    
    if (details['duree'] != null) {
      rows.add(const Divider());
      rows.add(_buildInfoBoxRow('Durée', (details['duree'] ?? '—').toString(), Icons.access_time));
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: rows,
      ),
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

  Future<void> _inscrire({required bool payerDirectement, bool demanderParrainage = false}) async {
    if (widget.formationId == null) return;
    
    setState(() => _loading = true);
    
    try {
      // 1. S'inscrire à la formation
      debugPrint('📝 Inscription à la formation ${widget.formationId}...');
      await _inscriptions.sInscrire(widget.formationId!, payerDirectement: payerDirectement);
      debugPrint('✅ Inscription réussie');
      
      // 2. Si demande de parrainage, créer la demande
      if (demanderParrainage) {
        debugPrint('💰 Création de la demande de parrainage...');
        final me = await _profile.getMe();
        final jeuneId = me['id'] as int;
        
        await _parrainages.creerDemande(
          idJeune: jeuneId,
          idFormation: widget.formationId!,
          idParrain: null, // Null = le jeune ne choisit pas de parrain spécifique
        );
        debugPrint('✅ Demande de parrainage créée');
      }
      
      if (mounted) _showSuccessDialog(context, demanderParrainage);
    } on Exception catch (e) {
      final errorMsg = e.toString();
      debugPrint('❌ Erreur inscription: $errorMsg');
      
      // Si l'erreur est "déjà inscrit" (409) ET qu'on veut faire une demande de parrainage
      if (errorMsg.contains('409') && errorMsg.contains('déjà inscrit') && demanderParrainage) {
        debugPrint('ℹ️ Déjà inscrit - Tentative de création du parrainage uniquement...');
        try {
          final me = await _profile.getMe();
          final jeuneId = me['id'] as int;
          
          await _parrainages.creerDemande(
            idJeune: jeuneId,
            idFormation: widget.formationId!,
            idParrain: null,
          );
          debugPrint('✅ Demande de parrainage créée pour inscription existante');
          
          if (mounted) _showSuccessDialog(context, true);
          return;
        } catch (parrainageError) {
          debugPrint('❌ Erreur création parrainage: $parrainageError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la demande de parrainage: ${parrainageError.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Autre erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${errorMsg.replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
