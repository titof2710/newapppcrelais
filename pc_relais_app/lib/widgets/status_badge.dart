import 'package:flutter/material.dart';
import '../models/repair_model.dart';

class StatusBadge extends StatelessWidget {
  final RepairStatus status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 12,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case RepairStatus.pending:
        return Colors.orange;
      case RepairStatus.waiting_drop:
        return Colors.orange.shade700;
      case RepairStatus.diagnosed:
        return Colors.indigo;
      case RepairStatus.waiting_for_parts:
        return Colors.amber;
      case RepairStatus.in_progress:
        return Colors.teal;
      case RepairStatus.completed:
        return Colors.green;
      case RepairStatus.ready_for_pickup:
        return Colors.green.shade700;
      case RepairStatus.picked_up:
        return Colors.green.shade900;
      case RepairStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case RepairStatus.pending:
        return 'En attente';
      case RepairStatus.waiting_drop:
        return 'En attente de dépôt';
      case RepairStatus.diagnosed:
        return 'Diagnosticé';
      case RepairStatus.waiting_for_parts:
        return 'Attente pièces';
      case RepairStatus.in_progress:
        return 'Réparation en cours';
      case RepairStatus.completed:
        return 'Terminé';
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
}
