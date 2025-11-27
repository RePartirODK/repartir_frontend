import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_paiement.dart';
import 'package:repartir_frontend/services/paiement_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:intl/intl.dart';

class MesPaiementsPage extends StatefulWidget {
  const MesPaiementsPage({Key? key}) : super(key: key);

  @override
  State<MesPaiementsPage> createState() => _MesPaiementsPageState();
}

class _MesPaiementsPageState extends State<MesPaiementsPage> {
  final PaiementService _paiementService = PaiementService();
  final ProfileService _profileService = ProfileService();
  
  bool _loading = true;
  String? _error;
  List<ResponsePaiement> _paiements = [];

  @override
  void initState() {
    super.initState();
    _loadPaiements();
  }

  Future<void> _loadPaiements() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final me = await _profileService.getMe();
      final jeuneId = me['id'] as int;
      
      _paiements = await _paiementService.getPaiementsByJeune(jeuneId);
      
      // Trier par date décroissante
      _paiements.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'VALIDE':
        return Colors.green;
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'REFUSE':
        return Colors.red;
      case 'A_REMBOURSE':
        return Colors.purple;
      case 'REMBOURSE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'VALIDE':
        return 'Validé';
      case 'EN_ATTENTE':
        return 'En attente';
      case 'REFUSE':
        return 'Refusé';
      case 'A_REMBOURSE':
        return 'À rembourser';
      case 'REMBOURSE':
        return 'Remboursé';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'VALIDE':
        return Icons.check_circle;
      case 'EN_ATTENTE':
        return Icons.hourglass_empty;
      case 'REFUSE':
        return Icons.cancel;
      case 'A_REMBOURSE':
        return Icons.payment;
      case 'REMBOURSE':
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
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
                child: _buildBody(),
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
              title: 'Mes Paiements',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Erreur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPaiements,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_paiements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'Aucun paiement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Vous n\'avez effectué aucun paiement pour le moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPaiements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paiements.length,
        itemBuilder: (context, index) {
          final paiement = _paiements[index];
          return _buildPaiementCard(paiement);
        },
      ),
    );
  }

  Widget _buildPaiementCard(ResponsePaiement paiement) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final statusColor = _getStatusColor(paiement.status);
    final statusLabel = _getStatusLabel(paiement.status);
    final statusIcon = _getStatusIcon(paiement.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _showPaiementDetails(paiement),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Référence
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Référence',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          paiement.reference,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Montant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${paiement.montant.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(paiement.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaiementDetails(ResponsePaiement paiement) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final statusColor = _getStatusColor(paiement.status);
    final statusLabel = _getStatusLabel(paiement.status);
    final statusIcon = _getStatusIcon(paiement.status);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Détails du paiement'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statut
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 24,
                          color: statusColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                // Détails
                _buildDetailRow('Référence', paiement.reference),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Montant',
                  '${paiement.montant.toStringAsFixed(0)} FCFA',
                  valueColor: Colors.green,
                  valueBold: true,
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Date', dateFormat.format(paiement.date)),
                const SizedBox(height: 12),
                _buildDetailRow('ID Formation', '#${paiement.idFormation}'),
                if (paiement.idParrainage != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('ID Parrainage', '#${paiement.idParrainage}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}







