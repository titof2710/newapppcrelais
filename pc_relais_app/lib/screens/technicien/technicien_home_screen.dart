import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';

class TechnicienHomeScreen extends StatefulWidget {
  final Widget child;

  const TechnicienHomeScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<TechnicienHomeScreen> createState() => _TechnicienHomeScreenState();
}

class _TechnicienHomeScreenState extends State<TechnicienHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PC Relais - Technicien'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: AppDrawer(userType: 'technicien'),
      body: Row(
        children: [
          // Navigation latérale pour les grands écrans
          if (MediaQuery.of(context).size.width >= 1200)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
                _navigateToDestination(index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Tableau de bord'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.build),
                  label: Text('Réparations'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chat),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profil'),
                ),
              ],
            ),
          // Contenu principal
          Expanded(
            child: widget.child,
          ),
        ],
      ),
      // Navigation du bas pour les petits écrans
      bottomNavigationBar: MediaQuery.of(context).size.width < 1200
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
                _navigateToDestination(index);
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: 'Réparations',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            )
          : null,
    );
  }

  void _navigateToDestination(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/technicien');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/technicien/repairs');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/technicien/chat');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/technicien/profile');
        break;
    }
  }
}

class TechnicienHomeContent extends StatelessWidget {
  const TechnicienHomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tableau de bord technicien',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Statistiques
          _buildStatisticsSection(),
          
          const SizedBox(height: 24),
          
          // Réparations en cours
          _buildCurrentRepairsSection(),
          
          const SizedBox(height: 24),
          
          // Tâches à venir
          _buildUpcomingTasksSection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Réparations en cours',
          value: '5',
          icon: Icons.build,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Réparations terminées',
          value: '12',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Temps moyen de réparation',
          value: '3.2 jours',
          icon: Icons.timer,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentRepairsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Réparations en cours',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.laptop, color: Colors.white),
                ),
                title: Text('Réparation #${1000 + index}'),
                subtitle: Text('Ordinateur portable - ${["En diagnostic", "En réparation", "En test"][index]}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigation vers le détail de la réparation
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tâches à venir',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.assignment, color: Colors.white),
                ),
                title: Text('Tâche #${index + 1}'),
                subtitle: Text('Échéance: ${["Aujourd'hui", "Demain", "Dans 3 jours"][index]}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigation vers le détail de la tâche
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
