import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/repair_service.dart';
import '../../models/repair_model.dart';
import '../../models/deposit_model.dart';
import '../../widgets/deposit_qr_widget.dart';
import '../../models/user_model.dart';
import '../../models/point_relais_model.dart';
import '../../theme/app_theme.dart';

class StorageManagementScreen extends StatefulWidget {
  const StorageManagementScreen({super.key});

  @override
  State<StorageManagementScreen> createState() => _StorageManagementScreenState();
}

class _StorageManagementScreenState extends State<StorageManagementScreen> {
  bool _isLoading = true;
  late PointRelaisModel _pointRelais;
  List<RepairModel> _storedDevices = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final repairService = Provider.of<RepairService>(context, listen: false);
      
      // Charger les données du point relais
      final user = await authService.getCurrentUserData();
      if (user is PointRelaisModel) {
        _pointRelais = user;
        
        // Charger les réparations stockées au point relais
        final repairs = await repairService.getRepairsForPointRelais(user.uuid);
        _storedDevices = repairs.where((repair) => 
          repair.status == 'waiting_repair' || 
          repair.status == 'ready_for_pickup').toList();
      } else {
        throw Exception('Utilisateur non autorisé');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des données: $e'),
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
        title: const Text('Gestion du stockage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStorageOverview(),
                    const SizedBox(height: 24),
                    const Text(
                      'Appareils stockés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _storedDevices.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: _storedDevices
                                .map((device) => _buildDeviceCard(device))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildStorageOverview() {
    // Calculer le pourcentage d'utilisation
    final usagePercentage = _pointRelais.storageCapacity > 0
        ? (_pointRelais.currentStorageUsed / _pointRelais.storageCapacity * 100).toInt()
        : 0;
    
    // Déterminer la couleur en fonction du pourcentage d'utilisation
    Color usageColor;
    if (usagePercentage < 50) {
      usageColor = Colors.green;
    } else if (usagePercentage < 80) {
      usageColor = Colors.orange;
    } else {
      usageColor = Colors.red;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capacité de stockage',
              style: TextStyle(
                fontSize: 16,
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
                          value: _pointRelais.storageCapacity > 0
                              ? _pointRelais.currentStorageUsed / _pointRelais.storageCapacity
                              : 0,
                          minHeight: 12,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(usageColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$usagePercentage% utilisé',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: usageColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${_pointRelais.currentStorageUsed}/${_pointRelais.storageCapacity}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'appareils',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStorageStat(
                  icon: Icons.arrow_downward,
                  label: 'En attente',
                  value: _storedDevices.where((d) => d.status == 'waiting_repair').length.toString(),
                  color: Colors.blue,
                ),
                _buildStorageStat(
                  icon: Icons.arrow_upward,
                  label: 'Prêts',
                  value: _storedDevices.where((d) => d.status == 'ready_for_pickup').length.toString(),
                  color: Colors.green,
                ),
                _buildStorageStat(
                  icon: Icons.schedule,
                  label: 'Arrivées',
                  value: '2', // Valeur fictive
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStorageStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun appareil stocké',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les appareils en attente de réparation ou prêts à être récupérés apparaîtront ici.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceCard(RepairModel repair) {
  // TODO: Pour afficher le QR code du dépôt, il faut relier RepairModel à DepositModel et récupérer le code ici.

    // Déterminer l'icône et la couleur en fonction du statut
    IconData statusIcon;
    Color statusColor;
    String statusText;
    
    if (repair.status == 'waiting_repair') {
      statusIcon = Icons.arrow_downward;
      statusColor = Colors.blue;
      statusText = 'En attente de réparation';
    } else {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
      statusText = 'Prêt pour récupération';
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${repair.deviceType} ${repair.brand} ${repair.model}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${repair.clientName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reçu le: ${_formatDate(repair.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                    // TODO: Affichage QR code dépôt : à activer si RepairModel est lié à DepositModel.
                    // Actuellement désactivé car RepairModel n'a pas de champ deposit/code.

                    if (repair.status == 'waiting_repair')
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implémenter l'envoi à l'atelier
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('ENVOYER À L\'ATELIER'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
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
