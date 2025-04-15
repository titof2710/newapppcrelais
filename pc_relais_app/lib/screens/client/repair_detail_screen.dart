import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/repair_model.dart';
import '../../services/repair_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class RepairDetailScreen extends StatefulWidget {
  final String repairId;
  final bool isPointRelais;
  final bool isTechnicien;

  const RepairDetailScreen({
    super.key,
    required this.repairId,
    this.isPointRelais = false,
    this.isTechnicien = false,
  });

  @override
  State<RepairDetailScreen> createState() => _RepairDetailScreenState();
}

class _RepairDetailScreenState extends State<RepairDetailScreen> {
  late final RepairService _repairService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repairService = Provider.of<RepairService>(context, listen: false);
  }

  Future<void> _updateRepairStatus(RepairStatus newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _repairService.updateRepairStatus(widget.repairId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du statut: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la réparation'),
        backgroundColor: widget.isPointRelais 
          ? AppTheme.secondaryColor 
          : widget.isTechnicien 
            ? AppTheme.technicienTheme.primaryColor 
            : AppTheme.primaryColor,
      ),
      body: StreamBuilder<RepairModel>(
        stream: _repairService.getRepairStream(widget.repairId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final repair = snapshot.data;
          if (repair == null) {
            return const Center(
              child: Text('Réparation introuvable'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte d'information principale
                _buildMainInfoCard(repair),
                const SizedBox(height: 24),

                // Progression de la réparation
                _buildRepairProgressSection(repair),
                const SizedBox(height: 24),

                // Détails de l'appareil
                _buildDeviceDetailsSection(repair),
                const SizedBox(height: 24),

                // Tâches de réparation
                if (repair.tasks.isNotEmpty) ...[
                  _buildRepairTasksSection(repair),
                  const SizedBox(height: 24),
                ],

                // Notes et commentaires
                if (repair.notes.isNotEmpty) ...[
                  _buildNotesSection(repair),
                  const SizedBox(height: 24),
                ],

                // Actions disponibles
                _buildActionsSection(repair),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainInfoCard(RepairModel repair) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final createdAtFormatted = dateFormat.format(repair.createdAt);
    final estimatedDateFormatted = repair.estimatedCompletionDate != null
        ? dateFormat.format(repair.estimatedCompletionDate!)
        : 'À déterminer';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réparation #${repair.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusBadge(status: repair.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Appareil', '${repair.deviceType} ${repair.brand} ${repair.model}'),
            _buildInfoRow('Date de création', createdAtFormatted),
            _buildInfoRow('Date estimée de fin', estimatedDateFormatted),
            if (repair.estimatedPrice != null)
              _buildInfoRow(
                'Prix estimé',
                '${repair.estimatedPrice!.toStringAsFixed(2)} €',
              ),
            _buildInfoRow(
              'Paiement',
              repair.isPaid ? 'Payé' : 'En attente de paiement',
              valueColor: repair.isPaid ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairProgressSection(RepairModel repair) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progression de la réparation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressIndicator(repair.status),
      ],
    );
  }

  Widget _buildProgressIndicator(RepairStatus status) {
    final int currentStep = _getStepFromStatus(status);
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: currentStep / 7,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(_getColorForStatus(status)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProgressStep('Dépôt', 1, currentStep),
            _buildProgressStep('Diagnostic', 2, currentStep),
            _buildProgressStep('Réparation', 4, currentStep),
            _buildProgressStep('Récupération', 7, currentStep),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressStep(String label, int step, int currentStep) {
    final bool isCompleted = currentStep >= step;
    final bool isCurrent = currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? _getColorForStep(step) : Colors.grey.shade300,
            border: isCurrent
                ? Border.all(color: _getColorForStep(step), width: 2)
                : null,
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? _getColorForStep(step) : AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  int _getStepFromStatus(RepairStatus status) {
    switch (status) {
      case RepairStatus.pending:
        return 0;
      case RepairStatus.waiting_drop:
        return 1;
      case RepairStatus.diagnosed:
        return 2;
      case RepairStatus.waiting_for_parts:
        return 3;
      case RepairStatus.in_progress:
        return 4;
      case RepairStatus.completed:
        return 5;
      case RepairStatus.ready_for_pickup:
        return 6;
      case RepairStatus.picked_up:
        return 7;
      case RepairStatus.cancelled:
        return 0;
      default:
        return 0;
    }
  }

  Color _getColorForStatus(RepairStatus status) {
    switch (status) {
      case RepairStatus.pending:
      case RepairStatus.waiting_drop:
        return Colors.blue;
      case RepairStatus.diagnosed:
      case RepairStatus.waiting_for_parts:
        return Colors.orange;
      case RepairStatus.in_progress:
        return Colors.teal;
      case RepairStatus.ready_for_pickup:
      case RepairStatus.completed:
      case RepairStatus.picked_up:
        return Colors.green;
      case RepairStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getColorForStep(int step) {
    switch (step) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 4:
        return Colors.teal;
      case 7:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDeviceDetailsSection(RepairModel repair) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails de l\'appareil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeviceInfoRow('Type d\'appareil', repair.deviceType),
                _buildDeviceInfoRow('Marque', repair.brand),
                _buildDeviceInfoRow('Modèle', repair.model),
                _buildDeviceInfoRow('Numéro de série', repair.serialNumber),
                const Divider(),
                const Text(
                  'Problème signalé',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(repair.issue),
                if (repair.photos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: repair.photos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              repair.photos[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairTasksSection(RepairModel repair) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tâches de réparation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: repair.tasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: task.isCompleted ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                            if (task.price != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${task.price!.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(RepairModel repair) {
    // Filtrer les notes en fonction du type d'utilisateur
    final notes = widget.isPointRelais
        ? repair.notes
        : repair.notes.where((note) => !note.isPrivate).toList();

    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes et commentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: notes.map((note) {
                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                final dateFormatted = dateFormat.format(note.createdAt);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            note.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dateFormatted,
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(note.content),
                      if (note.isPrivate) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Note interne',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(RepairModel repair) {
    // Actions différentes selon le type d'utilisateur et le statut de la réparation
    if (widget.isPointRelais) {
      return _buildPointRelaisActions(repair);
    } else if (widget.isTechnicien) {
      return _buildTechnicienActions(repair);
    } else {
      return _buildClientActions(repair);
    }
  }

  Widget _buildClientActions(RepairModel repair) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'CONTACTER LE TECHNICIEN',
                icon: Icons.chat,
                onPressed: () {
                  // TODO: Naviguer vers l'écran de chat
                  context.push('/client/chat/1');
                },
                type: ButtonType.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (repair.status == RepairStatus.diagnosed) ...[
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'APPROUVER LE DEVIS',
                  icon: Icons.check_circle,
                  onPressed: () {
                    _updateRepairStatus(RepairStatus.in_progress);
                  },
                  type: ButtonType.secondary,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (repair.status == RepairStatus.ready_for_pickup && !repair.isPaid) ...[
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'PAYER MAINTENANT',
                  icon: Icons.payment,
                  onPressed: () {
                    // TODO: Naviguer vers l'écran de paiement
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité de paiement à venir'),
                      ),
                    );
                  },
                  type: ButtonType.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'ANNULER LA RÉPARATION',
                icon: Icons.cancel,
                onPressed: () {
                  // Demander confirmation avant d'annuler
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Annuler la réparation'),
                      content: const Text(
                        'Êtes-vous sûr de vouloir annuler cette réparation ? Cette action est irréversible.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('NON'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateRepairStatus(RepairStatus.cancelled);
                          },
                          child: const Text('OUI'),
                        ),
                      ],
                    ),
                  );
                },
                type: ButtonType.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicienActions(RepairModel repair) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'METTRE À JOUR LE STATUT',
                icon: Icons.update,
                onPressed: () {
                  // Afficher un dialogue pour choisir le nouveau statut
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Mettre à jour le statut'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('En cours de diagnostic'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateRepairStatus(RepairStatus.diagnosed);
                            },
                          ),
                          ListTile(
                            title: const Text('En attente de pièces'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateRepairStatus(RepairStatus.waiting_for_parts);
                            },
                          ),
                          ListTile(
                            title: const Text('En cours de réparation'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateRepairStatus(RepairStatus.in_progress);
                            },
                          ),
                          ListTile(
                            title: const Text('Réparation terminée'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateRepairStatus(RepairStatus.completed);
                            },
                          ),
                          ListTile(
                            title: const Text('Prêt pour récupération'),
                            onTap: () {
                              Navigator.pop(context);
                              _updateRepairStatus(RepairStatus.ready_for_pickup);
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ANNULER'),
                        ),
                      ],
                    ),
                  );
                },
                type: ButtonType.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'AJOUTER UNE NOTE',
                icon: Icons.note_add,
                onPressed: () {
                  // TODO: Naviguer vers l'écran d'ajout de note
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité à venir'),
                    ),
                  );
                },
                type: ButtonType.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPointRelaisActions(RepairModel repair) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'CONTACTER L\'ATELIER',
                icon: Icons.chat,
                onPressed: () {
                  // TODO: Naviguer vers l'écran de chat
                  context.push('/point_relais/chat/1');
                },
                type: ButtonType.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (repair.status == RepairStatus.waiting_drop) ...[
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'ENREGISTRER LE DÉPÔT',
                  icon: Icons.check_circle,
                  onPressed: () {
                    _updateRepairStatus(RepairStatus.in_progress);
                  },
                  type: ButtonType.secondary,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (repair.status == RepairStatus.ready_for_pickup) ...[
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'REMETTRE AU CLIENT',
                  icon: Icons.handshake,
                  onPressed: () {
                    _updateRepairStatus(RepairStatus.completed);
                  },
                  type: ButtonType.secondary,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'SCANNER LE CODE QR',
                icon: Icons.qr_code_scanner,
                onPressed: () {
                  // TODO: Naviguer vers l'écran de scan
                  context.push('/point_relais/scan');
                },
                type: ButtonType.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
