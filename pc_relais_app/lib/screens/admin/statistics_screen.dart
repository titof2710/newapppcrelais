import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/repair_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

/// Écran des statistiques pour les administrateurs
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final AdminService _adminService = AdminService();
  
  List<RepairModel> _repairs = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final repairs = await _adminService.getAllRepairs();
      final statistics = await _adminService.getRepairStatistics();
      
      setState(() {
        _repairs = repairs;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildRepairStatusChart(),
                  const SizedBox(height: 24),
                  _buildMonthlyRepairsChart(),
                  const SizedBox(height: 24),
                  _buildDeviceTypeDistribution(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résumé',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              'Réparations totales',
              _statistics['totalRepairs'].toString(),
              Icons.build,
              Colors.blue,
            ),
            _buildStatCard(
              'Réparations terminées',
              _statistics['completedRepairs'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Réparations en cours',
              _statistics['inProgressRepairs'].toString(),
              Icons.pending_actions,
              Colors.orange,
            ),
            _buildStatCard(
              'Temps moyen (heures)',
              _statistics['averageRepairTimeHours'].toStringAsFixed(1),
              Icons.timer,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRepairStatusChart() {
    // Calculer les données pour le graphique
    final int completed = _statistics['completedRepairs'] as int;
    final int inProgress = _statistics['inProgressRepairs'] as int;
    final int pending = _statistics['pendingRepairs'] as int;
    final int total = _statistics['totalRepairs'] as int;
    
    final double completedPercentage = total > 0 ? (completed / total) * 100 : 0;
    final double inProgressPercentage = total > 0 ? (inProgress / total) * 100 : 0;
    final double pendingPercentage = total > 0 ? (pending / total) * 100 : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statut des réparations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: completedPercentage,
                  title: '${completedPercentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.blue,
                  value: inProgressPercentage,
                  title: '${inProgressPercentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: pendingPercentage,
                  title: '${pendingPercentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Terminées', Colors.green),
            const SizedBox(width: 24),
            _buildLegendItem('En cours', Colors.blue),
            const SizedBox(width: 24),
            _buildLegendItem('En attente', Colors.orange),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
  
  Widget _buildMonthlyRepairsChart() {
    // Calculer les données pour le graphique
    final Map<int, int> repairsByMonth = {};
    
    // Initialiser tous les mois à 0
    for (int i = 1; i <= 12; i++) {
      repairsByMonth[i] = 0;
    }
    
    // Compter les réparations par mois
    for (final repair in _repairs) {
      final month = repair.createdAt.month;
      repairsByMonth[month] = (repairsByMonth[month] ?? 0) + 1;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Réparations par mois',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: repairsByMonth.values.isEmpty
                  ? 10
                  : (repairsByMonth.values.reduce((a, b) => a > b ? a : b) * 1.2),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final month = _getMonthName(groupIndex + 1);
                    return BarTooltipItem(
                      '$month: ${rod.toY.round()}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final month = value.toInt() + 1;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          _getMonthAbbreviation(month),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const SideTitleWidget(
                          axisSide: AxisSide.left,
                          child: Text('0'),
                        );
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(value.toInt().toString()),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                12,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: repairsByMonth[index + 1]!.toDouble(),
                      color: AppTheme.primaryColor,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Janvier';
      case 2: return 'Février';
      case 3: return 'Mars';
      case 4: return 'Avril';
      case 5: return 'Mai';
      case 6: return 'Juin';
      case 7: return 'Juillet';
      case 8: return 'Août';
      case 9: return 'Septembre';
      case 10: return 'Octobre';
      case 11: return 'Novembre';
      case 12: return 'Décembre';
      default: return '';
    }
  }
  
  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Fév';
      case 3: return 'Mar';
      case 4: return 'Avr';
      case 5: return 'Mai';
      case 6: return 'Juin';
      case 7: return 'Juil';
      case 8: return 'Août';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Déc';
      default: return '';
    }
  }
  
  Widget _buildDeviceTypeDistribution() {
    // Calculer les données pour le graphique
    final Map<String, int> deviceTypeCounts = {};
    
    // Compter les réparations par type d'appareil
    for (final repair in _repairs) {
      final deviceType = repair.deviceType;
      deviceTypeCounts[deviceType] = (deviceTypeCounts[deviceType] ?? 0) + 1;
    }
    
    // Trier par nombre décroissant
    final sortedDeviceTypes = deviceTypeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Limiter à 5 types d'appareils les plus courants
    final topDeviceTypes = sortedDeviceTypes.take(5).toList();
    
    // Couleurs pour les différents types d'appareils
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Types d\'appareils',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        topDeviceTypes.isEmpty
            ? const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: List.generate(
                          topDeviceTypes.length,
                          (index) {
                            final deviceType = topDeviceTypes[index];
                            final percentage = deviceType.value / _repairs.length * 100;
                            
                            return PieChartSectionData(
                              color: colors[index % colors.length],
                              value: deviceType.value.toDouble(),
                              title: '${percentage.toStringAsFixed(1)}%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(
                      topDeviceTypes.length,
                      (index) {
                        final deviceType = topDeviceTypes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: colors[index % colors.length],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${deviceType.key} (${deviceType.value})',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
