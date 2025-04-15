import 'package:flutter/material.dart';
import '../../../models/repair_model.dart';
import '../../../theme/app_theme.dart';

/// Dialogue pour afficher les détails d'une réparation
class RepairDetailsDialog extends StatelessWidget {
  final RepairModel repair;
  final VoidCallback onEdit;

  const RepairDetailsDialog({
    super.key,
    required this.repair,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Détails de la réparation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec le statut
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: _getStatusColor(repair.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut: ${_getStatusText(repair.status)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(repair.status),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${repair.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Informations du client
            _buildSectionTitle('Informations du client'),
            _buildDetailRow('Nom', repair.clientName),
            _buildDetailRow('ID client', repair.clientId),
            const SizedBox(height: 16),
            
            // Informations de l'appareil
            _buildSectionTitle('Informations de l\'appareil'),
            _buildDetailRow('Type d\'appareil', repair.deviceType),
            if (repair.brand.isNotEmpty)
              _buildDetailRow('Marque', repair.brand),
            if (repair.model.isNotEmpty)
              _buildDetailRow('Modèle', repair.model),
            if (repair.serialNumber.isNotEmpty)
              _buildDetailRow('Numéro de série', repair.serialNumber),
            _buildDetailRow('Mot de passe', repair.devicePassword ?? 'Non spécifié'),
            const SizedBox(height: 16),
            
            // Description du problème
            _buildSectionTitle('Description du problème'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(repair.issue),
            ),
            const SizedBox(height: 16),
            
            // Photos (si disponibles)
            if (repair.photos.isNotEmpty) ...[
              _buildSectionTitle('Photos'),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: repair.photos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          repair.photos[index],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Date de création
            _buildDetailRow('Date de création', _formatDate(repair.createdAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fermer'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onEdit();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Modifier'),
        ),
      ],
    );
  }

  /// Construire un titre de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// Construire une ligne de détail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formater la date en format lisible
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Obtenir le texte du statut
  String _getStatusText(RepairStatus status) {
    switch (status) {
      case RepairStatus.pending:
        return 'En attente';
      case RepairStatus.waiting_drop:
        return 'En attente de dépôt';
      case RepairStatus.in_progress:
        return 'Réparation en cours';
      case RepairStatus.diagnosed:
        return 'Diagnostiqué';
      case RepairStatus.waiting_for_parts:
        return 'Attente pièces';
      case RepairStatus.completed:
        return 'Terminée';
      case RepairStatus.ready_for_pickup:
        return 'Prêt pour retrait';
      case RepairStatus.picked_up:
        return 'Récupéré';
      case RepairStatus.cancelled:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  /// Obtenir la couleur correspondant au statut
  Color _getStatusColor(RepairStatus status) {
    switch (status) {
      case RepairStatus.pending:
        return Colors.grey;
      case RepairStatus.waiting_drop:
        return Colors.orange;
      case RepairStatus.in_progress:
        return Colors.indigo;
      case RepairStatus.diagnosed:
        return Colors.purple;
      case RepairStatus.waiting_for_parts:
        return Colors.amber;
      case RepairStatus.completed:
        return Colors.green;
      case RepairStatus.ready_for_pickup:
        return Colors.teal;
      case RepairStatus.picked_up:
        return Colors.grey[700]!;
      case RepairStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
