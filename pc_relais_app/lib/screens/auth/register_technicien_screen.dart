import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/app_theme.dart';

class RegisterTechnicienScreen extends StatefulWidget {
  const RegisterTechnicienScreen({super.key});

  @override
  State<RegisterTechnicienScreen> createState() => _RegisterTechnicienScreenState();
}

class _RegisterTechnicienScreenState extends State<RegisterTechnicienScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialityController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _certificationsController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _specialityController.dispose();
    _experienceYearsController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.registerTechnicien(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        speciality: _specialityController.text.split(',').map((e) => e.trim()).toList(),
        experienceYears: int.tryParse(_experienceYearsController.text) ?? 0,
        certifications: _certificationsController.text.split(',').map((e) => e.trim()).toList(),
      );
      // Récupérer le token FCM et le stocker dans Supabase
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      final fcmToken = await notificationService.getToken();
      if (fcmToken != null) {
        await authService.updateUserFcmToken(user.uuid, fcmToken);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription technicien réussie !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/technicien');
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'inscription: ${e.toString()}';
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
        title: const Text('Inscription Technicien'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Créer un compte technicien',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: 'Nom complet',
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre nom' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre email' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  prefixIcon: const Icon(Icons.phone),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer votre téléphone' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: 'Adresse',
                  prefixIcon: const Icon(Icons.location_on),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _specialityController,
                  label: 'Spécialités (séparées par des virgules)',
                  prefixIcon: const Icon(Icons.build),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _experienceYearsController,
                  label: 'Années d\'expérience',
                  prefixIcon: const Icon(Icons.calendar_today),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _certificationsController,
                  label: 'Certifications (séparées par des virgules)',
                  prefixIcon: const Icon(Icons.verified),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) => value == null || value.length < 6 ? '6 caractères minimum' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) => value != _passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                CustomButton(
                  text: _isLoading ? 'Inscription...' : 'S\'inscrire',
                  onPressed: _isLoading ? null : _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
