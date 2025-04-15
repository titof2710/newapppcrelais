import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class BuralisteProfileScreen extends StatefulWidget {
  const BuralisteProfileScreen({super.key});

  @override
  State<BuralisteProfileScreen> createState() => _BuralisteProfileScreenState();
}

class _BuralisteProfileScreenState extends State<BuralisteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _openingHoursController = TextEditingController();
  
  bool _isLoading = true;
  bool _isEditing = false;
  
  late final AuthService _authService;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _shopNameController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUserData();
      
      if (user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber;
          _addressController.text = user.address ?? '';
          
          // Vérifier si l'utilisateur est un point relais
          if (user is PointRelaisModel) {
            _shopNameController.text = user.shopName;
            _openingHoursController.text = user.openingHours.join(', ');
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement du profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_user == null) {
        throw Exception('Utilisateur non trouvé');
      }
      
      UserModel updatedUser;
      
      // Vérifier si l'utilisateur est un buraliste
      if (_user is PointRelaisModel) {
        final pointRelaisUser = _user as PointRelaisModel;
        updatedUser = pointRelaisUser.copyWith(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          shopName: _shopNameController.text.trim(),
          shopAddress: _addressController.text.trim(),
          openingHours: _openingHoursController.text.split(',').map((e) => e.trim()).toList(),
        );
      } else {
        // Si ce n'est pas un point relais, mettre à jour les champs de base
        updatedUser = _user!.copyWith(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
      }
      
      _user = updatedUser;
      await _authService.updateUserProfile(updatedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _user = updatedUser;
          _isEditing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du profil: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil point relais'),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            child: Text(
                              (_user is PointRelaisModel && (_user as PointRelaisModel).shopName.isNotEmpty)
                                  ? (_user as PointRelaisModel).shopName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!_isEditing)
                            Text(
                              (_user is PointRelaisModel) ? (_user as PointRelaisModel).shopName : 'Point Relais',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Informations du point relais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _shopNameController,
                      label: 'Nom du commerce',
                      prefixIcon: const Icon(Icons.store),
                      readOnly: !_isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom de votre commerce';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Adresse',
                      prefixIcon: const Icon(Icons.location_on),
                      readOnly: !_isEditing,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'adresse de votre commerce';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _openingHoursController,
                      label: 'Horaires d\'ouverture',
                      prefixIcon: const Icon(Icons.access_time),
                      readOnly: !_isEditing,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer vos horaires d\'ouverture';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nom du responsable',
                      prefixIcon: const Icon(Icons.person),
                      readOnly: !_isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      readOnly: true, // L'email ne peut pas être modifié
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      prefixIcon: const Icon(Icons.phone),
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        // Validation simplifiée du format de téléphone
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Format invalide (10 chiffres requis)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'ANNULER',
                              onPressed: () {
                                // Réinitialiser les champs avec les valeurs actuelles
                                _nameController.text = _user?.name ?? '';
                                _phoneController.text = _user?.phoneNumber ?? '';
                                _addressController.text = _user?.address ?? '';
                                
                                // Réinitialiser les champs spécifiques au point relais
                                if (_user is PointRelaisModel) {
                                  final pointRelaisUser = _user as PointRelaisModel;
                                  _shopNameController.text = pointRelaisUser.shopName;
                                  _openingHoursController.text = pointRelaisUser.openingHours.join(', ');
                                }
                                
                                setState(() {
                                  _isEditing = false;
                                });
                              },
                              type: ButtonType.outline,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'ENREGISTRER',
                              onPressed: _updateProfile,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'DÉCONNEXION',
                      onPressed: () async {
                        await _authService.signOut();
                      },
                      type: ButtonType.text,
                      icon: Icons.logout,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
