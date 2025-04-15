import 'package:flutter/material.dart';
import '../../../models/repair_model.dart';
import '../../../theme/app_theme.dart';

/// Widget pour afficher une carte de réparation dans la liste
class RepairCard extends StatelessWidget {
  final RepairModel repair;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const RepairCard({
    super.key,
    required this.repair,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône du type d'appareil
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _getDeviceIcon(repair.deviceType),
                  ),
                  const SizedBox(width: 12),
                  // Informations principales
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repair.deviceType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Client: ${repair.clientName}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Problème: ${repair.issue}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bouton d'édition
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                    onPressed: onEdit,
                    tooltip: 'Modifier la réparation',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Informations supplémentaires
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date de création
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(repair.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(repair.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(repair.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

  /// Obtenir l'icône correspondant au type d'appareil
  Widget _getDeviceIcon(String deviceType) {
    IconData iconData;
    
    if (deviceType.toLowerCase().contains('ordinateur') || 
        deviceType.toLowerCase().contains('pc')) {
      iconData = Icons.computer;
    } else if (deviceType.toLowerCase().contains('portable') || 
               deviceType.toLowerCase().contains('laptop')) {
      iconData = Icons.laptop;
    } else if (deviceType.toLowerCase().contains('tablette') || 
               deviceType.toLowerCase().contains('tablet')) {
      iconData = Icons.tablet_android;
    } else if (deviceType.toLowerCase().contains('téléphone') || 
               deviceType.toLowerCase().contains('smartphone') || 
               deviceType.toLowerCase().contains('phone')) {
      iconData = Icons.smartphone;
    } else {
      iconData = Icons.devices;
    }
    
    return Icon(iconData, size: 24, color: AppTheme.primaryColor);
  }

  /// Formater la date en format lisible
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
