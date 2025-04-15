import 'package:flutter/material.dart';
import '../../../models/repair_model.dart';
import '../../../models/client_model.dart';
import '../../../services/admin_service.dart';
import '../../../theme/app_theme.dart';

/// Dialogue pour créer une nouvelle réparation
class CreateRepairDialog extends StatefulWidget {
  final AdminService adminService;
  final Function onRepairCreated;

  const CreateRepairDialog({
    super.key,
    required this.adminService,
    required this.onRepairCreated,
  });

  @override
  State<CreateRepairDialog> createState() => _CreateRepairDialogState();
}

class _CreateRepairDialogState extends State<CreateRepairDialog> {
  // Pour la sélection du client
  ClientModel? selectedClient;
  TextEditingController clientSearchController = TextEditingController();
  bool showNewClientForm = false;
  
  // Pour le nouveau client
  TextEditingController newClientFirstNameController = TextEditingController();
  TextEditingController newClientLastNameController = TextEditingController();
  TextEditingController newClientEmailController = TextEditingController();
  TextEditingController newClientPhoneController = TextEditingController();
  TextEditingController newClientPasswordController = TextEditingController();
  TextEditingController newClientPasswordConfirmController = TextEditingController();
  
  // Pour les informations de l'appareil
  TextEditingController deviceTypeController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController issueController = TextEditingController();
  TextEditingController devicePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer une nouvelle réparation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section de sélection du client
            _buildClientSection(),
            const SizedBox(height: 16),
            
