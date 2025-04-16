import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/technicien_affectation_service.dart';
import '../../services/auth_service.dart';

class MyPointRelaisScreen extends StatefulWidget {
  final String technicienId;
  const MyPointRelaisScreen({Key? key, required this.technicienId}) : super(key: key);

  @override
  State<MyPointRelaisScreen> createState() => _MyPointRelaisScreenState();
}

class _MyPointRelaisScreenState extends State<MyPointRelaisScreen> {
  late final TechnicienAffectationService _affectationService;
  List<UserModel> _myPointRelais = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _affectationService = TechnicienAffectationService(client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await _affectationService.getMyPointRelais(widget.technicienId);
    setState(() {
      _myPointRelais = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes points relais')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _myPointRelais
                  .map((pr) => ListTile(
                        title: Text(pr.name),
                        subtitle: Text(pr.email),
                      ))
                  .toList(),
            ),
    );
  }
}
