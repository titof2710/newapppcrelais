import 'package:flutter/material.dart';
import '../../models/repair_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/repair_card.dart';
import 'widgets/repair_details_dialog.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/create_repair_dialog.dart';
import 'widgets/edit_repair_dialog.dart';

/// Écran de gestion des réparations pour les administrateurs
class RepairsManagementScreen extends StatefulWidget {
  const RepairsManagementScreen({super.key});

  @override
  State<RepairsManagementScreen> createState() => _RepairsManagementScreenState();
}

class _RepairsManagementScreenState extends State<RepairsManagementScreen> {
  // Service d'administration
  final AdminService _adminService = AdminService();
  
  // Données et filtres
  List<RepairModel> _repairs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }
  
  /// Charger la liste des réparations
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des réparations: $e')),
        );
      }
    }
  }
  
  /// Filtrer les réparations selon les critères de recherche et de statut
  List<RepairModel> get _filteredRepairs {
    return _repairs.where((repair) {
      // Appliquer le filtre de recherche
      final matchesSearch = 
          repair.deviceType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          repair.issue.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          repair.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
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
            tooltip: 'Actualiser la liste',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          SearchFilterBar(
            searchQuery: _searchQuery,
            filterStatus: _filterStatus,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onFilterChanged: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
          ),
          
          // Liste des réparations
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
                          return RepairCard(
                            repair: repair,
                            onTap: () => _showRepairDetailsDialog(repair),
                            onEdit: () => _showEditRepairDialog(repair),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRepairDialog,
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Créer une réparation',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  /// Afficher le dialogue de détails d'une réparation
  void _showRepairDetailsDialog(RepairModel repair) {
    showDialog(
      context: context,
      builder: (context) {
        return RepairDetailsDialog(
          repair: repair,
          onEdit: () {
            Navigator.of(context).pop();
            _showEditRepairDialog(repair);
          },
        );
      },
    );
  }
  
  /// Afficher le dialogue de modification d'une réparation
  void _showEditRepairDialog(RepairModel repair) {
    showDialog(
      context: context,
      builder: (context) {
        return EditRepairDialog(
          repair: repair,
          adminService: _adminService,
          onRepairUpdated: _loadRepairs,
        );
      },
    );
  }
  
  /// Afficher le dialogue de création d'une réparation
  void _showCreateRepairDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreateRepairDialog(
          adminService: _adminService,
          onRepairCreated: _loadRepairs,
        );
      },
    );
  }
}
