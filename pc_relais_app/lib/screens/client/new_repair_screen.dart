import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/repair_model.dart';
import '../../models/user_model.dart';
import '../../models/point_relais_model.dart';
import '../../services/auth_service.dart';
import '../../services/repair_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class NewRepairScreen extends StatefulWidget {
  const NewRepairScreen({super.key});

  @override
  State<NewRepairScreen> createState() => _NewRepairScreenState();
}

class _NewRepairScreenState extends State<NewRepairScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceTypeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _issueController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  int _currentStep = 0;
  
  // Pour la sélection du point relais
  PointRelaisModel? _selectedPointRelais;
  List<PointRelaisModel> _pointRelaisList = [];
  bool _loadingPointRelais = false;

  late final AuthService _authService;
  late final RepairService _repairService;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _repairService = Provider.of<RepairService>(context, listen: false);
    _loadPointRelais();
  }
  
  // Charger la liste des points relais
  Future<void> _loadPointRelais() async {
    setState(() {
      _loadingPointRelais = true;
    });
    
    try {
      final pointRelais = await _authService.getNearbyPointRelais();
      setState(() {
        _pointRelaisList = pointRelais;
        if (pointRelais.isNotEmpty) {
          _selectedPointRelais = pointRelais.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des points relais: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loadingPointRelais = false;
      });
    }
  }

  @override
  void dispose() {
    _deviceTypeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection des images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitRepair() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUserData();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // TODO: Implémenter le téléchargement des images vers Firebase Storage
      // Pour l'instant, nous allons simplement créer la réparation sans images

      // Vérifier qu'un point relais est sélectionné
      if (_selectedPointRelais == null) {
        throw Exception('Veuillez sélectionner un point relais');
      }
      
      final repair = RepairModel(
        clientId: user.id,
        clientName: user.name,
        pointRelaisId: _selectedPointRelais!.id, // Ajout de l'ID du point relais
        deviceType: _deviceTypeController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        serialNumber: _serialNumberController.text.trim(),
        issue: _issueController.text.trim(),
        status: RepairStatus.waiting_drop,
      );

      await _repairService.createRepair(repair);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande de réparation créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/client/repairs');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la réparation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        title: const Text('Nouvelle réparation'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            _submitRepair();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: _currentStep < 2 ? 'CONTINUER' : 'SOUMETTRE',
                    onPressed: details.onStepContinue!,
                    isLoading: _isLoading && _currentStep == 2,
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'RETOUR',
                      onPressed: details.onStepCancel!,
                      type: ButtonType.outline,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Appareil'),
            content: _buildDeviceInfoStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Problème'),
            content: _buildIssueStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Photos'),
            content: _buildPhotosStep(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations sur l\'appareil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _deviceTypeController,
            label: 'Type d\'appareil',
            hint: 'PC Portable, PC Fixe, etc.',
            prefixIcon: const Icon(Icons.computer),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez indiquer le type d\'appareil';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _brandController,
            label: 'Marque',
            hint: 'HP, Dell, Asus, etc.',
            prefixIcon: const Icon(Icons.business),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez indiquer la marque';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _modelController,
            label: 'Modèle',
            hint: 'Pavilion, XPS, ROG, etc.',
            prefixIcon: const Icon(Icons.laptop),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez indiquer le modèle';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _serialNumberController,
            label: 'Numéro de série (optionnel)',
            hint: 'Généralement sous l\'appareil ou dans les paramètres système',
            prefixIcon: const Icon(Icons.numbers),
          ),
          const SizedBox(height: 24),
          
          // Section de sélection du point relais
          const Text(
            'Point relais pour le dépôt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _loadingPointRelais
              ? const Center(child: CircularProgressIndicator())
              : _pointRelaisList.isEmpty
                  ? const Text('Aucun point relais disponible dans votre région')
                  : DropdownButtonFormField<PointRelaisModel>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                        labelText: 'Choisir un point relais',
                      ),
                      value: _selectedPointRelais,
                      items: _pointRelaisList.map((pointRelais) {
                        return DropdownMenuItem<PointRelaisModel>(
                          value: pointRelais,
                          child: Text(pointRelais.shopName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPointRelais = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un point relais';
                        }
                        return null;
                      },
                    ),
          const SizedBox(height: 16),
          if (_selectedPointRelais != null) ...[  
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations sur le point relais',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Adresse: ${_selectedPointRelais!.shopAddress}'),
                    Text('Horaires: ${_selectedPointRelais!.openingHours.join(', ')}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIssueStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description du problème',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _issueController,
          label: 'Problème rencontré',
          hint: 'Décrivez en détail le problème que vous rencontrez avec votre appareil',
          prefixIcon: const Icon(Icons.error_outline),
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez décrire le problème';
            }
            if (value.length < 10) {
              return 'Veuillez fournir une description plus détaillée';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseils pour une bonne description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Soyez précis sur les symptômes (écran noir, bruit anormal, etc.)',
                ),
                Text(
                  '• Indiquez depuis quand le problème existe',
                ),
                Text(
                  '• Mentionnez si le problème est intermittent ou permanent',
                ),
                Text(
                  '• Précisez les solutions que vous avez déjà essayées',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos de l\'appareil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ajoutez des photos pour aider le technicien à mieux comprendre le problème (optionnel)',
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'AJOUTER DES PHOTOS',
          icon: Icons.photo_library,
          onPressed: _pickImages,
          type: ButtonType.outline,
        ),
        const SizedBox(height: 16),
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récapitulatif',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Après avoir soumis votre demande, veuillez déposer votre appareil au point relais sélectionné. Le point relais validera le dépôt et vous recevrez une notification dès que votre appareil sera pris en charge par nos techniciens.',
                ),
                SizedBox(height: 8),
                Text(
                  'Un diagnostic complet sera effectué et un devis vous sera envoyé pour approbation avant toute réparation.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
