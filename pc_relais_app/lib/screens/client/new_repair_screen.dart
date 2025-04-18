import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/repair_model.dart';
import '../../models/deposit_model.dart';
import '../../models/user_model.dart';
import '../../models/point_relais_model.dart';
import '../../services/auth_service.dart';
import '../../services/repair_service.dart';
import '../../services/deposit_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../confirmation/repair_qr_confirmation_screen.dart';

class NewRepairScreen extends StatefulWidget {
  const NewRepairScreen({super.key});

  @override
  State<NewRepairScreen> createState() => _NewRepairScreenState();
}

class _NewRepairScreenState extends State<NewRepairScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceTypeController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _devicePasswordController = TextEditingController();

  // Nouveaux contrôleurs et variables pour les champs ajoutés
  String? _selectedOS;
  final List<String> _osList = [
    'Windows', 'MacOS', 'Linux', 'Android', 'iOS', 'Autre'
  ];
  final _accessoriesController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _depositDate = DateTime.now();

  String? _selectedDeviceType;
  final List<String> _deviceTypes = [
    'Smartphone',
    'PC',
    'Tablette',
    'Autre',
  ];
  bool _showDevicePasswordField = false; // Pour afficher le champ mot de passe selon le type
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
  late final DepositService _depositService; // Ajouté

  @override
  void initState() {
    super.initState();
    _authService = provider.Provider.of<AuthService>(context, listen: false);
    _repairService = provider.Provider.of<RepairService>(context, listen: false);
    _depositService = DepositService(Supabase.instance.client); // Utilise le client central
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
    setState(() { _isLoading = true; });
    try {
      // Authentification utilisateur (pour lier les photos à l'utilisateur)
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? 'anonymous';
      final storageService = StorageService(client: Supabase.instance.client);
      List<String> uploadedPhotoUrls = [];
      for (var image in _selectedImages) {
        final url = await storageService.uploadImage(image, userId);
        uploadedPhotoUrls.add(url);
      }

      if (!_formKey.currentState!.validate()) {
        setState(() { _isLoading = false; });
        return;
      }

      final userData = await _authService.getCurrentUserData();
      if (userData == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier qu'un point relais est sélectionné
      if (_selectedPointRelais == null) {
        throw Exception('Veuillez sélectionner un point relais');
      }
      
      final isUuid = DepositModel.isValidUuid(userData.uuid);
      final deposit = DepositModel(
        clientId: isUuid ? userData.uuid : null,
        firebaseClientId: !isUuid ? userData.uuid : null,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        deviceType: _selectedDeviceType ?? '',
        brand: _brandController.text,
        model: _modelController.text,
        serialNumber: _serialNumberController.text,
        devicePassword: _devicePasswordController.text,
        os: _selectedOS ?? '',
        accessories: _accessoriesController.text,
        notes: _notesController.text,
        depositDate: _depositDate,
        pointRelaisId: _selectedPointRelais!.uuid,
        issue: _issueController.text,
        photoUrls: uploadedPhotoUrls,
      );

      final depositId = await _depositService.createDeposit(deposit);

      // Naviguer vers l'écran de QR code de confirmation après la création
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RepairQrConfirmationScreen(repairId: depositId),
            ),
          );
        }
      });
      final repair = RepairModel(
        clientEmail: '',
        clientId: userData.uuid,
        clientName: _firstNameController.text.trim() + ' ' + _lastNameController.text.trim(),
        deviceType: _deviceTypeController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        serialNumber: _serialNumberController.text.trim(),
        issue: _issueController.text.trim(),
        status: RepairStatus.waiting_drop,
        // Ajoute les autres champs requis par RepairModel ici
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
      setState(() { _isLoading = false; });
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
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Type d\'appareil *',
              border: OutlineInputBorder(),
            ),
            value: _selectedDeviceType,
            items: _deviceTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDeviceType = newValue;
                _showDevicePasswordField = newValue == 'PC' || newValue == 'Smartphone' || newValue == 'Tablette';
              });
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Veuillez sélectionner un type d\'appareil'
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _brandController,
            label: 'Marque *',
            validator: Validators.notEmpty,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _modelController,
            label: 'Modèle *',
            validator: Validators.notEmpty,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _serialNumberController,
            label: 'Numéro de série',
          ),
          if (_showDevicePasswordField) ...[
            const SizedBox(height: 16),
            CustomTextField(
              controller: _devicePasswordController,
              label: 'Mot de passe de l\'appareil (si applicable)',
              obscureText: true,
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Système d\'exploitation',
              border: OutlineInputBorder(),
            ),
            value: _selectedOS,
            items: _osList.map((String os) {
              return DropdownMenuItem<String>(
                value: os,
                child: Text(os),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedOS = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _accessoriesController,
            label: 'Accessoires fournis',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _firstNameController,
            label: 'Prénom *',
            validator: Validators.notEmpty,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _lastNameController,
            label: 'Nom *',
            validator: Validators.notEmpty,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email *',
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const Text(
            'Point relais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _loadingPointRelais
              ? const Center(child: CircularProgressIndicator())
              : _pointRelaisList.isEmpty
                  ? const Text('Aucun point relais disponible')
                  : DropdownButtonFormField<PointRelaisModel>(
                      decoration: const InputDecoration(
                        labelText: 'Point relais *',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedPointRelais,
                      items: _pointRelaisList.map((PointRelaisModel pr) {
                        return DropdownMenuItem<PointRelaisModel>(
                          value: pr,
                          child: Text(pr.address != null && pr.address!.isNotEmpty
                              ? '${pr.name} - ${pr.address}'
                              : pr.name),
                        );
                      }).toList(),
                      onChanged: (PointRelaisModel? newValue) {
                        setState(() {
                          _selectedPointRelais = newValue;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Veuillez sélectionner un point relais'
                          : null,
                    ),
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
          label: 'Décrivez le problème en détail *',
          maxLines: 5,
          validator: Validators.notEmpty,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _notesController,
          label: 'Notes additionnelles',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseils pour une description efficace',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Soyez précis sur les symptômes du problème',
                ),
                Text(
                  '• Indiquez quand le problème a commencé',
                ),
                Text(
                  '• Mentionnez si le problème est intermittent ou constant',
                ),
                Text(
                  '• Décrivez toute tentative de réparation déjà effectuée',
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
          'Ajoutez des photos de l\'appareil pour aider nos techniciens à mieux comprendre le problème.',
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Ajouter des photos'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedImages.isNotEmpty) ...[
          const Text(
            'Photos sélectionnées:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: kIsWeb
                          ? Image.network(
                              _selectedImages[index].path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_selectedImages[index].path),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 5,
                      right: 13,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
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
