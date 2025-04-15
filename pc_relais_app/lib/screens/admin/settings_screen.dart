import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/admin_model.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Écran des paramètres pour les administrateurs
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  
  AdminModel? _adminData;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Français';
  
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
      final adminData = await _adminService.getCurrentAdminData();
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _adminData = adminData;
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
        _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
        _selectedLanguage = prefs.getString('language') ?? 'Français';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données: $e')),
      );
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
      await prefs.setBool('darkModeEnabled', _darkModeEnabled);
      await prefs.setString('language', _selectedLanguage);
      
      setState(() {
        _isLoading = false;
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres enregistrés avec succès')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement des paramètres: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _adminData == null
              ? const Center(
                  child: Text(
                    'Vous n\'avez pas les droits d\'administration nécessaires.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 24),
                      _buildNotificationsSection(),
                      const SizedBox(height: 24),
                      _buildAppearanceSection(),
                      const SizedBox(height: 24),
                      _buildLanguageSection(),
                      const SizedBox(height: 24),
                      _buildSecuritySection(),
                      const SizedBox(height: 24),
                      _buildAboutSection(),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Enregistrer les paramètres'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 30,
                  child: Text(
                    _adminData!.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _adminData!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _adminData!.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Rôle: ${_adminData!.role}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Implémenter la modification du profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à implémenter')),
                );
              },
              child: const Text('Modifier le profil'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Activer les notifications'),
              subtitle: const Text('Recevoir des notifications pour les nouvelles réparations et messages'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(),
            ListTile(
              title: const Text('Nouvelles réparations'),
              subtitle: const Text('Notifications pour les nouvelles réparations'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
            ListTile(
              title: const Text('Nouveaux messages'),
              subtitle: const Text('Notifications pour les nouveaux messages'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppearanceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apparence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mode sombre'),
              subtitle: const Text('Utiliser le thème sombre pour l\'application'),
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Langue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Langue',
                border: OutlineInputBorder(),
              ),
              value: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 'Français',
                  child: Text('Français'),
                ),
                DropdownMenuItem(
                  value: 'English',
                  child: Text('English'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sécurité',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Changer le mot de passe'),
              onTap: () {
                // Implémenter le changement de mot de passe
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à implémenter')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Authentification à deux facteurs'),
              onTap: () {
                // Implémenter l'authentification à deux facteurs
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à implémenter')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'À propos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Version de l\'application'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Conditions d\'utilisation'),
              onTap: () {
                // Afficher les conditions d'utilisation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à implémenter')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Politique de confidentialité'),
              onTap: () {
                // Afficher la politique de confidentialité
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à implémenter')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
