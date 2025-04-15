import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/repair_service.dart';
import '../../theme/app_theme.dart';

class ScanDeviceScreen extends StatefulWidget {
  const ScanDeviceScreen({super.key});

  @override
  State<ScanDeviceScreen> createState() => _ScanDeviceScreenState();
}

class _ScanDeviceScreenState extends State<ScanDeviceScreen> {
  final _repairIdController = TextEditingController();
  bool _isLoading = false;
  bool _isManualEntry = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _repairIdController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    // Simuler le scan d'un QR code
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Dans une implémentation réelle, cela serait remplacé par un vrai scanner de QR code
      await Future.delayed(const Duration(seconds: 2));
      
      // Simuler un ID de réparation obtenu par le scan
      const scannedId = 'REP123456';
      
      setState(() {
        _repairIdController.text = scannedId;
        _isLoading = false;
      });
      
      // Vérifier automatiquement l'ID scanné
      _verifyRepairId();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du scan: $e';
      });
    }
  }

  Future<void> _verifyRepairId() async {
    final repairId = _repairIdController.text.trim();
    
    if (repairId.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un ID de réparation';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      final repairService = Provider.of<RepairService>(context, listen: false);
      
      // Vérifier si la réparation existe
      final repair = await repairService.getRepairById(repairId);
      
      if (repair != null) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Réparation trouvée: ${repair.deviceType} ${repair.brand} ${repair.model}';
        });
        
        // Naviguer vers les détails de la réparation après un court délai
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/point_relais/repairs/details',
              arguments: repairId,
            );
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Aucune réparation trouvée avec cet ID';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de la vérification: $e';
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
            SegmentedButton<bool>(
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
            
            const SizedBox(height: 32),
            
            // Champ de saisie manuelle ou bouton de scan
            if (_isManualEntry) ...[
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
                  // Effacer les messages d'erreur/succès lors de la saisie
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
            ] else ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _scanQRCode,
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
            ],
            
            const SizedBox(height: 24),
            
            // Messages d'erreur ou de succès
            if (_errorMessage != null)
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
            
            if (_successMessage != null)
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
          ],
        ),
      ),
    );
  }
}
