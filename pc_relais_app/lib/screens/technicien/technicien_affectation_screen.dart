import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class TechnicienAffectationScreen extends StatelessWidget {
  final UserModel technicien;
  const TechnicienAffectationScreen({Key? key, required this.technicien}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Affectation de ${technicien.name ?? technicien.email ?? ''}')),
      body: Center(
        child: Text('Gestion des affectations pour ${technicien.name ?? technicien.email ?? ''}'),
      ),
    );
  }
}
