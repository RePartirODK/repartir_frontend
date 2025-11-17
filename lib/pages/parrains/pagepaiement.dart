import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/api_service.dart';
import 'package:repartir_frontend/services/formations_service.dart';
import 'package:repartir_frontend/services/inscriptions_service.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF2196F3); // Couleur principale bleue
const Color primaryGreen = Color(0xFF4CAF50); // Vert pour Montant payé
const Color primaryRed = Color(0xFFF44336); // Rouge pour Montant restant

// --- 2. WIDGET PRINCIPAL : PaymentPage ---
class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.idJeune,
    required this.idFormation,
    required this.idParrainage,
    required this.jeuneName,
  });
  final int idJeune;
  final int idFormation;
  final int idParrainage;
  final String jeuneName;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Contrôleurs pour les champs de saisie
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Simuler les données (à intégrer avec le backend plus tard)

  final _api = ApiService();
  final _formationsService = FormationsService();
  final _inscriptionsService = InscriptionsService();

  bool _loading = true;
  String? _error;
  String _formationName = '—';
  String _dateDebut = '—';
  String _dateFin = '—';
  String _certification = '—';
  double _costTotal = 0.0;
  double _amountPaid = 0.0;
  int? _idInscription;
  double get amountRemaining => _costTotal - _amountPaid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Formation details
      final f = await _formationsService.details(widget.idFormation);
      final d = f;
      _formationName = (d['titre'] ?? '').toString();
      final debut = d['date_debut']?.toString();
      final fin = d['date_fin']?.toString();
      _dateDebut = _safeFormatDate(debut);
      _dateFin = _safeFormatDate(fin);
      _certification = (d['duree'] ?? '').toString().isNotEmpty ? 'Oui' : '—';
      _costTotal = (d['cout'] as num?)?.toDouble() ?? 0.0;

      // Inscriptions for formation → find the jeune’s inscription by name
      final inscs = await _inscriptionsService.listByFormation(
        widget.idFormation,
      );
      final found = inscs.firstWhere(
        (i) => (i['nomJeune'] ?? '') == widget.jeuneName,
        orElse: () => {},
      );
      _idInscription = (found['id'] is int)
          ? found['id'] as int
          : int.tryParse(found['id']?.toString() ?? '');

      // Payments for inscription (sum validated)
      if (_idInscription != null) {
        final res = await _api.get('/paiements/inscription/${_idInscription}');
        final List data = _api.decodeJson<List<dynamic>>(
          res,
          (d) => d as List<dynamic>,
        );
        _amountPaid = data.fold<double>(0.0, (sum, p) {
          final status = (p['status'] ?? '').toString();
          final montant = (p['montant'] as num?)?.toDouble() ?? 0.0;
          return status == 'VALIDE' ? sum + montant : sum;
        });
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _safeFormatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    if (d == null) return '—';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Erreur: $_error'))
          : Stack(
              children: [
                // 1. En-tête bleu et barre de titre
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomHeader(
                    title: "Paiement",
                    showBackButton: true,
                    height: 150,
                  ),
                ),

                // 2. Contenu principal (scrollable)
                Positioned.fill(
                  top: 200, // Démarre le contenu sous le titre
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 2.1 Récapitulatif de la Formation ---
                          _buildFormationSummaryCard(),
                          const SizedBox(height: 30),

                          // --- 2.2 Bilan Financier ---
                          _buildFinancialSummary(),
                          const SizedBox(height: 40),

                          // --- 2.3 Champ Saisir le Montant ---
                          _buildInputField(
                            _amountController,
                            'Saisissez le montant à payer',
                            Icons.money,
                          ),
                          const SizedBox(height: 15),

                          // --- 2.4 Champ Numéro de Téléphone ---
                          _buildInputField(
                            _phoneController,
                            'Numero de téléphone',
                            Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 40),

                          // --- 2.5 Bouton Payer ---
                          _buildPaymentAction(),
                          const SizedBox(height: 40), // Espace en bas
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  // Carte de résumé de la formation
  Widget _buildFormationSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: const Text(
              'Formations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              _formationName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 25, color: Colors.white),

          // Détails Date Début/Fin/Certification
          _buildDetailRow('Date debut', _dateDebut),
          const SizedBox(height: 8),
          _buildDetailRow('Date Fin', _dateFin),
          const SizedBox(height: 8),
          _buildDetailRow('Certification', _certification),
        ],
      ),
    );
  }

  // Ligne de détail simple (clé/valeur)
  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Bilan financier
  Widget _buildFinancialSummary() {
    // Formatter les montants en FCFA (ou autre devise)
    String formatCurrency(double amount) {
      return '${amount.toInt().toStringAsFixed(0)}.00';
    }

    return Column(
      children: [
        // Coût total
        _buildSummaryRow(
          'Coût de la formation',
          formatCurrency(_costTotal),
          Colors.black87,
        ),
        const SizedBox(height: 10),
        // Montant payé (vert)
        _buildSummaryRow(
          'Montant payé',
          formatCurrency(_amountPaid),
          primaryGreen,
          isBold: true,
        ),
        const SizedBox(height: 10),
        // Montant restant (rouge)
        _buildSummaryRow(
          'Montant restant',
          formatCurrency(amountRemaining),
          primaryRed,
          isBold: true,
        ),
      ],
    );
  }

  // Ligne de résumé financier
  Widget _buildSummaryRow(
    String title,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Champ de saisie stylisé
  Widget _buildInputField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        // Style de bordure claire pour correspondre à l'image
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
    );
  }

  // Bouton d'action pour le paiement
  Widget _buildPaymentAction() {
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: () async{
              debugPrint(
                'Action: Payer le montant ${_amountController.text} FCFA vers le ${_phoneController.text}',
              );
              final montant = double.tryParse(_amountController.text.trim());
              final phone = _phoneController.text.trim();
              if (montant == null || montant <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez saisir un montant valide.')),
                );
                return;
              }
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez saisir un numéro de téléphone.')),
                );
                return;
              }
              if (_idInscription == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inscription introuvable pour ce jeune.')),
                );
                return;
              }
              // Create payment
              try {
                final res = await _api.post(
                  '/paiements/creer',
                  body: jsonEncode({
                    'idJeune': widget.idJeune,
                    'idInscription': _idInscription,
                    'montant': montant,
                    'idParrainage': widget.idParrainage,
                  }),
                  extraHeaders: {'Content-Type': 'application/json'},
                );
                _api.decodeJson(res, (d) => d); // will throw on errors
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paiement créé. En attente de validation.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur de paiement: $e')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              // Icône qui ressemble à l'icône de transaction/paiement de l'image
              child: const Icon(
                Icons.south_west_outlined,
                color: Colors.black,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Payer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
