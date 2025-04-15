import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
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
      
      final updatedUser = _user!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      
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
        title: const Text('Mon profil'),
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              _user?.name.isNotEmpty == true
                                  ? _user!.name.substring(0, 1).toUpperCase()
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
                              _user?.name ?? 'Utilisateur',
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
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nom complet',
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
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Adresse',
                      prefixIcon: const Icon(Icons.home),
                      readOnly: !_isEditing,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse';
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
