import 'package:flutter/material.dart';

class RepairQrConfirmationScreen extends StatelessWidget {
  final String repairId;
  const RepairQrConfirmationScreen({Key? key, required this.repairId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Réparation créée avec succès !'),
            const SizedBox(height: 24),
            Text('ID Réparation : $repairId'),
            // Ici tu pourrais ajouter un widget QR code si besoin
          ],
        ),
      ),
    );
  }
}
