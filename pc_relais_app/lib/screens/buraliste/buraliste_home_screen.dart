import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';

class BuralisteHomeScreen extends StatefulWidget {
  final Widget child;

  const BuralisteHomeScreen({
    super.key,
    required this.child,
  });

  @override
  State<BuralisteHomeScreen> createState() => _BuralisteHomeScreenState();
}

class _BuralisteHomeScreenState extends State<BuralisteHomeScreen> {
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

class BuralisteHomeContent extends StatefulWidget {
  const BuralisteHomeContent({super.key});

  @override
  State<BuralisteHomeContent> createState() => _BuralisteHomeContentState();
}

class _BuralisteHomeContentState extends State<BuralisteHomeContent> {
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
                                      'Bonjour, ${user.name}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user is PointRelaisModel ? user.shopName : 'Point Relais',
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
                          const Text(
                            'Gérez facilement les appareils en dépôt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/point_relais/scan'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('SCANNER UN APPAREIL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Résumé du stockage
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Capacité de stockage',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.inventory_2,
                                color: AppTheme.secondaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (user is PointRelaisModel) ...[
                            LinearProgressIndicator(
                              value: user.currentStorageUsed / user.storageCapacity,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${user.currentStorageUsed} appareils en stock',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Capacité: ${user.storageCapacity}',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/point_relais/storage'),
                              icon: const Icon(Icons.visibility),
                              label: const Text('GÉRER LE STOCKAGE'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Titre section arrivées imminentes
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Arrivées imminentes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: AppTheme.accentColor,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Liste des arrivées imminentes (à remplacer par les vraies données)
                  _buildArrivalCard(
                    clientName: 'Martin Dupont',
                    deviceType: 'PC Portable',
                    brand: 'Lenovo',
                    model: 'ThinkPad X1',
                    arrivalDate: 'Aujourd\'hui',
                    status: 'En transit',
                    onTap: () => context.go('/point_relais/repairs/3'),
                  ),
                  const SizedBox(height: 12),
                  _buildArrivalCard(
                    clientName: 'Sophie Martin',
                    deviceType: 'PC Fixe',
                    brand: 'Asus',
                    model: 'ROG',
                    arrivalDate: 'Demain',
                    status: 'En préparation',
                    onTap: () => context.go('/point_relais/repairs/4'),
                  ),
                  const SizedBox(height: 12),
                  _buildArrivalCard(
                    clientName: 'Jean Dujardin',
                    deviceType: 'PC Portable',
                    brand: 'Apple',
                    model: 'MacBook Pro',
                    arrivalDate: 'Après-demain',
                    status: 'En préparation',
                    onTap: () => context.go('/point_relais/repairs/5'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bouton voir toutes les réparations
                  OutlinedButton(
                    onPressed: () => context.go('/point_relais/repairs'),
                    child: const Text('VOIR TOUTES LES RÉPARATIONS'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Titre section appareils à récupérer
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appareils à récupérer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Liste des appareils à récupérer (à remplacer par les vraies données)
                  _buildPickupCard(
                    clientName: 'Lucie Petit',
                    deviceType: 'PC Portable',
                    brand: 'Dell',
                    model: 'Inspiron',
                    readySince: '3 jours',
                    onTap: () => context.go('/point_relais/repairs/6'),
                  ),
                  const SizedBox(height: 12),
                  _buildPickupCard(
                    clientName: 'Thomas Leroy',
                    deviceType: 'PC Fixe',
                    brand: 'HP',
                    model: 'Pavilion',
                    readySince: '1 jour',
                    onTap: () => context.go('/point_relais/repairs/7'),
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
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.computer,
                  color: AppTheme.accentColor,
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
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            arrivalDate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
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
                    const SizedBox(height: 4),
                    Text(
                      'Statut: $status',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
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
