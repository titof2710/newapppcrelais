import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../technicien/technicien_affectation_screen.dart';
import '../../models/admin_model.dart';
import '../../models/point_relais_model.dart';
import '../../models/technicien_model.dart';
import '../../services/admin_service.dart';
import '../../services/point_relais_service.dart';
import '../../theme/app_theme.dart';

/// Écran de gestion des utilisateurs pour les administrateurs
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final AdminService _adminService = AdminService();
  final PointRelaisService _pointRelaisService = PointRelaisService();
  
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final users = await _adminService.getAllUsers();
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des utilisateurs: $e')),
        );
      }
    }
  }
  
  List<UserModel> get _filteredUsers {
    return _users.where((user) {
      // Appliquer le filtre de recherche
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.phoneNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Appliquer le filtre de type d'utilisateur
      final matchesType = _filterType == 'all' || user.userType == _filterType;
      
      return matchesSearch && matchesType;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun utilisateur trouvé',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Clients', 'client'),
                const SizedBox(width: 8),
                _buildFilterChip('Techniciens', 'technicien'),
                const SizedBox(width: 8),
                _buildFilterChip('Points Relais', 'point_relais'),
                const SizedBox(width: 8),
                _buildFilterChip('Administrateurs', 'admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withAlpha(51), // Équivalent à withOpacity(0.2)
      checkmarkColor: AppTheme.primaryColor,
    );
  }
  
  Widget _buildUserCard(UserModel user) {
    Color avatarColor;
    IconData userTypeIcon;
    
    switch (user.userType) {
      case 'client':
        avatarColor = Colors.blue;
        userTypeIcon = Icons.person;
        break;
      case 'technicien':
        avatarColor = Colors.green;
        userTypeIcon = Icons.build;
        break;
      case 'point_relais':
        avatarColor = Colors.orange;
        userTypeIcon = Icons.store;
        break;
      case 'admin':
        avatarColor = Colors.red;
        userTypeIcon = Icons.admin_panel_settings;
        break;
      default:
        avatarColor = Colors.grey;
        userTypeIcon = Icons.person;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Icon(userTypeIcon, color: Colors.white),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(
              _getUserTypeLabel(user.userType),
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.userType == 'technicien')
              IconButton(
                icon: const Icon(Icons.link),
                tooltip: 'Affecter à des points relais',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicienAffectationScreen(technicien: user),
                    ),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditUserDialog(context, user);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                _showDeleteUserDialog(context, user);
              },
            ),
          ],
        ),
        onTap: () {
          _showUserDetailsDialog(context, user);
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  void _showUserDetailsDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de ${user.name}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Type', _getUserTypeLabel(user.userType)),
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Téléphone', user.phoneNumber),
                if (user.address != null && user.address!.isNotEmpty)
                  _buildDetailRow('Adresse', user.address!),
                _buildDetailRow('Créé le', _formatDate(user.createdAt)),
                
                // Afficher les détails spécifiques en fonction du type d'utilisateur
                if (user is PointRelaisModel) ...[                  
                  const Divider(),
                  const Text(
                    'Détails du point relais',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildDetailRow('Nom du commerce', user.shopName),
                  _buildDetailRow('Adresse du commerce', user.shopAddress),
                  _buildDetailRow('Heures d\'ouverture', user.openingHours.join(', ')),
                  _buildDetailRow('Capacité de stockage', user.storageCapacity.toString()),
                ] else if (user is TechnicienModel) ...[                  
                  const Divider(),
                  const Text(
                    'Détails du technicien',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildDetailRow('Spécialités', user.speciality.join(', ')),
                  _buildDetailRow('Années d\'expérience', user.experienceYears.toString()),
                  if (user.certifications.isNotEmpty)
                    _buildDetailRow('Certifications', user.certifications.join(', ')),
                ] else if (user is AdminModel) ...[                  
                  const Divider(),
                  const Text(
                    'Détails de l\'administrateur',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildDetailRow('Rôle', user.role),
                  if (user.permissions.isNotEmpty)
                    _buildDetailRow('Permissions', user.permissions.join(', ')),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'client':
        return 'Client';
      case 'point_relais':
        return 'Point Relais';
      case 'technicien':
        return 'Technicien';
      case 'admin':
        return 'Administrateur';
      default:
        return userType;
    }
  }
  
  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final passwordController = TextEditingController();
    
    // Champs spécifiques pour les points relais
    final shopNameController = TextEditingController();
    final shopAddressController = TextEditingController();
    final openingHoursController = TextEditingController();
    final storageCapacityController = TextEditingController(text: '10');
    
    // Champs spécifiques pour les techniciens
    final specialityController = TextEditingController();
    final experienceYearsController = TextEditingController(text: '0');
    final certificationsController = TextEditingController();
    
    // Champs spécifiques pour les administrateurs
    final roleController = TextEditingController(text: 'admin');
    final permissionsController = TextEditingController(text: 'all');
    
    String selectedUserType = 'client';
    bool _isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un utilisateur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedUserType,
                      decoration: const InputDecoration(
                        labelText: 'Type d\'utilisateur',
                      ),
                      items: [
                        DropdownMenuItem(value: 'client', child: Text(_getUserTypeLabel('client'))),
                        DropdownMenuItem(value: 'point_relais', child: Text(_getUserTypeLabel('point_relais'))),
                        DropdownMenuItem(value: 'technicien', child: Text(_getUserTypeLabel('technicien'))),
                        DropdownMenuItem(value: 'admin', child: Text(_getUserTypeLabel('admin'))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        hintText: 'Entrez le nom complet',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Entrez l\'adresse email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        hintText: 'Entrez le numéro de téléphone',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        hintText: 'Entrez l\'adresse',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        hintText: 'Entrez le mot de passe',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Champs spécifiques pour les points relais
                    if (selectedUserType == 'point_relais') ...[                      
                      const Divider(),
                      const Text(
                        'Informations du point relais',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: shopNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du commerce',
                          hintText: 'Entrez le nom du commerce',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: shopAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse du commerce',
                          hintText: 'Entrez l\'adresse du commerce',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: openingHoursController,
                        decoration: const InputDecoration(
                          labelText: 'Heures d\'ouverture',
                          hintText: 'Ex: Lun-Ven 9h-18h, Sam 9h-12h',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: storageCapacityController,
                        decoration: const InputDecoration(
                          labelText: 'Capacité de stockage',
                          hintText: 'Nombre de PC pouvant être stockés',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ]
                    
                    // Champs spécifiques pour les techniciens
                    else if (selectedUserType == 'technicien') ...[                      
                      const Divider(),
                      const Text(
                        'Informations du technicien',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: specialityController,
                        decoration: const InputDecoration(
                          labelText: 'Spécialités',
                          hintText: 'Ex: Réparation PC, Dépannage réseau',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: experienceYearsController,
                        decoration: const InputDecoration(
                          labelText: 'Années d\'expérience',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: certificationsController,
                        decoration: const InputDecoration(
                          labelText: 'Certifications',
                          hintText: 'Ex: CompTIA A+, Microsoft Certified',
                        ),
                      ),
                    ]
                    
                    // Champs spécifiques pour les administrateurs
                    else if (selectedUserType == 'admin') ...[                      
                      const Divider(),
                      const Text(
                        'Informations de l\'administrateur',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: roleController,
                        decoration: const InputDecoration(
                          labelText: 'Rôle',
                          hintText: 'Ex: admin, super_admin',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: permissionsController,
                        decoration: const InputDecoration(
                          labelText: 'Permissions',
                          hintText: 'Ex: users, repairs, all',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  TextButton(
                    onPressed: () async {
                      // Validation des champs obligatoires
                      if (nameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          passwordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                        );
                        return;
                      }
                      
                      try {
                        setState(() {
                          _isLoading = true;
                        });
                        
                        // Variable pour suivre si le contexte est monté
                        
                        
                        // Création de l'utilisateur en fonction du type sélectionné
                        if (selectedUserType == 'client') {
                          await _adminService.createClient(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            address: addressController.text.trim(),
                          );
                        } else if (selectedUserType == 'point_relais') {
                          // Validation des champs spécifiques aux points relais
                          if (shopNameController.text.trim().isEmpty ||
                              shopAddressController.text.trim().isEmpty ||
                              openingHoursController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs du point relais')),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            return;
                          }
                          
                          await _pointRelaisService.createPointRelais(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            address: addressController.text.trim(),
                            shopName: shopNameController.text.trim(),
                            shopAddress: shopAddressController.text.trim(),
                            openingHours: openingHoursController.text.split(',').map((s) => s.trim()).toList(),
                            storageCapacity: int.tryParse(storageCapacityController.text) ?? 10,
                          );
                        } else if (selectedUserType == 'technicien') {
                          // Validation des champs spécifiques aux techniciens
                          if (specialityController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez spécifier au moins une spécialité')),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            return;
                          }
                          
                          await _adminService.createTechnicien(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            address: addressController.text.trim(),
                            speciality: specialityController.text.split(',').map((s) => s.trim()).toList(),
                            experienceYears: int.tryParse(experienceYearsController.text) ?? 0,
                            certifications: certificationsController.text.split(',').map((s) => s.trim()).toList(),
                          );
                        } else if (selectedUserType == 'admin') {
                          await _adminService.createAdmin(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            role: roleController.text.trim(),
                            permissions: permissionsController.text.split(',').map((s) => s.trim()).toList(),
                          );
                        }
                        
                        Navigator.of(context).pop();
                        
                        // Recharger la liste des utilisateurs
                        await _loadUsers();
                        
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Utilisateur créé avec succès')),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la création: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Ajouter'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final addressController = TextEditingController(text: user.address ?? '');
    
    // Champs spécifiques pour les points relais
    final shopNameController = TextEditingController();
    final shopAddressController = TextEditingController();
    final openingHoursController = TextEditingController();
    final storageCapacityController = TextEditingController(text: '10');
    
    // Champs spécifiques pour les techniciens
    final specialityController = TextEditingController();
    final experienceYearsController = TextEditingController(text: '0');
    final certificationsController = TextEditingController();
    
    // Initialiser les champs spécifiques en fonction du type d'utilisateur
    if (user is PointRelaisModel) {
      shopNameController.text = user.shopName;
      shopAddressController.text = user.shopAddress;
      openingHoursController.text = user.openingHours.join(', ');
      storageCapacityController.text = user.storageCapacity.toString();
    } else if (user is TechnicienModel) {
      specialityController.text = user.speciality.join(', ');
      experienceYearsController.text = user.experienceYears.toString();
      certificationsController.text = user.certifications.join(', ');
    }
    
    bool _isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Modifier ${user.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getUserTypeLabel(user.userType),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        hintText: 'Entrez le nom complet',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Entrez l\'adresse email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        hintText: 'Entrez le numéro de téléphone',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        hintText: 'Entrez l\'adresse',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Champs spécifiques pour les points relais
                    if (user is PointRelaisModel) ...[                      
                      const Divider(),
                      const Text(
                        'Informations du point relais',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: shopNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du commerce',
                          hintText: 'Entrez le nom du commerce',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: shopAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse du commerce',
                          hintText: 'Entrez l\'adresse du commerce',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: openingHoursController,
                        decoration: const InputDecoration(
                          labelText: 'Heures d\'ouverture',
                          hintText: 'Ex: Lun-Ven 9h-18h, Sam 9h-12h',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: storageCapacityController,
                        decoration: const InputDecoration(
                          labelText: 'Capacité de stockage',
                          hintText: 'Nombre de PC pouvant être stockés',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ]
                    
                    // Champs spécifiques pour les techniciens
                    else if (user is TechnicienModel) ...[                      
                      const Divider(),
                      const Text(
                        'Informations du technicien',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: specialityController,
                        decoration: const InputDecoration(
                          labelText: 'Spécialités',
                          hintText: 'Ex: Réparation PC, Dépannage réseau',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: experienceYearsController,
                        decoration: const InputDecoration(
                          labelText: 'Années d\'expérience',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: certificationsController,
                        decoration: const InputDecoration(
                          labelText: 'Certifications',
                          hintText: 'Ex: CompTIA A+, Microsoft Certified',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  TextButton(
                    onPressed: () async {
                      // Validation des champs obligatoires
                      if (nameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                        );
                        return;
                      }
                      
                      try {
                        setState(() {
                          _isLoading = true;
                        });
                        
                        // Variable pour suivre si le contexte est monté
                        
                        
                        // Mise à jour de l'utilisateur en fonction du type
                        // Créer un modèle utilisateur mis à jour
                        UserModel updatedUser = user.copyWith(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                        );
                        
                        if (user is PointRelaisModel) {
                          // Pour les points relais, utiliser la méthode spécifique
                          await _pointRelaisService.updatePointRelais(
                            updatedUser,
                            shopName: shopNameController.text.trim(),
                            shopAddress: shopAddressController.text.trim(),
                            openingHours: openingHoursController.text.split(',').map((s) => s.trim()).toList(),
                            storageCapacity: int.tryParse(storageCapacityController.text) ?? 10,
                          );
                        } else {
                          // Pour les autres types d'utilisateurs, utiliser la méthode générique
                          await _adminService.updateUser(updatedUser);
                        }
                        
                        // Recharger la liste des utilisateurs
                        await _loadUsers();
                        
                        
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Utilisateur mis à jour avec succès')),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showDeleteUserDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur ${user.name} ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  
                  setState(() {
                    _isLoading = true;
                  });
                  
                  // Variable pour suivre si le contexte est monté
                  
                  
                  // Variable pour suivre si le contexte est monté
                  
                  
                  await _adminService.deleteUser(user.id);
                  
                  // Recharger la liste des utilisateurs
                  await _loadUsers();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Utilisateur supprimé avec succès')),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  
                  
                  
                  
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la suppression: $e')),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
