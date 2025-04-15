import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/repair_service.dart';
import '../../models/repair_model.dart';
import '../../widgets/custom_button.dart';

class StorageManagementScreen extends StatefulWidget {
  const StorageManagementScreen({super.key});

  @override
  State<StorageManagementScreen> createState() => _StorageManagementScreenState();
}

class _StorageManagementScreenState extends State<StorageManagementScreen> {
  late final RepairService _repairService;
  bool _isLoading = true;
  List<RepairModel> _repairs = [];
  
  // Capacité simulée du point relais
  final int _totalCapacity = 20;

  @override
  void initState() {
    super.initState();
    _repairService = Provider.of<RepairService>(context, listen: false);
    _loadRepairs();
  }

  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repairs = await _repairService.getRelayRepairs();
      setState(() {
        _repairs = repairs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des réparations: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculer le nombre d'appareils actuellement stockés
    final int currentlyStored = _repairs.where((repair) => 
      repair.status == RepairStatus.droppedOff || 
      repair.status == RepairStatus.atRelay
    ).length;
    
    // Calculer le pourcentage d'espace utilisé
    final double usagePercentage = currentlyStored / _totalCapacity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du stockage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRepairs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStorageOverview(currentlyStored, usagePercentage),
                  const SizedBox(height: 24),
                  const Text(
                    'Appareils stockés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildStoredDevicesList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStorageOverview(int currentlyStored, double usagePercentage) {
    final Color statusColor = usagePercentage < 0.7 
        ? Colors.green 
        : usagePercentage < 0.9 
            ? Colors.orange 
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capacité de stockage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: usagePercentage,
                          minHeight: 20,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currentlyStored appareils sur $_totalCapacity (${(usagePercentage * 100).toInt()}%)',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow('En attente de dépôt', 
                        _repairs.where((r) => r.status == RepairStatus.waitingForDropOff).length),
                      const SizedBox(height: 4),
                      _buildStatusRow('Déposés', 
                        _repairs.where((r) => r.status == RepairStatus.droppedOff).length),
                      const SizedBox(height: 4),
                      _buildStatusRow('Prêts pour récupération', 
                        _repairs.where((r) => r.status == RepairStatus.atRelay).length),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoredDevicesList() {
    final storedDevices = _repairs.where((repair) => 
      repair.status == RepairStatus.droppedOff || 
      repair.status == RepairStatus.atRelay
    ).toList();

    if (storedDevices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun appareil stocké',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Les appareils déposés ou prêts pour récupération apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: storedDevices.length,
      itemBuilder: (context, index) {
        final repair = storedDevices[index];
        final bool isReadyForPickup = repair.status == RepairStatus.atRelay;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isReadyForPickup 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.primary,
              child: Icon(
                isReadyForPickup ? Icons.check : Icons.devices,
                color: Colors.white,
              ),
            ),
            title: Text(
              '${repair.brand} ${repair.model}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              isReadyForPickup 
                  ? 'Prêt pour récupération' 
                  : 'Déposé le ${_formatDate(repair.updatedAt ?? repair.createdAt)}',
            ),
            trailing: Text(
              'ID: ${repair.id.substring(0, 8)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            onTap: () {
              // Navigation vers le détail de la réparation
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
