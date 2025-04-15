import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final String userType;

  const AppDrawer({
    super.key,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'PC Relais',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  userType == 'client' 
                      ? 'Espace Client'
                      : userType == 'point_relais'
                          ? 'Espace Point Relais'
                          : userType == 'technicien'
                              ? 'Espace Technicien'
                              : 'Espace Administrateur',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (userType == 'client') ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                context.go('/client');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Mes réparations'),
              onTap: () {
                context.go('/client/repairs');
                Navigator.pop(context);
              },
            ),
            // Les clients ne peuvent pas créer de réparations directement
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon profil'),
              onTap: () {
                context.go('/client/profile');
                Navigator.pop(context);
              },
            ),
          ] else if (userType == 'point_relais') ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                context.go('/point_relais');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Réparations'),
              onTap: () {
                context.go('/point_relais/repairs');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scanner'),
              onTap: () {
                context.go('/point_relais/scan');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Stockage'),
              onTap: () {
                context.go('/point_relais/storage');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon profil'),
              onTap: () {
                context.go('/point_relais/profile');
                Navigator.pop(context);
              },
            ),
          ] else if (userType == 'technicien') ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                context.go('/technicien');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Réparations'),
              onTap: () {
                context.go('/technicien/repairs');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Nouvelle réparation'),
              onTap: () {
                context.go('/technicien/new-repair');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon profil'),
              onTap: () {
                context.go('/technicien/profile');
                Navigator.pop(context);
              },
            ),
          ] else if (userType == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tableau de bord'),
              onTap: () {
                context.go('/admin');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Utilisateurs'),
              onTap: () {
                context.go('/admin/users');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Réparations'),
              onTap: () {
                context.go('/admin/repairs');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                context.go('/admin/settings');
                Navigator.pop(context);
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go('/login');
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
