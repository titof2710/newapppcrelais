import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/technicien_affectation_service.dart';
import '../../services/auth_service.dart';

class TechnicienAffectationScreen extends StatefulWidget {
  final UserModel technicien;
  const TechnicienAffectationScreen({Key? key, required this.technicien}) : super(key: key);

  @override
  State<TechnicienAffectationScreen> createState() => _TechnicienAffectationScreenState();
}

class _TechnicienAffectationScreenState extends State<TechnicienAffectationScreen> {
  late final TechnicienAffectationService _affectationService;
  List<UserModel> _allPointRelais = [];
  List<String> _assignedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final client = Provider.of<AuthService>(context, listen: false)._supabaseService.client;
    _affectationService = TechnicienAffectationService(client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final all = await _affectationService.getAllPointRelais();
    final assigned = await _affectationService.getAssignedPointRelaisIds(widget.technicien.id);
    setState(() {
      _allPointRelais = all;
      _assignedIds = assigned;
      _isLoading = false;
    });
  }

  Future<void> _onAffectationChanged(String pointRelaisId, bool value) async {
    setState(() => _isLoading = true);
    if (value) {
      await _affectationService.assignTechnicienToPointRelais(widget.technicien.id, pointRelaisId);
    } else {
      await _affectationService.unassignTechnicienFromPointRelais(widget.technicien.id, pointRelaisId);
    }
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Affecter à ${widget.technicien.name}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _allPointRelais.map((pr) {
                final isAssigned = _assignedIds.contains(pr.id);
                return CheckboxListTile(
                  title: Text(pr.name),
                  subtitle: Text(pr.email),
                  value: isAssigned,
                  onChanged: (val) => _onAffectationChanged(pr.id, val ?? false),
                );
              }).toList(),
            ),
    );
  }
}
