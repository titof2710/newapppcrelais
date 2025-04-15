import 'package:flutter/material.dart';
import '../../../models/repair_model.dart';
import '../../../services/admin_service.dart';
import '../../../theme/app_theme.dart';

/// Dialogue pour modifier une réparation existante
class EditRepairDialog extends StatefulWidget {
  final RepairModel repair;
  final AdminService adminService;
  final Function onRepairUpdated;

  const EditRepairDialog({
    super.key,
    required this.repair,
    required this.adminService,
    required this.onRepairUpdated,
  });

  @override
  State<EditRepairDialog> createState() => _EditRepairDialogState();
}

class _EditRepairDialogState extends State<EditRepairDialog> {
  late TextEditingController deviceTypeController;
  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController serialNumberController;
  late TextEditingController issueController;
  late TextEditingController devicePasswordController;
  late RepairStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs existantes
    deviceTypeController = TextEditingController(text: widget.repair.deviceType);
    brandController = TextEditingController(text: widget.repair.brand);
    modelController = TextEditingController(text: widget.repair.model);
    serialNumberController = TextEditingController(text: widget.repair.serialNumber);
    issueController = TextEditingController(text: widget.repair.issue);
    devicePasswordController = TextEditingController(text: widget.repair.devicePassword);
    selectedStatus = widget.repair.status;
  }

  @override
  void dispose() {
    // Libérer les ressources
    deviceTypeController.dispose();
    brandController.dispose();
    modelController.dispose();
    serialNumberController.dispose();
    issueController.dispose();
    devicePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la réparation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du client (non modifiables)
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations du client',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('Client: ${widget.repair.clientName}'),
                  Text('ID client: ${widget.repair.clientId}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Statut de la réparation
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut de la réparation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RepairStatus>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: RepairStatus.values.map((status) {
                      return DropdownMenuItem<RepairStatus>(
                        value: status,
                        child: Text(_getStatusText(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Informations de l'appareil
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations de l\'appareil',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  // Type d'appareil (obligatoire)
                  TextField(
                    controller: deviceTypeController,
                    decoration: InputDecoration(
                      labelText: 'Type d\'appareil *',
                      hintText: 'Ex: Ordinateur portable, Smartphone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.devices),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Marque et modèle
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: brandController,
                          decoration: InputDecoration(
                            labelText: 'Marque',
                            hintText: 'Ex: Dell, Apple',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: modelController,
                          decoration: InputDecoration(
                            labelText: 'Modèle',
                            hintText: 'Ex: XPS 15, MacBook Pro',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Numéro de série
                  TextField(
                    controller: serialNumberController,
                    decoration: InputDecoration(
                      labelText: 'Numéro de série',
                      hintText: 'Numéro de série de l\'appareil',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description du problème (obligatoire)
                  TextField(
                    controller: issueController,
                    decoration: InputDecoration(
                      labelText: 'Description du problème *',
                      hintText: 'Décrivez le problème rencontré avec l\'appareil',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.error_outline),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  
                  // Mot de passe de la machine
                  TextField(
                    controller: devicePasswordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe de la machine',
                      hintText: 'Laisser vide si aucun',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '* Champs obligatoires',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _handleUpdateRepair,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Enregistrer les modifications'),
        ),
      ],
    );
  }

  /// Gérer la mise à jour de la réparation
  void _handleUpdateRepair() async {
    // Vérifier les champs obligatoires
    if (deviceTypeController.text.isEmpty || issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Mise à jour en cours...'),
              ],
            ),
          ),
        );
      },
    );
    
    try {
      // Créer une nouvelle instance avec les valeurs mises à jour
      final updatedRepair = RepairModel(
        id: widget.repair.id,
        clientId: widget.repair.clientId,
        clientName: widget.repair.clientName,
        deviceType: deviceTypeController.text.trim(),
        brand: brandController.text.trim(),
        model: modelController.text.trim(),
        serialNumber: serialNumberController.text.trim(),
        issue: issueController.text.trim(),
        devicePassword: devicePasswordController.text.trim(),
        photos: widget.repair.photos,
        status: selectedStatus,
        createdAt: widget.repair.createdAt,
      );
      
      // Mettre à jour la réparation
      await widget.adminService.updateRepair(updatedRepair);
      
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();
      
      // Fermer le formulaire
      Navigator.of(context).pop();
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réparation mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Appeler la fonction de callback
      widget.onRepairUpdated();
      
    } catch (e) {
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
}
