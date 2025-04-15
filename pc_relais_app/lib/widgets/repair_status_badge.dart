import 'package:flutter/material.dart';

class RepairStatusBadge extends StatelessWidget {
  final String status;

  const RepairStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer la couleur et le texte en fonction du statut
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'En attente';
        break;
      case 'waiting_drop':
        color = Colors.orange;
        text = 'Dépôt attendu';
        break;
      case 'in_progress':
        color = Colors.blue;
        text = 'En réparation';
        break;
      case 'diagnosed':
        color = Colors.purple;
        text = 'Diagnostiqué';
        break;
      case 'waiting_for_parts':
        color = Colors.amber;
        text = 'Attente pièces';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Terminée';
        break;
      case 'ready_for_pickup':
        color = Colors.green;
        text = 'Prêt pour retrait';
        break;
      case 'picked_up':
        color = Colors.green;
        text = 'Récupéré';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Annulée';
        break;
      default:
        color = Colors.grey;
        text = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
