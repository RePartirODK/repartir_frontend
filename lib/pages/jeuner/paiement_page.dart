import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/request/request_paiement.dart';
import 'package:repartir_frontend/services/paiement_service.dart';
import 'package:repartir_frontend/services/inscriptions_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';

class PaiementPage extends StatefulWidget {
  const PaiementPage({
    Key? key,
    required this.formationId,
    required this.formationTitre,
    required this.montantTotal,
  }) : super(key: key);

  final int formationId;
  final String formationTitre;
  final double montantTotal;

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montantController = TextEditingController();
  final PaiementService _paiementService = PaiementService();
  final InscriptionsService _inscriptionsService = InscriptionsService();
  final ProfileService _profileService = ProfileService();
  
  bool _loading = false;
  bool _paiementPartiel = false;

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _confirmerPaiement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Récupérer les informations du jeune connecté
      final me = await _profileService.getMe();
      final jeuneId = me['id'] as int;

      int? inscriptionId;

      // 2. Créer l'inscription d'abord (avec payerDirectement=false pour éviter la création automatique de paiement)
      try {
        print('📝 Création de l\'inscription...');
        final inscription = await _inscriptionsService.sInscrire(
          widget.formationId,
          payerDirectement: false, // false pour créer le paiement manuellement après
        );
        inscriptionId = inscription['id'] as int;
        print('✅ Inscription créée avec ID: $inscriptionId');
      } catch (e) {
        // Si l'utilisateur est déjà inscrit, récupérer l'ID de l'inscription existante
        final errorMsg = e.toString();
        if (errorMsg.contains('409') || errorMsg.contains('déjà inscrit')) {
          print('ℹ️ Déjà inscrit - Récupération de l\'inscription existante...');
          
          // Récupérer les inscriptions du jeune pour trouver celle de cette formation
          final mesInscriptions = await _inscriptionsService.mesInscriptions();
          final inscriptionExistante = mesInscriptions.firstWhere(
            (insc) => insc['formation']?['id'] == widget.formationId,
            orElse: () => throw Exception('Inscription non trouvée'),
          );
          
          inscriptionId = inscriptionExistante['id'] as int;
          print('✅ Inscription existante trouvée avec ID: $inscriptionId');
        } else {
          rethrow; // Autre erreur, on la remonte
        }
      }

      if (inscriptionId == null) {
        throw Exception('Impossible de récupérer l\'ID de l\'inscription');
      }

      // 3. Créer le paiement manuellement avec le montant saisi
      final montantAPayer = double.parse(_montantController.text);
      print('💰 Création du paiement de $montantAPayer FCFA...');
      
      final requestPaiement = RequestPaiement(
        idJeune: jeuneId,
        idInscription: inscriptionId,
        montant: montantAPayer,
        idParrainage: null, // Pas de parrainage pour un paiement direct
      );

      final responsePaiement = await _paiementService.creerPaiement(requestPaiement);
      print('✅ Paiement créé avec référence: ${responsePaiement.reference}');

      if (mounted) {
        _showSuccessDialog(
          reference: responsePaiement.reference,
          montant: montantAPayer,
          estPartiel: montantAPayer < widget.montantTotal,
        );
      }
    } catch (e) {
      print('❌ Erreur: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessDialog({
    required String reference,
    required double montant,
    required bool estPartiel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.check_circle, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Paiement enregistré !',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Référence', reference),
                    const Divider(),
                    _buildInfoRow('Montant payé', '${montant.toStringAsFixed(0)} FCFA'),
                    const Divider(),
                    _buildInfoRow(
                      'Statut',
                      estPartiel ? 'Paiement partiel' : 'Paiement total',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hourglass_empty, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'En attente de validation',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      estPartiel
                          ? 'Votre paiement partiel de ${montant.toStringAsFixed(0)} FCFA a été enregistré. Montant restant : ${(widget.montantTotal - montant).toStringAsFixed(0)} FCFA.\n\nUn administrateur va vérifier votre paiement. Vous recevrez un reçu par email une fois validé.'
                          : 'Votre paiement de ${montant.toStringAsFixed(0)} FCFA est en attente de validation. Un administrateur va vérifier votre paiement sous peu.\n\nVous recevrez un reçu par email une fois le paiement validé.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialogue
                  Navigator.of(context).pop(); // Retourner à la page précédente
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Terminer'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Titre de la page
                        const Text(
                          'Paiement de la formation',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Carte d'information de la formation
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.school, color: Colors.blue[700], size: 28),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.formationTitre,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Montant total',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${widget.montantTotal.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),

                        // Information sur le paiement
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue[700]),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Informations importantes',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Vous pouvez payer le montant total ou effectuer un paiement partiel.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Votre paiement sera en attente de validation par l\'administration.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Vous recevrez un reçu par email une fois le paiement validé.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Champ de saisie du montant
                        const Text(
                          'Montant à payer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _montantController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Entrez le montant',
                            prefixIcon: const Icon(Icons.attach_money, color: Colors.blue),
                            suffixText: 'FCFA',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un montant';
                            }
                            final montant = double.tryParse(value);
                            if (montant == null || montant <= 0) {
                              return 'Veuillez entrer un montant valide';
                            }
                            if (montant > widget.montantTotal) {
                              return 'Le montant ne peut pas dépasser ${widget.montantTotal.toStringAsFixed(0)} FCFA';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final montant = double.tryParse(value);
                            if (montant != null) {
                              setState(() {
                                _paiementPartiel = montant < widget.montantTotal;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 15),

                        // Indicateur de paiement partiel
                        if (_paiementPartiel && _montantController.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Montant restant à payer : ${(widget.montantTotal - (double.tryParse(_montantController.text) ?? 0)).toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 40),

                        // Bouton de confirmation
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _confirmerPaiement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Confirmer le paiement',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bouton annuler
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: _loading ? null : () => Navigator.pop(context),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Paiement',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

