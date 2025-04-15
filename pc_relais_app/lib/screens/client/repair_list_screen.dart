import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/repair_model.dart';
import '../../services/repair_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';

class RepairListScreen extends StatefulWidget {
  const RepairListScreen({super.key});

  @override
  State<RepairListScreen> createState() => _RepairListScreenState();
}

class _RepairListScreenState extends State<RepairListScreen> {
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
      final repairs = await _repairService.getClientRepairs();
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
        title: const Text('Mes réparations'),
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
        onPressed: () => context.push('/client/repairs/new'),
        label: const Text('Nouvelle réparation'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.computer_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune réparation en cours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas encore de réparation en cours',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'NOUVELLE RÉPARATION',
            icon: Icons.add,
            onPressed: () => context.push('/client/repairs/new'),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _repairs.length,
      itemBuilder: (context, index) {
        final repair = _repairs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => context.push('/client/repairs/${repair.id}'),
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
                    'Problème: ${repair.issue}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.push('/client/repairs/${repair.id}'),
                        icon: const Icon(Icons.visibility),
                        label: const Text('DÉTAILS'),
                      ),
                      if (repair.status == RepairStatus.ready_for_pickup)
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Implémenter la logique pour récupérer l'appareil
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('RÉCUPÉRER'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
