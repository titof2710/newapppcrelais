import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/repair_service.dart';
import '../../models/repair_model.dart';
import '../../models/user_model.dart';
import '../../models/point_relais_model.dart';
import '../../theme/app_theme.dart';

class RelayRepairsScreen extends StatefulWidget {
  const RelayRepairsScreen({super.key});

  @override
  State<RelayRepairsScreen> createState() => _RelayRepairsScreenState();
}

class _RelayRepairsScreenState extends State<RelayRepairsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RepairService _repairService;
  late AuthService _authService;
  
  bool _isLoading = true;
  List<RepairModel> _pendingRepairs = [];
  List<RepairModel> _inProgressRepairs = [];
  List<RepairModel> _completedRepairs = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _repairService = Provider.of<RepairService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadRepairs();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await _authService.getCurrentUserData();
      
      if (user is PointRelaisModel) {
        // Charger les réparations associées à ce point relais
        final repairs = await _repairService.getRepairsForPointRelais(user.uuid);
        
        // Trier les réparations par statut
        _pendingRepairs = repairs.where((repair) => 
          repair.status == 'pending' || repair.status == 'waiting_drop').toList();
        
        _inProgressRepairs = repairs.where((repair) => 
          repair.status == 'in_progress' || repair.status == 'diagnosed').toList();
        
        _completedRepairs = repairs.where((repair) => 
          repair.status == 'completed' || repair.status == 'ready_for_pickup' || 
          repair.status == 'picked_up' || repair.status == 'cancelled').toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des réparations: $e'),
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
        title: const Text('Réparations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRepairs,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRepairList(_pendingRepairs, 'en attente'),
                  _buildRepairList(_inProgressRepairs, 'en cours'),
                  _buildRepairList(_completedRepairs, 'terminées'),
                ],
              ),
            ),
    );
  }
  
  Widget _buildRepairList(List<RepairModel> repairs, String status) {
    if (repairs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.engineering_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune réparation $status',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: repairs.length,
      itemBuilder: (context, index) {
        final repair = repairs[index];
        return _buildRepairCard(repair);
      },
    );
  }
  
  Widget _buildRepairCard(RepairModel repair) {
    // Déterminer la couleur et l'icône en fonction du statut
    IconData statusIcon;
    Color statusColor;
    String statusText;
    
    switch (repair.status) {
      case 'pending':
        statusIcon = Icons.schedule;
        statusColor = Colors.orange;
        statusText = 'En attente';
        break;
      case 'waiting_drop':
        statusIcon = Icons.schedule;
        statusColor = Colors.orange;
        statusText = 'Dépôt attendu';
        break;
      case 'in_progress':
        statusIcon = Icons.build;
        statusColor = Colors.blue;
        statusText = 'En réparation';
        break;
      case 'diagnosed':
        statusIcon = Icons.search;
        statusColor = Colors.purple;
        statusText = 'Diagnostiqué';
        break;
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Terminée';
        break;
      case 'ready_for_pickup':
        statusIcon = Icons.inventory;
        statusColor = Colors.green;
        statusText = 'Prêt pour retrait';
        break;
      case 'picked_up':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Récupéré';
        break;
      case 'cancelled':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusText = 'Annulée';
        break;
      default:
        statusIcon = Icons.help_outline;
        statusColor = Colors.grey;
        statusText = 'Inconnu';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Naviguer vers les détails de la réparation
          Navigator.pushNamed(
            context,
            '/point_relais/repairs/details',
            arguments: repair.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${repair.deviceType} ${repair.brand} ${repair.model}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Client: ${repair.clientName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Problème: ${repair.issue}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Créé le: ${_formatDate(repair.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (repair.status == 'waiting_drop')
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter la réception de l'appareil
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('RÉCEPTIONNER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              if (repair.status == 'ready_for_pickup')
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter la remise au client
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('REMETTRE AU CLIENT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
