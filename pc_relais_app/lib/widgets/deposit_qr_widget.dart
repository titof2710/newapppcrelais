import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/deposit_model.dart';

class DepositQrWidget extends StatelessWidget {
  final DepositModel deposit;
  const DepositQrWidget({Key? key, required this.deposit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Code dépôt :',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SelectableText(
          deposit.code,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        QrImageView(
          data: deposit.code,
          version: QrVersions.auto,
          size: 160,
          gapless: false,
        ),
      ],
    );
  }
}
