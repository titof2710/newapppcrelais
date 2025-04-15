import 'package:flutter/material.dart';
import '../../models/repair_model.dart';
import '../../models/client_model.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

/// Écran de gestion des réparations pour les administrateurs
class RepairsManagementScreen extends StatefulWidget {
  const RepairsManagementScreen({super.key});

  @override
  State<RepairsManagementScreen> createState() => _RepairsManagementScreenState();
}

class _RepairsManagementScreenState extends State<RepairsManagementScreen> {
  // Pour la création de réparation (client)
  ClientModel? selectedClient;
  TextEditingController clientSearchController = TextEditingController();
  bool showNewClientForm = false;
  // Pour mini-formulaire nouveau client
  TextEditingController newClientFirstNameController = TextEditingController();
  TextEditingController newClientLastNameController = TextEditingController();
  TextEditingController newClientEmailController = TextEditingController();
  TextEditingController newClientPhoneController = TextEditingController();
  TextEditingController newClientPasswordController = TextEditingController();
  TextEditingController newClientPasswordConfirmController = TextEditingController();
  // Pour le mot de passe de la machine
  TextEditingController devicePasswordController = TextEditingController();
  final AdminService _adminService = AdminService();
  
  List<RepairModel> _repairs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }
  
  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final repairs = await _adminService.getAllRepairs();
      
      setState(() {
        _repairs = repairs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des réparations: $e')),
      );
    }
  }
  
  List<RepairModel> get _filteredRepairs {
    return _repairs.where((repair) {
      // Appliquer le filtre de recherche
      final matchesSearch = 
          repair.deviceType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          repair.issue.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          repair.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Appliquer le filtre de statut
      final matchesStatus = _filterStatus == 'all' || 
          repair.status.toString().split('.').last == _filterStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des réparations'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRepairs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRepairs.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune réparation trouvée',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredRepairs.length,
                        itemBuilder: (context, index) {
                          final repair = _filteredRepairs[index];
                          return _buildRepairCard(repair);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRepairDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une réparation...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('En attente', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('En cours', 'in_progress'),
                const SizedBox(width: 8),
                _buildFilterChip('Terminé', 'completed'),
                const SizedBox(width: 8),
                _buildFilterChip('Annulé', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
  
  Widget _buildRepairCard(RepairModel repair) {
    Color statusColor;
    String statusText;
    
    switch (repair.status) {
      case RepairStatus.waiting_drop:
        statusColor = Colors.orange;
        statusText = 'En attente de dépôt';
        break;
      case RepairStatus.pending:
        statusColor = Colors.blue;
        statusText = 'En attente';
        break;
      case RepairStatus.in_progress:
        statusColor = Colors.purple;
        statusText = 'En cours';
        break;
      case RepairStatus.diagnosed:
        statusColor = Colors.amber;
        statusText = 'Diagnostiqué';
        break;
      case RepairStatus.waiting_for_parts:
        statusColor = Colors.deepOrange;
        statusText = 'Attente pièces';
        break;
      case RepairStatus.completed:
        statusColor = Colors.green;
        statusText = 'Terminé';
        break;
      case RepairStatus.ready_for_pickup:
        statusColor = Colors.teal;
        statusText = 'Prêt pour retrait';
        break;
      case RepairStatus.picked_up:
        statusColor = Colors.indigo;
        statusText = 'Récupéré';
        break;
      case RepairStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Annulé';
        break;
      default:
        statusColor = Colors.grey;
        statusText = repair.status.toString().split('.').last;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getDeviceIcon(repair.deviceType),
            color: Colors.white,
          ),
        ),
        title: Text(repair.deviceType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${repair.clientName}'),
            Text('Créé le: ${_formatDate(repair.createdAt)}'),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _showEditRepairDialog(context, repair);
              },
            ),
            IconButton(
              icon: const Icon(Icons.info, color: Colors.green),
              onPressed: () {
                _showRepairDetailsDialog(context, repair);
              },
            ),
          ],
        ),
        onTap: () {
          _showRepairDetailsDialog(context, repair);
        },
      ),
    );
  }
  
  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'laptop':
      case 'ordinateur portable':
        return Icons.laptop;
      case 'desktop':
      case 'ordinateur de bureau':
        return Icons.desktop_windows;
      case 'tablet':
      case 'tablette':
        return Icons.tablet_android;
      case 'phone':
      case 'téléphone':
      case 'smartphone':
        return Icons.smartphone;
      default:
        return Icons.devices;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  void _showRepairDetailsDialog(BuildContext context, RepairModel repair) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de la réparation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', repair.id),
                _buildDetailRow('Appareil', repair.deviceType),
                _buildDetailRow('Marque', repair.brand),
                _buildDetailRow('Modèle', repair.model),
                _buildDetailRow('Problème', repair.issue),
                _buildDetailRow('Client ID', repair.clientId),
                _buildDetailRow('Point Relais ID', repair.pointRelaisId ?? 'Non assigné'),
                _buildDetailRow('Statut', _getStatusText(repair.status.toString().split('.').last)),
                _buildDetailRow('Créé le', _formatDate(repair.createdAt)),
                _buildDetailRow('Prix estimé', '${repair.estimatedPrice ?? "Non défini"} €'),
                _buildDetailRow('Payé', repair.isPaid ? 'Oui' : 'Non'),
                
                const Divider(),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (repair.notes.isNotEmpty)
                  ...repair.notes.map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• ${note.content} (${_formatDate(note.createdAt)})'),
                  ))
                else
                  const Text('Aucune note'),
                
                const Divider(),
                const Text(
                  'Tâches:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (repair.tasks.isNotEmpty)
                  ...repair.tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                          color: task.isCompleted ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${task.title}: ${task.description}'),
                        ),
                      ],
                    ),
                  ))
                else
                  const Text('Aucune tâche'),
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
          ],
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'waiting_drop':
        return 'En attente de dépôt';
      case 'dropped_off':
        return 'Déposé au point relais';
      case 'in_transit':
        return 'En transit vers l\'atelier';
      case 'in_diagnosis':
        return 'Diagnostic en cours';
      case 'waiting_approval':
        return 'En attente d\'approbation';
      case 'in_repair':
        return 'Réparation en cours';
      case 'repaired':
        return 'Réparé';
      case 'ready_for_pickup':
        return 'Prêt pour récupération';
      case 'in_transit_to_relay':
        return 'En transit vers le point relais';
      case 'at_relay':
        return 'Au point relais';
      case 'delivered':
        return 'Livré';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
  
  void _showEditRepairDialog(BuildContext context, RepairModel repair) {
    // Implémenter l'édition de réparation
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier la réparation'),
          content: const Text('Fonctionnalité à implémenter'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
  
  void _showCreateRepairDialog(BuildContext context) {
    // Réinitialiser les variables d'état pour éviter les problèmes de persistance
    setState(() {
      selectedClient = null;
      showNewClientForm = false;
      clientSearchController = TextEditingController();
      newClientFirstNameController.clear();
      newClientLastNameController.clear();
      newClientEmailController.clear();
      newClientPhoneController.clear();
      newClientPasswordController.clear();
      newClientPasswordConfirmController.clear();
      devicePasswordController.clear();
    });
    
    // Contrôleurs pour le formulaire de réparation
    final TextEditingController deviceTypeController = TextEditingController();
    final TextEditingController brandController = TextEditingController();
    final TextEditingController modelController = TextEditingController();
    final TextEditingController serialNumberController = TextEditingController();
    final TextEditingController issueController = TextEditingController();
    
    // Options pour l'état visuel de l'appareil
    final List<String> visualStateOptions = [
      'Rayures',
      'Écran cassé',
      'Touches manquantes',
      'Coque abîmée',
      'Charnière cassée',
      'Autre',
    ];
    final Set<String> selectedVisualStates = {};
    final TextEditingController customVisualStateController = TextEditingController();
    final TextEditingController accessoriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Créer une nouvelle réparation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Section de sélection du client
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
                        '1. Sélection du client',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      // Onglets pour choisir entre client existant et nouveau client
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !showNewClientForm ? AppTheme.primaryColor : Colors.grey[300],
                                foregroundColor: !showNewClientForm ? Colors.white : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  showNewClientForm = false;
                                });
                              },
                              child: const Text('Client existant'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: showNewClientForm ? AppTheme.primaryColor : Colors.grey[300],
                                foregroundColor: showNewClientForm ? Colors.white : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  showNewClientForm = true;
                                  selectedClient = null;
                                });
                              },
                              child: const Text('Nouveau client'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Formulaire selon l'option sélectionnée
                      if (!showNewClientForm)
                        FutureBuilder<List<UserModel>>(
                          future: _adminService.getAllUsers(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final clients = snapshot.data!.where((u) => u.userType == 'client').cast<ClientModel>().toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rechercher un client existant:'),
                                const SizedBox(height: 8),
                                Autocomplete<ClientModel>(
                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text == '') {
                                      return clients; // Afficher tous les clients si le champ est vide
                                    }
                                    return clients.where((ClientModel c) =>
                                      c.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                      c.email.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                      c.phoneNumber.toLowerCase().contains(textEditingValue.text.toLowerCase())
                                    );
                                  },
                                  displayStringForOption: (ClientModel c) => "${c.name} (${c.email})",
                                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                    clientSearchController = controller;
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        labelText: 'Nom, email ou téléphone',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon: controller.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                controller.clear();
                                                setState(() {
                                                  selectedClient = null;
                                                });
                                              },
                                            )
                                          : null,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    );
                                  },
                                  onSelected: (ClientModel selection) {
                                    setState(() {
                                      selectedClient = selection;
                                      print('Client sélectionné: ${selection.name}');
                                    });
                                  },
                                ),
                                if (selectedClient != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.green[300]!),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Client sélectionné: ${selectedClient!.name}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text('Email: ${selectedClient!.email}'),
                                              Text('Téléphone: ${selectedClient!.phoneNumber}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (selectedClient == null && clientSearchController.text.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.orange[300]!),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning, color: Colors.orange),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text('Client non trouvé. Voulez-vous créer un nouveau client?'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              showNewClientForm = true;
                                              // Pré-remplir le nom si possible
                                              String fullName = clientSearchController.text.split(' (').first.trim();
                                              List<String> nameParts = fullName.split(' ');
                                              if (nameParts.length > 1) {
                                                newClientFirstNameController.text = nameParts[0];
                                                newClientLastNameController.text = nameParts.sublist(1).join(' ');
                                              } else {
                                                newClientFirstNameController.text = fullName;
                                              }
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Créer un client'),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      else
                        // Formulaire de création de nouveau client
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Informations du nouveau client:'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: newClientFirstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Prénom *',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: newClientLastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nom *',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: newClientEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: newClientPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: newClientPasswordController,
                                    decoration: const InputDecoration(
                                      labelText: 'Mot de passe *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.lock),
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: newClientPasswordConfirmController,
                                    decoration: const InputDecoration(
                                      labelText: 'Confirmer *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.lock_outline),
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '* Champs obligatoires',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                      ],
                    );
                  },
                );
                // Section des informations de l'appareil
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
                        '2. Informations de l\'appareil',
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
                      
                      // Marque et modèle sur la même ligne
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
              onPressed: () async {
                // Afficher un indicateur de chargement pendant la validation
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
                            Text('Validation en cours...'),
                          ],
                        ),
                      ),
                    );
                  },
                );
                
                // Attendre un court instant pour que le dialogue s'affiche
                await Future.delayed(const Duration(milliseconds: 300));
                
                try {
                  // 1. Validation du client
                  String? clientId;
                  String? clientName;
                  
                  if (selectedClient != null) {
                    // Client existant sélectionné
                    clientId = selectedClient!.id;
                    clientName = selectedClient!.name;
                    print('Client existant validé: $clientName');
                  } else if (showNewClientForm) {
                    // Vérification des champs du nouveau client
                    if (newClientFirstNameController.text.isEmpty ||
                        newClientLastNameController.text.isEmpty ||
                        newClientEmailController.text.isEmpty ||
                        newClientPhoneController.text.isEmpty ||
                        newClientPasswordController.text.isEmpty) {
                      // Fermer le dialogue de chargement
                      Navigator.of(context).pop();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir tous les champs du nouveau client'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Vérifier que les mots de passe correspondent
                    if (newClientPasswordController.text != newClientPasswordConfirmController.text) {
                      // Fermer le dialogue de chargement
                      Navigator.of(context).pop();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Les mots de passe ne correspondent pas'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Création du nouveau client
                    print('Création d\'un nouveau client');
                  } else if (clientSearchController.text.isNotEmpty) {
                    // Texte saisi mais pas de client sélectionné
                    // Fermer le dialogue de chargement
                    Navigator.of(context).pop();
                    
                    setState(() {
                      showNewClientForm = true;
                      // Pré-remplir le nom si possible
                      String fullName = clientSearchController.text.split(' (').first.trim();
                      List<String> nameParts = fullName.split(' ');
                      if (nameParts.length > 1) {
                        newClientFirstNameController.text = nameParts[0];
                        newClientLastNameController.text = nameParts.sublist(1).join(' ');
                      } else {
                        newClientFirstNameController.text = fullName;
                      }
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Client non trouvé. Veuillez compléter les informations du nouveau client.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  } else {
                    // Aucun client spécifié
                    Navigator.of(context).pop(); // Fermer le dialogue de chargement
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez sélectionner un client ou créer un nouveau client'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // 2. Validation des informations de l'appareil
                  if (deviceTypeController.text.isEmpty) {
                    Navigator.of(context).pop(); // Fermer le dialogue de chargement
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez spécifier le type d\'appareil'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if (issueController.text.isEmpty) {
                    Navigator.of(context).pop(); // Fermer le dialogue de chargement
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez décrire le problème rencontré'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // 3. Création de la réparation
                  try {
                    // Création du client si nécessaire
                    if (showNewClientForm) {
                      // Création d'un nouveau client
                      final newClient = await _adminService.createClient(
                        name: "${newClientFirstNameController.text.trim()} ${newClientLastNameController.text.trim()}",
                        email: newClientEmailController.text.trim(),
                        phoneNumber: newClientPhoneController.text.trim(),
                        password: newClientPasswordController.text.trim(),
                      );
                      clientId = newClient.id;
                      clientName = newClient.name;
                      print('Nouveau client créé: $clientName (ID: $clientId)');
                    } else {
                      // Utilisation du client existant sélectionné
                      clientId = selectedClient!.id;
                      clientName = selectedClient!.name;
                    }
                    
                    // Création de la réparation
                    final RepairModel newRepair = RepairModel(
                      id: '',
                      clientId: clientId!,
                      clientName: clientName!,
                      deviceType: deviceTypeController.text.trim(),
                      brand: brandController.text.trim(),
                      model: modelController.text.trim(),
                      serialNumber: serialNumberController.text.trim(),
                      issue: issueController.text.trim(),
                      devicePassword: devicePasswordController.text.trim().isEmpty ? 'aucun' : devicePasswordController.text.trim(),
                      photos: [],
                      status: RepairStatus.waiting_drop,
                      createdAt: DateTime.now(),
                    );
                    
                    print('Création de la réparation pour $clientName: ${newRepair.deviceType}');
                    await _adminService.createRepair(newRepair);
                    
                    // Fermer le dialogue de chargement
                    Navigator.of(context).pop();
                    
                    // Fermer le formulaire
                    Navigator.of(context).pop();
                    
                    // Afficher un message de succès
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Réparation créée avec succès pour $clientName'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Recharger la liste des réparations
                    _loadRepairs();
                  } catch (e) {
                    // Fermer le dialogue de chargement
                    Navigator.of(context).pop();
                    
                    print('Erreur lors de la création: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la création de la réparation: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  // Fermer le dialogue de chargement en cas d'erreur générale
                  Navigator.of(context).pop();
                  
                  print('Erreur générale: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Une erreur est survenue: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Créer la réparation'),
            ),
          ],
        );
      },
    );
  }
}
