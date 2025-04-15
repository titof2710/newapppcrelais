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
  // Services et données
  final AdminService _adminService = AdminService();
  List<RepairModel> _repairs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all';
  
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
  
  // Pour les informations de l'appareil
  TextEditingController deviceTypeController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController issueController = TextEditingController();
  TextEditingController devicePasswordController = TextEditingController();
  
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une réparation...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Filtrer par statut: '),
                const SizedBox(width: 8),
                _buildFilterChip('Tous', 'all'),
                _buildFilterChip('En attente de dépôt', 'waiting_drop'),
                _buildFilterChip('Déposé', 'dropped_off'),
                _buildFilterChip('En diagnostic', 'in_diagnosis'),
                _buildFilterChip('En réparation', 'in_repair'),
                _buildFilterChip('Réparé', 'repaired'),
                _buildFilterChip('Livré', 'delivered'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: _filterStatus == value,
        onSelected: (selected) {
          setState(() {
            _filterStatus = selected ? value : 'all';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }
  
  // Méthode pour afficher le dialogue de création de réparation
  void _showCreateRepairDialog(BuildContext context) {
    // Réinitialiser les variables d'état
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
      deviceTypeController.clear();
      brandController.clear();
      modelController.clear();
      serialNumberController.clear();
      issueController.clear();
      devicePasswordController.clear();
    });
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Créer une nouvelle réparation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Section client (simplifiée pour l'exemple)
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
                      // Champ simplifié pour l'exemple
                      TextField(
                        controller: clientSearchController,
                        decoration: const InputDecoration(
                          labelText: 'Rechercher un client',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Section appareil
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
                      
                      TextField(
                        controller: deviceTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Type d\'appareil *',
                          hintText: 'Ex: Ordinateur portable, Smartphone',
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: issueController,
                        decoration: const InputDecoration(
                          labelText: 'Description du problème *',
                          hintText: 'Décrivez le problème rencontré avec l\'appareil',
                        ),
                        maxLines: 3,
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
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Logique simplifiée pour l'exemple
                if (deviceTypeController.text.isEmpty || issueController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // Création de la réparation (simplifiée)
                try {
                  final RepairModel newRepair = RepairModel(
                    id: '',
                    clientId: 'client_test',
                    clientName: 'Client Test',
                    deviceType: deviceTypeController.text.trim(),
                    brand: brandController.text.trim(),
                    model: modelController.text.trim(),
                    serialNumber: serialNumberController.text.trim(),
                    issue: issueController.text.trim(),
                    devicePassword: devicePasswordController.text.trim(),
                    photos: [],
                    status: RepairStatus.waiting_drop,
                    createdAt: DateTime.now(),
                  );
                  
                  await _adminService.createRepair(newRepair);
                  
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Réparation créée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  _loadRepairs();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la création: $e'),
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
  
  Widget _buildRepairCard(RepairModel repair) {
    // Implémentation simplifiée
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(repair.deviceType),
        subtitle: Text(repair.issue),
        trailing: Text(repair.status.toString()),
        onTap: () {
          // Afficher les détails
        },
      ),
    );
  }
}
