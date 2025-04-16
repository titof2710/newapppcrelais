import 'package:flutter/material.dart';

class PointRelaisDashboard extends StatelessWidget {
  const PointRelaisDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 60, color: Theme.of(context).primaryColor),
          SizedBox(height: 16),
          Text(
            'Bienvenue sur l\'espace Point Relais',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Gérez vos réparations et votre stockage depuis cet écran.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
