import 'package:flutter/material.dart';
import '../../models/repair_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/repair_status_badge.dart';

class TechnicienRepairsScreen extends StatefulWidget {
  const TechnicienRepairsScreen({Key? key}) : super(key: key);

  @override
  State<TechnicienRepairsScreen> createState() => _TechnicienRepairsScreenState();
}

class _TechnicienRepairsScreenState extends State<TechnicienRepairsScreen> {
  final AuthService _authService = AuthService();
  List<RepairModel> _repairs = [];
  bool _isLoading = true;
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
      // Simuler le chargement des réparations assignées au technicien
      // À remplacer par un appel API réel
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _repairs = [
          RepairModel(
            id: '1001',
            clientId: 'client1',
            clientName: 'Jean Dupont',
            technicienId: 'tech1',
            deviceType: 'Ordinateur portable',
            brand: 'Dell',
            model: 'XPS 15',
            serialNumber: 'SN12345',
            issue: 'Écran cassé',
            status: RepairStatus.in_progress,
            estimatedPrice: 150.0,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          RepairModel(
            id: '1002',
            clientId: 'client2',
            clientName: 'Jean Dupont',
            technicienId: 'tech1',
            deviceType: 'Smartphone',
            brand: 'Samsung',
            model: 'Galaxy S21',
            serialNumber: 'SN67890',
            issue: 'Batterie défectueuse',
            status: RepairStatus.diagnosed,
            estimatedPrice: 80.0,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          RepairModel(
            id: '1003',
            clientId: 'client3',
            clientName: 'Pierre Martin',
            pointRelaisId: 'point_relais2',
            technicienId: 'tech1',
            deviceType: 'Tablette',
            brand: 'Apple',
            model: 'iPad Pro',
            serialNumber: 'SN54321',
            issue: 'Ne s\'allume plus',
            status: RepairStatus.waiting_for_parts,
            estimatedPrice: 200.0,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          RepairModel(
            id: '1004',
            clientId: 'client4',
            clientName: 'Sophie Dubois',
            pointRelaisId: 'point_relais2',
            technicienId: 'tech1',
            deviceType: 'Ordinateur de bureau',
            brand: 'HP',
            model: 'Pavilion',
            serialNumber: 'SN09876',
            issue: 'Problème de démarrage',
            status: RepairStatus.completed,
            estimatedPrice: 120.0,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ];
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
    if (_filterStatus == 'all') {
      return _repairs;
    }
    return _repairs.where((repair) => repair.status.toString() == 'RepairStatus.$_filterStatus').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réparations'),
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: _filteredRepairs.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune réparation trouvée',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : _buildRepairsList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'écran de création d'une nouvelle réparation
          Navigator.of(context).pushNamed('/technicien/repairs/new');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Text('Filtrer par statut:'),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Tous'),
                  _buildFilterChip('diagnostic', 'Diagnostic'),
                  _buildFilterChip('inProgress', 'En cours'),
                  _buildFilterChip('waitingForParts', 'Attente pièces'),
                  _buildFilterChip('readyForPickup', 'Prêt'),
                  _buildFilterChip('completed', 'Terminé'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filterStatus == value,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _filterStatus = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildRepairsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRepairs.length,
      itemBuilder: (context, index) {
        final repair = _filteredRepairs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Navigation vers le détail de la réparation
              Navigator.of(context).pushNamed(
                '/technicien/repairs/${repair.id}',
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Réparation #${repair.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RepairStatusBadge(status: repair.status.toString().split('.').last),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${repair.brand} ${repair.model}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              repair.deviceType,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Problème:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              repair.issue,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reçu le: ${_formatDate(repair.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (repair.estimatedPrice != null)
                        Text(
                          'Prix estimé: ${repair.estimatedPrice?.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
