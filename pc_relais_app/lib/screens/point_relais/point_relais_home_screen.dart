import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/repair_service.dart';
import '../../models/user_model.dart';
import '../../models/repair_model.dart';
import '../../models/point_relais_model.dart';
import '../../theme/app_theme.dart';

class PointRelaisHomeScreen extends StatefulWidget {
  final Widget child;

  const PointRelaisHomeScreen({
    super.key,
    required this.child,
  });

  @override
  State<PointRelaisHomeScreen> createState() => _PointRelaisHomeScreenState();
}

class _PointRelaisHomeScreenState extends State<PointRelaisHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(GoRouterState.of(context).uri.toString()),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              context.go('/point_relais');
              break;
            case 1:
              context.go('/point_relais/repairs');
              break;
            case 2:
              context.go('/point_relais/scan');
              break;
            case 3:
              context.go('/point_relais/storage');
              break;
            case 4:
              context.go('/point_relais/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.computer_outlined),
            selectedIcon: Icon(Icons.computer),
            label: 'Réparations',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stockage',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/point_relais/repairs')) {
      return 1;
    } else if (location.startsWith('/point_relais/scan')) {
      return 2;
    } else if (location.startsWith('/point_relais/storage')) {
      return 3;
    } else if (location.startsWith('/point_relais/profile')) {
      return 4;
    } else {
      return 0;
    }
  }
}

class PointRelaisHomeContent extends StatefulWidget {
  const PointRelaisHomeContent({super.key});

  @override
  State<PointRelaisHomeContent> createState() => _PointRelaisHomeContentState();
}

class _PointRelaisHomeContentState extends State<PointRelaisHomeContent> {
  // Formater une date pour l'affichage
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays == -1) {
      return "Demain";
    } else if (difference.inDays < 0 && difference.inDays > -7) {
      return "Dans ${-difference.inDays} jours";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
  
  // Calculer le nombre de jours écoulés depuis une date
  String _getDaysSince(DateTime? date) {
    if (date == null) {
      return "Date inconnue";
    }
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "1 jour";
    } else {
      return "${difference.inDays} jours";
    }
  }
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PC Relais - Point Relais'),
        backgroundColor: AppTheme.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implémenter les notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: authService.getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }
          
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Aucune donnée disponible'),
            );
          }
          
          final user = snapshot.data as PointRelaisModel;
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec informations du point relais
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.shopName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.shopAddress,
                                      style: const TextStyle(
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                icon: Icons.inventory_2,
                                title: 'Capacité',
                                value: '${user.currentStorageUsed}/${user.storageCapacity}',
                                color: AppTheme.primaryColor,
                              ),
                              _buildStatCard(
                                icon: Icons.access_time,
                                title: 'Horaires',
                                value: user.openingHours.isNotEmpty ? user.openingHours[0] : 'Non défini',
                                color: AppTheme.secondaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section des arrivées imminentes
                  const Text(
                    'Arrivées imminentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Liste des arrivées imminentes - chargées dynamiquement
                  FutureBuilder<List<RepairModel>>(
                    future: Provider.of<RepairService>(context).getRepairsForPointRelais(user.uuid, status: RepairStatus.waiting_drop),
                    builder: (context, arrivalsSnapshot) {
                      if (arrivalsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (arrivalsSnapshot.hasError) {
                        return Center(
                          child: Text('Erreur: ${arrivalsSnapshot.error}'),
                        );
                      }
                      
                      final arrivals = arrivalsSnapshot.data ?? [];
                      
                      if (arrivals.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Aucune arrivée imminente.',
                              style: TextStyle(color: AppTheme.textSecondaryColor),
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: arrivals.map((repair) {
                          return _buildArrivalCard(
                            clientName: repair.clientName,
                            deviceType: repair.deviceType,
                            brand: repair.brand,
                            model: repair.model,
                            arrivalDate: _formatDate(repair.createdAt),
                            status: 'En attente',
                            onTap: () {
                              context.go('/point_relais/repairs/${repair.id}');
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section des appareils prêts à être récupérés
                  const Text(
                    'Prêts à être récupérés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Liste des appareils prêts - chargés dynamiquement
                  FutureBuilder<List<RepairModel>>(
                    future: Provider.of<RepairService>(context).getRepairsForPointRelais(user.uuid, status: RepairStatus.ready_for_pickup),
                    builder: (context, readySnapshot) {
                      if (readySnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (readySnapshot.hasError) {
                        return Center(
                          child: Text('Erreur: ${readySnapshot.error}'),
                        );
                      }
                      
                      final readyRepairs = readySnapshot.data ?? [];
                      
                      if (readyRepairs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Aucun appareil prêt à être récupéré.',
                              style: TextStyle(color: AppTheme.textSecondaryColor),
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: readyRepairs.map((repair) {
                          return _buildPickupCard(
                            clientName: repair.clientName,
                            deviceType: repair.deviceType,
                            brand: repair.brand,
                            model: repair.model,
                            readySince: _getDaysSince(repair.updatedAt),
                            onTap: () {
                              context.go('/point_relais/repairs/${repair.id}');
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalCard({
    required String clientName,
    required String deviceType,
    required String brand,
    required String model,
    required String arrivalDate,
    required String status,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppTheme.primaryColor,
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
                            clientName,
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
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Arrivée: $arrivalDate',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$deviceType $brand $model',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implémenter la réception
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
                      ],
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

  Widget _buildPickupCard({
    required String clientName,
    required String deviceType,
    required String brand,
    required String model,
    required String readySince,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
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
                            clientName,
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
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Prêt depuis $readySince',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$deviceType $brand $model',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