            // Section des informations de l'appareil
            _buildDeviceSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _handleCreateRepair,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Créer la réparation'),
        ),
      ],
    );
  }

  /// Construire la section de sélection du client
  Widget _buildClientSection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Sélection du client',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          
          // Onglets pour choisir entre client existant et nouveau client
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !showNewClientForm ? AppTheme.primaryColor : Colors.grey[300],
                    foregroundColor: !showNewClientForm ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      showNewClientForm = false;
                    });
                  },
                  child: const Text('Client existant'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showNewClientForm ? AppTheme.primaryColor : Colors.grey[300],
                    foregroundColor: showNewClientForm ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      showNewClientForm = true;
                      selectedClient = null;
                    });
                  },
                  child: const Text('Nouveau client'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Afficher le formulaire approprié
          if (!showNewClientForm)
            _buildExistingClientForm()
          else
            _buildNewClientForm(),
        ],
      ),
    );
  }

  /// Construire le formulaire pour sélectionner un client existant
  Widget _buildExistingClientForm() {
    return FutureBuilder<List<ClientModel>>(
      future: widget.adminService.getAllClients(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final clients = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rechercher un client existant:'),
            const SizedBox(height: 8),
            
            // Champ de recherche autocomplété
            Autocomplete<ClientModel>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return clients;
                }
                return clients.where((ClientModel client) =>
                  client.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                  client.email.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                  client.phoneNumber.toLowerCase().contains(textEditingValue.text.toLowerCase())
                );
              },
              displayStringForOption: (ClientModel client) => "${client.name} (${client.email})",
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                clientSearchController = controller;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Nom, email ou téléphone',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.clear();
                            setState(() {
                              selectedClient = null;
                            });
                          },
                        )
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              },
              onSelected: (ClientModel selection) {
                setState(() {
                  selectedClient = selection;
                });
              },
            ),
            
            // Afficher les informations du client sélectionné
            if (selectedClient != null)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client sélectionné: ${selectedClient!.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Email: ${selectedClient!.email}'),
                          Text('Téléphone: ${selectedClient!.phoneNumber}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Suggestion de création si le client n'est pas trouvé
            if (selectedClient == null && clientSearchController.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Client non trouvé. Voulez-vous créer un nouveau client?'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNewClientForm = true;
                          // Pré-remplir le nom si possible
                          String fullName = clientSearchController.text.split(' (').first.trim();
                          List<String> nameParts = fullName.split(' ');
                          if (nameParts.length > 1) {
                            newClientFirstNameController.text = nameParts[0];
                            newClientLastNameController.text = nameParts.sublist(1).join(' ');
                          } else {
                            newClientFirstNameController.text = fullName;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Créer un client'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// Construire le formulaire pour créer un nouveau client
  Widget _buildNewClientForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations du nouveau client:'),
        const SizedBox(height: 8),
        
        // Prénom et nom
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newClientFirstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: newClientLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Email et téléphone
        TextField(
          controller: newClientEmailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: newClientPhoneController,
          decoration: const InputDecoration(
            labelText: 'Téléphone *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        
        // Mot de passe
        TextField(
          controller: newClientPasswordController,
          decoration: const InputDecoration(
            labelText: 'Mot de passe *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: newClientPasswordConfirmController,
          decoration: const InputDecoration(
            labelText: 'Confirmer le mot de passe *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 8),
        const Text(
          '* Champs obligatoires',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ],
    );
  }

  /// Construire la section des informations de l'appareil
  Widget _buildDeviceSection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Informations de l\'appareil',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          
          // Type d'appareil (obligatoire)
          TextField(
            controller: deviceTypeController,
            decoration: InputDecoration(
              labelText: 'Type d\'appareil *',
              hintText: 'Ex: Ordinateur portable, Smartphone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.devices),
            ),
          ),
          const SizedBox(height: 12),
          
          // Marque et modèle
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: brandController,
                  decoration: InputDecoration(
                    labelText: 'Marque',
                    hintText: 'Ex: Dell, Apple',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: modelController,
                  decoration: InputDecoration(
                    labelText: 'Modèle',
                    hintText: 'Ex: XPS 15, MacBook Pro',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Numéro de série
          TextField(
            controller: serialNumberController,
            decoration: InputDecoration(
              labelText: 'Numéro de série',
              hintText: 'Numéro de série de l\'appareil',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.confirmation_number),
            ),
          ),
          const SizedBox(height: 12),
          
          // Description du problème (obligatoire)
          TextField(
            controller: issueController,
            decoration: InputDecoration(
              labelText: 'Description du problème *',
              hintText: 'Décrivez le problème rencontré avec l\'appareil',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.error_outline),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          
          // Mot de passe de la machine
          TextField(
            controller: devicePasswordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe de la machine',
              hintText: 'Laisser vide si aucun',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          const Text(
            '* Champs obligatoires',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Gérer la création d'une réparation
  void _handleCreateRepair() async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Validation en cours...'),
              ],
            ),
          ),
        );
      },
    );
    
    // Attendre un court instant pour que le dialogue s'affiche
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      // 1. Validation du client
      String? clientId;
      String? clientName;
      
      if (selectedClient != null) {
        // Client existant sélectionné
        clientId = selectedClient!.id;
        clientName = selectedClient!.name;
      } else if (showNewClientForm) {
        // Vérification des champs du nouveau client
        if (newClientFirstNameController.text.isEmpty || 
            newClientLastNameController.text.isEmpty || 
            newClientEmailController.text.isEmpty || 
            newClientPhoneController.text.isEmpty || 
            newClientPasswordController.text.isEmpty) {
          Navigator.of(context).pop(); // Fermer le dialogue de chargement
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez remplir tous les champs du nouveau client'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // Vérification du format de l'email
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(newClientEmailController.text.trim())) {
          Navigator.of(context).pop(); // Fermer le dialogue de chargement
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez saisir un email valide'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        if (newClientPasswordController.text != newClientPasswordConfirmController.text) {
          Navigator.of(context).pop(); // Fermer le dialogue de chargement
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Les mots de passe ne correspondent pas'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else {
        // Aucun client sélectionné
        Navigator.of(context).pop(); // Fermer le dialogue de chargement
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un client ou créer un nouveau client'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // 2. Validation des informations de l'appareil
      if (deviceTypeController.text.isEmpty) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez spécifier le type d\'appareil'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (issueController.text.isEmpty) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez décrire le problème rencontré'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // 3. Création de la réparation
      try {
        // Création du client si nécessaire
        if (showNewClientForm) {
          // Création d'un nouveau client
          final newClient = await widget.adminService.createClient(
            name: "${newClientFirstNameController.text.trim()} ${newClientLastNameController.text.trim()}",
            email: newClientEmailController.text.trim(),
            phoneNumber: newClientPhoneController.text.trim(),
            password: newClientPasswordController.text.trim(),
          );
          clientId = newClient.id;
          clientName = newClient.name;
        }
        
        // Création de la réparation
        final RepairModel newRepair = RepairModel(
          id: '',
          clientId: clientId!,
          clientName: clientName!,
          deviceType: deviceTypeController.text.trim(),
          brand: brandController.text.trim(),
          model: modelController.text.trim(),
          serialNumber: serialNumberController.text.trim(),
          issue: issueController.text.trim(),
          devicePassword: devicePasswordController.text.trim().isEmpty ? 'aucun' : devicePasswordController.text.trim(),
          photos: [],
          status: RepairStatus.waiting_drop,
          createdAt: DateTime.now(),
        );
        
        await widget.adminService.createRepair(newRepair);
        
        // Fermer le dialogue de chargement
        Navigator.of(context).pop();
        
        // Fermer le formulaire
        Navigator.of(context).pop();
        
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réparation créée avec succès pour $clientName'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Appeler la fonction de callback
        widget.onRepairCreated();
        
      } catch (e) {
        // Fermer le dialogue de chargement
        Navigator.of(context).pop();
        
        // Afficher un dialogue d'erreur plus détaillé et persistant
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur lors de la création de la réparation', 
                style: TextStyle(color: Colors.red),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('Détails de l\'erreur: $e'),
                    const SizedBox(height: 20),
                    const Text('Conseils de dépannage:'),
                    const SizedBox(height: 10),
                    const Text('1. Vérifiez que tous les champs obligatoires sont remplis'),
                    const Text('2. Vérifiez que le client existe dans la base de données'),
                    const Text('3. Vérifiez votre connexion internet'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Fermer'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur générale
      Navigator.of(context).pop();
      
      // Afficher un dialogue d'erreur plus détaillé et persistant
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur générale', 
              style: TextStyle(color: Colors.red),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Détails de l\'erreur: $e'),
                  const SizedBox(height: 20),
                  const Text('Conseils de dépannage:'),
                  const SizedBox(height: 10),
                  const Text('1. Vérifiez votre connexion internet'),
                  const Text('2. Vérifiez que l\'application est à jour'),
                  const Text('3. Contactez l\'administrateur système si le problème persiste'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Fermer'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
