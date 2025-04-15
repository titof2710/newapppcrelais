import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class RegisterBuralisteScreen extends StatefulWidget {
  const RegisterBuralisteScreen({super.key});

  @override
  State<RegisterBuralisteScreen> createState() => _RegisterBuralisteScreenState();
}

class _RegisterBuralisteScreenState extends State<RegisterBuralisteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final List<String> _openingHours = List.filled(7, '');
  final List<String> _daysOfWeek = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];
  
  int _storageCapacity = 10; // Valeur par défaut
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Filtrer les horaires vides
      final List<String> openingHours = [];
      for (int i = 0; i < _daysOfWeek.length; i++) {
        if (_openingHours[i].isNotEmpty) {
          openingHours.add('${_daysOfWeek[i]}: ${_openingHours[i]}');
        } else {
          openingHours.add('${_daysOfWeek[i]}: Fermé');
        }
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.registerPointRelais(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        shopName: _shopNameController.text.trim(),
        shopAddress: _shopAddressController.text.trim(),
        openingHours: openingHours,
        storageCapacity: _storageCapacity,
      );

      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Vous êtes maintenant connecté.'),
          backgroundColor: Colors.green,
        ),
      );

      // Rediriger vers la page d'accueil point relais
      context.go('/point_relais');
    } catch (e) {
      setState(() {
        _errorMessage = 'Échec de l\'inscription: ${e.toString()}';
      });
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
        title: const Text('Inscription Point Relais'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titre
                const Text(
                  'Devenir point relais',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez notre réseau de points relais partenaires',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Affichage des erreurs
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),

                // Section Informations personnelles
                const Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Champ nom
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du responsable',
                    hintText: 'Jean Dupont',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'exemple@email.com',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ téléphone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    hintText: '06 12 34 56 78',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Section Informations du commerce
                const Text(
                  'Informations du commerce',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Champ nom du commerce
                TextFormField(
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du commerce',
                    hintText: 'Tabac Presse du Centre',
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom de votre commerce';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ adresse du commerce
                TextFormField(
                  controller: _shopAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse du commerce',
                    hintText: '123 rue de Paris, 75001 Paris',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'adresse de votre commerce';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Section Horaires d'ouverture
                const Text(
                  'Horaires d\'ouverture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Indiquez vos horaires d\'ouverture pour chaque jour (ex: 9h-12h, 14h-19h)',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Champs horaires pour chaque jour
                ...List.generate(7, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            _daysOfWeek[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'ex: 9h-12h, 14h-19h',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              _openingHours[index] = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Section Capacité de stockage
                const Text(
                  'Capacité de stockage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Combien d\'appareils pouvez-vous stocker dans votre commerce ?',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Slider pour la capacité de stockage
                Row(
                  children: [
                    const Text('5'),
                    Expanded(
                      child: Slider(
                        value: _storageCapacity.toDouble(),
                        min: 5,
                        max: 50,
                        divisions: 9,
                        label: _storageCapacity.toString(),
                        onChanged: (value) {
                          setState(() {
                            _storageCapacity = value.round();
                          });
                        },
                      ),
                    ),
                    const Text('50'),
                  ],
                ),
                Center(
                  child: Text(
                    '$_storageCapacity appareils',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section Mot de passe
                const Text(
                  'Sécurité',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Bouton d'inscription
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('S\'INSCRIRE COMME POINT RELAIS'),
                ),
                const SizedBox(height: 16),

                // Lien vers la page de connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte ?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
