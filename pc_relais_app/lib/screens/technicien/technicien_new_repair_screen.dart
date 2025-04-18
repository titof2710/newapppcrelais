import 'package:flutter/material.dart';
import '../../models/repair_model.dart';
import '../../services/repair_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class TechnicienNewRepairScreen extends StatefulWidget {
  const TechnicienNewRepairScreen({Key? key}) : super(key: key);

  @override
  State<TechnicienNewRepairScreen> createState() => _TechnicienNewRepairScreenState();
}

class _TechnicienNewRepairScreenState extends State<TechnicienNewRepairScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _deviceTypeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _issueController = TextEditingController();
  final _estimatedPriceController = TextEditingController();
  
  final RepairService _repairService = RepairService();
  final AuthService _authService = AuthService();
  
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientNameController.dispose();
    _deviceTypeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _issueController.dispose();
    _estimatedPriceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final currentUser = await _authService.getCurrentUserData();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final repair = RepairModel(
        clientEmail: '',
        id: '', // Sera généré par le service
        clientId: _clientIdController.text, // Doit contenir un UUID (à vérifier lors de la saisie ou récupération du client)
        clientName: _clientNameController.text,
        technicienId: currentUser.uuid,
        deviceType: _deviceTypeController.text,
        brand: _brandController.text,
        model: _modelController.text,
        serialNumber: _serialNumberController.text,
        issue: _issueController.text,
        status: RepairStatus.waiting_drop,
        estimatedPrice: double.tryParse(_estimatedPriceController.text),
        createdAt: DateTime.now(),
      );

      await _repairService.createRepair(repair);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réparation créée avec succès')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la création de la réparation: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle réparation'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              
              const Text(
                'Informations client',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientIdController,
                decoration: const InputDecoration(
                  labelText: 'ID du client',
                  hintText: 'Entrez l\'ID du client',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'ID du client';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du client',
                  hintText: 'Entrez le nom du client',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du client';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              const Text(
                'Informations sur l\'appareil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Type d\'appareil',
                  hintText: 'Ex: Ordinateur portable, Smartphone...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.devices),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le type d\'appareil';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marque',
                  hintText: 'Ex: Dell, Apple, Samsung...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la marque';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modèle',
                  hintText: 'Ex: XPS 15, MacBook Pro, Galaxy S21...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.laptop),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le modèle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de série (optionnel)',
                  hintText: 'Ex: SN1234567890',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text(
                'Problème et estimation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issueController,
                decoration: const InputDecoration(
                  labelText: 'Description du problème',
                  hintText: 'Décrivez le problème rencontré par le client',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.error_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez décrire le problème';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _estimatedPriceController,
                decoration: const InputDecoration(
                  labelText: 'Prix estimé (optionnel)',
                  hintText: 'Ex: 150.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                  suffixText: '€',
                ),
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Créer la réparation',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
