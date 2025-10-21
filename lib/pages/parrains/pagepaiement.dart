import 'package:flutter/material.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF2196F3); // Couleur principale bleue
const Color primaryGreen = Color(0xFF4CAF50); // Vert pour Montant payé
const Color primaryRed = Color(0xFFF44336);  // Rouge pour Montant restant

// --- 1. CLASSE CLIPPER (pour la forme 'blob' de l'en-tête) ---
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85); // Début du clip sur la gauche
    
    // Courbe cubique pour la forme irrégulière (le "blob" pour l'en-tête)
    final controlPoint1 = Offset(size.width * 0.25, size.height * 1.15); 
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.55);
    final endPoint = Offset(size.width, size.height * 0.65);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy, 
      controlPoint2.dx, controlPoint2.dy, 
      endPoint.dx, endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- 2. WIDGET PRINCIPAL : PaymentPage ---
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Contrôleurs pour les champs de saisie
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Simuler les données (à intégrer avec le backend plus tard)
  final String formationName = 'Couture';
  final String dateDebut = '12/03/2025';
  final String dateFin = '12/05/2025';
  final String certification = 'Oui';
  final double costTotal = 150000.00;
  final double amountPaid = 100000.00;
  double get amountRemaining => costTotal - amountPaid;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. En-tête bleu et barre de titre
          _buildHeader(),
          
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
                    _buildInputField(_amountController, 'Saisissez le montant à payer', Icons.money),
                    const SizedBox(height: 15),
                    
                    // --- 2.4 Champ Numéro de Téléphone ---
                    _buildInputField(_phoneController, 'Numero de téléphone', Icons.phone, keyboardType: TextInputType.phone),
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
  
  // En-tête avec le clipper et le titre
  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: CustomShapeClipper(),
        child: Container(
          height: 250, // Hauteur de l'en-tête bleu
          color: primaryBlue,
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context), 
                ),
                // Titre
                Expanded(
                  child: Text(
                    'Paiement',
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Placeholder pour le logo RePartir (alignement)
                const SizedBox(width: 48), 
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                color: primaryBlue
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              formationName,
              style: const TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87
              ),
            ),
          ),
          const Divider(height: 25, color: Colors.white),
          
          // Détails Date Début/Fin/Certification
          _buildDetailRow('Date debut', dateDebut),
          const SizedBox(height: 8),
          _buildDetailRow('Date Fin', dateFin),
          const SizedBox(height: 8),
          _buildDetailRow('Certification', certification),
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
        _buildSummaryRow('Coût de la formation', formatCurrency(costTotal), Colors.black87),
        const SizedBox(height: 10),
        // Montant payé (vert)
        _buildSummaryRow('Montant payé', formatCurrency(amountPaid), primaryGreen, isBold: true),
        const SizedBox(height: 10),
        // Montant restant (rouge)
        _buildSummaryRow('Montant restant', formatCurrency(amountRemaining), primaryRed, isBold: true),
      ],
    );
  }
  
  // Ligne de résumé financier
  Widget _buildSummaryRow(String title, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16, 
            color: color, 
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16, 
            color: color, 
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal
          ),
        ),
      ],
    );
  }
  
  // Champ de saisie stylisé
  Widget _buildInputField(
    TextEditingController controller, 
    String hintText, 
    IconData icon,
    {TextInputType keyboardType = TextInputType.text}
  ) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  // Bouton d'action pour le paiement
  Widget _buildPaymentAction() {
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Simuler l'action de paiement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Paiement de ${_amountController.text} en cours vers le ${_phoneController.text}...'
                  ),
                ),
              );
              print('Action: Payer le montant');
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha:  0.3),
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
                size: 50
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


