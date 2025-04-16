import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../../services/repair_service.dart';
import '../../services/deposit_service.dart';
import '../../models/deposit_model.dart';
import '../../models/repair_model.dart';
import '../../widgets/deposit_qr_widget.dart';
import '../../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/auth_service.dart';

class ScanDeviceScreen extends StatefulWidget {
  const ScanDeviceScreen({super.key});

  @override
  State<ScanDeviceScreen> createState() => _ScanDeviceScreenState();
}

class _ScanDeviceScreenState extends State<ScanDeviceScreen> {
  bool _isTechnicianOrAdmin = false;

  final _repairIdController = TextEditingController();
  bool _isLoading = false;
  bool _isManualEntry = true;
  String? _errorMessage;
  String? _successMessage;
  DepositModel? _deposit; // Ajouté pour stocker le dépôt trouvé

  Future<void> _checkUserRole() async {
    final authService = provider.Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUserData();
    if (user != null && (user.userType == 'technicien' || user.userType == 'admin')) {
      setState(() {
        _isTechnicianOrAdmin = true;
      });
    } else {
      setState(() {
        _isTechnicianOrAdmin = false;
      });
    }
  }

  @override
  void dispose() {
    _repairIdController.dispose();
    super.dispose();
  }

  void _openQrScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 400,
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                Navigator.pop(context); // Ferme la pop-up
                setState(() {
                  _repairIdController.text = barcodes.first.rawValue!;
                });
                _verifyRepairId();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _verifyRepairId() async {
    final depositId = _repairIdController.text.trim();
    
    if (depositId.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez scanner un QR code ou saisir un identifiant valide.';
        _deposit = null;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _deposit = null;
    });
    
    try {
      final depositService = DepositService(Supabase.instance.client);
      final deposit = await depositService.getDepositByIdOrReference(depositId);
      if (deposit != null) {
        setState(() {
          _isLoading = false;
          _deposit = deposit;
          _successMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _deposit = null;
          _errorMessage = 'Aucun dépôt trouvé avec cet ID';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _deposit = null;
        _errorMessage = 'Erreur lors de la vérification: $e';
      });
    }
  }

  Future<void> _registerDeposit() async {
    if (_deposit == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final depositService = DepositService(Supabase.instance.client);
      await depositService.updateDepositStatus(_deposit!.id, 'received');
      setState(() {
        _isLoading = false;
        _successMessage = 'Dépôt enregistré avec succès !';
        _deposit = DepositModel(
          id: _deposit!.id,
          clientId: _deposit!.clientId,
          firstName: _deposit!.firstName,
          lastName: _deposit!.lastName,
          email: _deposit!.email,
          deviceType: _deposit!.deviceType,
          brand: _deposit!.brand,
          model: _deposit!.model,
          serialNumber: _deposit!.serialNumber ?? '',
          devicePassword: _deposit!.devicePassword,
          pointRelaisId: _deposit!.pointRelaisId,
          issue: _deposit!.issue,
          photoUrls: _deposit!.photoUrls,
          createdAt: _deposit!.createdAt,
          status: 'received',
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de l\'enregistrement du dépôt: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un appareil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Illustration ou icône
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  _isManualEntry ? Icons.edit_document : Icons.qr_code_scanner,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Titre et description
            Text(
              _isManualEntry ? 'Saisie manuelle' : 'Scanner un QR code',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _isManualEntry
                  ? 'Entrez l\'ID de réparation pour rechercher un appareil'
                  : 'Scannez le QR code sur l\'étiquette de l\'appareil',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Mode de saisie (manuel ou scan)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Saisie manuelle'),
                    icon: Icon(Icons.edit),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Scanner QR code'),
                    icon: Icon(Icons.qr_code_scanner),
                  ),
                ],
                selected: {_isManualEntry},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    _isManualEntry = selection.first;
                    _errorMessage = null;
                    _successMessage = null;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            
            // Champ de saisie manuelle ou bouton de scan
            ...(_isManualEntry
                ? [
                    TextField(
                      controller: _repairIdController,
                      decoration: InputDecoration(
                        labelText: 'ID de réparation',
                        hintText: 'Ex: REP123456',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) {
                        if (_errorMessage != null || _successMessage != null) {
                          setState(() {
                            _errorMessage = null;
                            _successMessage = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _verifyRepairId,
                      icon: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isLoading ? 'Recherche en cours...' : 'RECHERCHER'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ]
                : [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _openQrScanner(context),
                      icon: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.qr_code_scanner),
                      label: Text(_isLoading ? 'Scan en cours...' : 'SCANNER LE QR CODE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ]),
            
            const SizedBox(height: 24),
            
            // Messages d'erreur ou de succès
            ...(_errorMessage != null
                ? [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                : []),
            ...(_successMessage != null
                ? [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                : []),

            // Affichage fiche dépôt trouvée (code + QR)
            if (_deposit != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Dépôt trouvé', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      // Widget code + QR
                      DepositQrWidget(deposit: _deposit!),
                      const SizedBox(height: 16),
                      Text('Client : \\${_deposit!.firstName} \\${_deposit!.lastName}'),
                      Text('Appareil : \\${_deposit!.deviceType} - \\${_deposit!.brand} \\${_deposit!.model}'),
                      // Ajoute d'autres infos si besoin
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
