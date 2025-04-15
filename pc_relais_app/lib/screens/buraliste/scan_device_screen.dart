import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/repair_service.dart';
import '../../widgets/custom_button.dart';

class ScanDeviceScreen extends StatefulWidget {
  const ScanDeviceScreen({super.key});

  @override
  State<ScanDeviceScreen> createState() => _ScanDeviceScreenState();
}

class _ScanDeviceScreenState extends State<ScanDeviceScreen> {
  final _repairIdController = TextEditingController();
  bool _isLoading = false;
  bool _isScanning = false;

  late final RepairService _repairService;

  @override
  void initState() {
    super.initState();
    _repairService = Provider.of<RepairService>(context, listen: false);
  }

  @override
  void dispose() {
    _repairIdController.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Simuler un scan de QR code
      await Future.delayed(const Duration(seconds: 2));
      
      // Dans une application réelle, vous utiliseriez un plugin comme qr_code_scanner
      // pour scanner le QR code et obtenir l'ID de réparation
      final repairId = 'REP-${DateTime.now().millisecondsSinceEpoch}';
      
      setState(() {
        _repairIdController.text = repairId;
        _isScanning = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _verifyRepair() async {
    final repairId = _repairIdController.text.trim();
    if (repairId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez scanner ou saisir un ID de réparation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repair = await _repairService.getRepairById(repairId);
      
      if (mounted) {
        if (repair != null) {
          context.push('/point_relais/repairs/$repairId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réparation non trouvée'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la vérification: $e'),
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
        title: const Text('Scanner un appareil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Scannez le QR code de l\'appareil ou saisissez manuellement l\'ID de réparation',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isScanning
                  ? _buildScanningView()
                  : _buildManualInputView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Scan en cours...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'ANNULER',
          onPressed: () {
            setState(() {
              _isScanning = false;
            });
          },
          type: ButtonType.outline,
        ),
      ],
    );
  }

  Widget _buildManualInputView() {
    return Column(
      children: [
        TextField(
          controller: _repairIdController,
          decoration: InputDecoration(
            labelText: 'ID de réparation',
            hintText: 'Saisissez l\'ID de réparation',
            prefixIcon: const Icon(Icons.tag),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'SCANNER QR CODE',
                icon: Icons.qr_code_scanner,
                onPressed: _scanQrCode,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'VÉRIFIER',
                icon: Icons.search,
                onPressed: _verifyRepair,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment ça marche ?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Scannez le QR code sur l\'étiquette de l\'appareil ou le reçu du client',
                ),
                SizedBox(height: 4),
                Text(
                  '2. Vérifiez les informations de la réparation',
                ),
                SizedBox(height: 4),
                Text(
                  '3. Enregistrez le dépôt ou le retrait de l\'appareil',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
