import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RepairQrConfirmationScreen extends StatelessWidget {
  final String repairId;
  const RepairQrConfirmationScreen({Key? key, required this.repairId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation du dépôt')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Votre demande de dépôt a bien été enregistrée !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            QrImage(
              data: repairId,
              version: QrVersions.auto,
              size: 220.0,
            ),
            const SizedBox(height: 24),
            const Text(
              'Présentez ce QR code au point relais lors du dépôt de votre appareil.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
