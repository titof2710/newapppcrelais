import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/repair_model.dart';
import '../../services/repair_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';

class RelayRepairsScreen extends StatefulWidget {
  const RelayRepairsScreen({super.key});

  @override
  State<RelayRepairsScreen> createState() => _RelayRepairsScreenState();
}

class _RelayRepairsScreenState extends State<RelayRepairsScreen> {
  late final RepairService _repairService;
  bool _isLoading = true;
  List<RepairModel> _repairs = [];

  @override
  void initState() {
    super.initState();
    _repairService = Provider.of<RepairService>(context, listen: false);
    _loadRepairs();
  }

  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repairs = await _repairService.getRelayRepairs();
      setState(() {
        _repairs = repairs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des réparations: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: const Text('Réparations en point relais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRepairs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _repairs.isEmpty
              ? _buildEmptyState()
              : _buildRepairList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/point_relais/scan'),
        label: const Text('Scanner un appareil'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun appareil en point relais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas d\'appareils en attente de dépôt ou de retrait',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'SCANNER UN APPAREIL',
            icon: Icons.qr_code_scanner,
            onPressed: () => context.push('/point_relais/scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairList() {
    // Trier les réparations par statut
    final waitingForDropOff = _repairs.where((r) => r.status == RepairStatus.waitingForDropOff).toList();
    final atRelay = _repairs.where((r) => r.status == RepairStatus.atRelay).toList();
    final droppedOff = _repairs.where((r) => r.status == RepairStatus.droppedOff).toList();
    final others = _repairs.where((r) => 
      r.status != RepairStatus.waitingForDropOff && 
      r.status != RepairStatus.atRelay &&
      r.status != RepairStatus.droppedOff
    ).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (waitingForDropOff.isNotEmpty) ...[
          _buildSectionHeader('En attente de dépôt', Icons.arrow_downward),
          ...waitingForDropOff.map((repair) => _buildRepairCard(repair)),
          const SizedBox(height: 16),
        ],
        if (atRelay.isNotEmpty) ...[
          _buildSectionHeader('Prêts pour récupération', Icons.arrow_upward),
          ...atRelay.map((repair) => _buildRepairCard(repair)),
          const SizedBox(height: 16),
        ],
        if (droppedOff.isNotEmpty) ...[
          _buildSectionHeader('Déposés au point relais', Icons.check_circle),
          ...droppedOff.map((repair) => _buildRepairCard(repair)),
          const SizedBox(height: 16),
        ],
        if (others.isNotEmpty) ...[
          _buildSectionHeader('Autres', Icons.devices),
          ...others.map((repair) => _buildRepairCard(repair)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCard(RepairModel repair) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/point_relais/repairs/${repair.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${repair.brand} ${repair.model}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: repair.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${repair.deviceType}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'N° série: ${repair.serialNumber}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/point_relais/repairs/${repair.id}'),
                    icon: const Icon(Icons.visibility),
                    label: const Text('DÉTAILS'),
                  ),
                  if (repair.status == RepairStatus.waitingForDropOff)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implémenter la logique pour enregistrer le dépôt
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('DÉPÔT'),
                    ),
                  if (repair.status == RepairStatus.atRelay)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implémenter la logique pour enregistrer le retrait
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('RETRAIT'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
