import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/repair_service.dart';
import '../../models/repair_model.dart';
import '../../models/user_model.dart';
import '../../models/point_relais_model.dart';
import '../../theme/app_theme.dart';

class ClientHomeScreen extends StatefulWidget {
  final Widget child;

  const ClientHomeScreen({
    super.key,
    required this.child,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
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
              context.go('/client');
              break;
            case 1:
              context.go('/client/new_repair');
              break;
            case 2:
              context.go('/client/repairs');
              break;
            case 3:
              context.go('/client/chat');
              break;
            case 4:
              context.go('/client/profile');
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
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Déposer',
          ),
          NavigationDestination(
            icon: Icon(Icons.computer_outlined),
            selectedIcon: Icon(Icons.computer),
            label: 'Réparations',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Messages',
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
    if (location.startsWith('/client/repairs')) {
      return 1;
    } else if (location.startsWith('/client/chat')) {
      return 2;
    } else if (location.startsWith('/client/profile')) {
      return 3;
    } else {
      return 0;
    }
  }
}

class ClientHomeContent extends StatefulWidget {
  const ClientHomeContent({super.key});

  @override
  State<ClientHomeContent> createState() => _ClientHomeContentState();
}

class _ClientHomeContentState extends State<ClientHomeContent> {
  // Méthode pour calculer la progression d'une réparation en fonction de son statut
  double _getRepairProgress(RepairStatus status) {
    switch (status) {
      case RepairStatus.waiting_drop:
        return 0.1;
      case RepairStatus.in_progress:
        return 0.5;
      case RepairStatus.diagnosed:
        return 0.3;
      case RepairStatus.waiting_for_parts:
        return 0.4;
      case RepairStatus.ready_for_pickup:
        return 0.9;
      case RepairStatus.completed:
        return 1.0;
      case RepairStatus.picked_up:
        return 1.0;
      case RepairStatus.cancelled:
        return 0.0;
      case RepairStatus.pending:
        return 0.0;
      default:
        return 0.0;
    }
  }
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PC Relais'),
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
          
          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Text('Utilisateur non connecté'),
            );
          }
          
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
                  // Carte de bienvenue
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour, ${user.name}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Bienvenue sur PC Relais',
                                      style: TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Besoin de faire réparer votre ordinateur ?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/client/new-repair'),
                            icon: const Icon(Icons.add),
                            label: const Text('NOUVELLE DEMANDE DE RÉPARATION'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Titre section réparations en cours
                  const Text(
                    'Vos réparations en cours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Réparations en cours - chargées dynamiquement
                  FutureBuilder<List<RepairModel>>(
                    future: Provider.of<RepairService>(context).getRepairsForClient(user.id),
                    builder: (context, repairsSnapshot) {
                      if (repairsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (repairsSnapshot.hasError) {
                        return Center(
                          child: Text('Erreur: ${repairsSnapshot.error}'),
                        );
                      }
                      
                      final repairs = repairsSnapshot.data ?? [];
                      
                      if (repairs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Vous n\'avez aucune réparation en cours.',
                              style: TextStyle(color: AppTheme.textSecondaryColor),
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: repairs.take(2).map((repair) {
                          return Column(
                            children: [
                              _buildRepairCard(
                                status: repair.status.toString().split('.').last,
                                deviceType: repair.deviceType,
                                brand: repair.brand,
                                model: repair.model,
                                date: repair.createdAt.toString().substring(0, 10),
                                progress: _getRepairProgress(repair.status),
                                onTap: () => context.go('/client/repair/${repair.id}'),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Bouton voir toutes les réparations
                  OutlinedButton(
                    onPressed: () => context.go('/client/repairs'),
                    child: const Text('VOIR TOUTES MES RÉPARATIONS'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Titre section points relais
                  const Text(
                    'Points relais à proximité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Liste des points relais - chargés dynamiquement
                  FutureBuilder<List<PointRelaisModel>>(
                    future: Provider.of<AuthService>(context).getNearbyPointRelais(),
                    builder: (context, pointRelaisSnapshot) {
                      if (pointRelaisSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (pointRelaisSnapshot.hasError) {
                        return Center(
                          child: Text('Erreur: ${pointRelaisSnapshot.error}'),
                        );
                      }
                      
                      final pointRelais = pointRelaisSnapshot.data ?? [];
                      
                      if (pointRelais.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Aucun point relais trouvé à proximité.',
                              style: TextStyle(color: AppTheme.textSecondaryColor),
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: pointRelais.take(3).map((pr) {
                          return Column(
                            children: [
                              _buildRelayCard(
                                name: pr.shopName,
                                address: pr.shopAddress,
                                distance: '< 5km', // À calculer avec la géolocalisation
                                openingHours: pr.openingHours.join(', '),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRepairCard({
    required String status,
    required String deviceType,
    required String brand,
    required String model,
    required String date,
    required double progress,
    required VoidCallback onTap,
  }) {
    Color statusColor;
    if (progress < 0.3) {
      statusColor = Colors.orange;
    } else if (progress < 0.7) {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.green;
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$deviceType $brand $model',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dépôt',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const Text(
                    'Diagnostic',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const Text(
                    'Réparation',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const Text(
                    'Récupération',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelayCard({
    required String name,
    required String address,
    required String distance,
    required String openingHours,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.store,
                color: AppTheme.secondaryColor,
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
                          name,
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
                          distance,
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
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    openingHours,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
