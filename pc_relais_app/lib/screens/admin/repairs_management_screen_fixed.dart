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
      case RepairStatus.dropped_off:
        statusColor = Colors.blue;
        statusText = 'Déposé';
        break;
      case RepairStatus.in_diagnosis:
        statusColor = Colors.purple;
        statusText = 'En diagnostic';
        break;
      case RepairStatus.in_repair:
        statusColor = Colors.amber;
        statusText = 'En réparation';
        break;
      case RepairStatus.repaired:
        statusColor = Colors.green;
        statusText = 'Réparé';
        break;
      case RepairStatus.delivered:
        statusColor = Colors.teal;
        statusText = 'Livré';
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
    final TextEditingController clientIdController = TextEditingController();
    final TextEditingController deviceTypeController = TextEditingController();
    final TextEditingController brandController = TextEditingController();
    final TextEditingController modelController = TextEditingController();
    final TextEditingController serialNumberController = TextEditingController();
    final TextEditingController issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Créer une nouvelle réparation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Champ de sélection/recherche de client
                FutureBuilder<List<UserModel>>(
                  future: _adminService.getAllUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final clients = snapshot.data!.where((u) => u.userType == 'client').cast<ClientModel>().toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Autocomplete<ClientModel>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<ClientModel>.empty();
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
                              decoration: const InputDecoration(
                                labelText: 'Client',
                                hintText: 'Nom, prénom, email ou téléphone',
                              ),
                            );
                          },
                          onSelected: (ClientModel selection) {
                            setState(() {
                              selectedClient = selection;
                              showNewClientForm = false;
                            });
                          },
                        ),
                        const SizedBox(height: 4),
                        if (selectedClient == null && clientSearchController.text.isNotEmpty && !showNewClientForm)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showNewClientForm = true;
                              });
                            },
                            child: const Text('Créer un nouveau client'),
                          ),
                        if (showNewClientForm)
                          Column(
                            children: [
                              TextField(
                                controller: newClientFirstNameController,
                                decoration: const InputDecoration(labelText: 'Prénom'),
                              ),
                              TextField(
                                controller: newClientLastNameController,
                                decoration: const InputDecoration(labelText: 'Nom'),
                              ),
                              TextField(
                                controller: newClientEmailController,
                                decoration: const InputDecoration(labelText: 'Email'),
                              ),
                              TextField(
                                controller: newClientPhoneController,
                                decoration: const InputDecoration(labelText: 'Téléphone'),
                              ),
                              TextField(
                                controller: newClientPasswordController,
                                decoration: const InputDecoration(labelText: 'Mot de passe'),
                                obscureText: true,
                              ),
                              TextField(
                                controller: newClientPasswordConfirmController,
                                decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                                obscureText: true,
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: deviceTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Type d\'appareil',
                    hintText: 'Ex: Ordinateur portable, Smartphone',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(
                    labelText: 'Marque (facultatif)',
                    hintText: 'Ex: Dell, Apple, Samsung',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Modèle (facultatif)',
                    hintText: 'Ex: XPS 15, MacBook Pro, Galaxy S20',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: serialNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de série (facultatif)',
                    hintText: 'Numéro de série de l\'appareil',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: issueController,
                  decoration: const InputDecoration(
                    labelText: 'Problème',
                    hintText: 'Description du problème',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: devicePasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe de la machine (facultatif)',
                    hintText: 'Laisser vide si aucun',
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if ((selectedClient == null && !showNewClientForm) ||
                    deviceTypeController.text.isEmpty ||
                    issueController.text.isEmpty ||
                    (showNewClientForm && (newClientFirstNameController.text.isEmpty || newClientLastNameController.text.isEmpty || newClientEmailController.text.isEmpty || newClientPhoneController.text.isEmpty))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                  );
                  return;
                }
                try {
                  String clientId;
                  String clientName;
                  if (showNewClientForm) {
                    final newClient = await _adminService.createClient(
                      name: "${newClientFirstNameController.text.trim()} ${newClientLastNameController.text.trim()}",
                      email: newClientEmailController.text.trim(),
                      phoneNumber: newClientPhoneController.text.trim(),
                      password: newClientPasswordController.text.trim(),
                    );
                    clientId = newClient.id;
                    clientName = "${newClient.name}";
                  } else if (selectedClient != null) {
                    clientId = selectedClient!.id;
                    clientName = selectedClient!.name;
                  } else {
                    throw Exception('Aucun client sélectionné');
                  }
                  final RepairModel newRepair = RepairModel(
                    id: '',
                    clientId: clientId,
                    clientName: clientName,
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
                  await _adminService.createRepair(newRepair);
                  Navigator.of(context).pop();
                  _loadRepairs();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la création de la réparation: $e')),
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }
}
