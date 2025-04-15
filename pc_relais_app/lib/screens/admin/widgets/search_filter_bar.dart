import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Barre de recherche et de filtrage pour les réparations
class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final String filterStatus;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.filterStatus,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une réparation...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: searchQuery.length),
              ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 8),
          
          // Filtres de statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Filtrer par statut: '),
                const SizedBox(width: 8),
                _buildFilterChip('Tous', 'all'),
                _buildFilterChip('En attente', 'pending'),
                _buildFilterChip('En attente de dépôt', 'waiting_drop'),
                _buildFilterChip('Réparation en cours', 'in_progress'),
                _buildFilterChip('Diagnostiqué', 'diagnosed'),
                _buildFilterChip('Attente pièces', 'waiting_for_parts'),
                _buildFilterChip('Terminée', 'completed'),
                _buildFilterChip('Prêt pour retrait', 'ready_for_pickup'),
                _buildFilterChip('Récupéré', 'picked_up'),
                _buildFilterChip('Annulé', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construire une puce de filtre
  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: filterStatus == value,
        onSelected: (selected) {
          onFilterChanged(selected ? value : 'all');
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }
}
