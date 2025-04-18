import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_client_screen.dart';
import '../screens/auth/register_point_relais_screen.dart';
import '../screens/client/client_home_screen.dart';
import '../screens/client/repair_list_screen.dart';
import '../screens/client/repair_detail_screen.dart';
import '../screens/client/new_repair_screen.dart';
import '../screens/client/chat_screen.dart';
import '../screens/client/profile_screen.dart';
import '../screens/point_relais/point_relais_home_screen.dart';
import 'package:pc_relais_app/screens/point_relais/relay_repairs_screen.dart';
import 'package:pc_relais_app/screens/point_relais/point_relais_dashboard.dart';
import '../screens/point_relais/scan_device_screen.dart';
import '../screens/point_relais/storage_management_screen.dart';
import '../screens/point_relais/point_relais_profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/users_management_screen.dart';
import '../screens/admin/repairs_management_screen.dart';
import '../screens/admin/statistics_screen.dart';
import '../screens/admin/settings_screen.dart';
import '../screens/admin/admin_registration_screen.dart';
import '../screens/technicien/technicien_home_screen.dart';
import '../screens/technicien/technicien_repairs_screen.dart';
import '../screens/technicien/technicien_profile_screen.dart';
import '../screens/technicien/technicien_new_repair_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _clientNavigatorKey = GlobalKey<NavigatorState>();
  static final _pointRelaisNavigatorKey = GlobalKey<NavigatorState>();
  static final _adminNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isLoggedIn = authService.currentUser != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation.startsWith('/register');
      final isGoingSplash = state.matchedLocation == '/';

      // Si l'utilisateur n'est pas connecté et ne va pas vers login/register/splash
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingSplash) {
        return '/login';
      }

      // Si l'utilisateur est connecté et va vers login/register
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        final userType = await authService.getUserType();
        if (userType == 'client') {
          return '/client';
        } else if (userType == 'point_relais') {
          return '/point_relais';
        } else if (userType == 'technicien') {
          return '/technicien';
        } else if (userType == 'admin') {
          return '/admin';
        }
      }

      // Pas de redirection
      return null;
    },
    routes: [
      // Route initiale - Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Routes d'authentification
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register/client',
        builder: (context, state) => const RegisterClientScreen(),
      ),
      GoRoute(
        path: '/register/point_relais',
        builder: (context, state) => const RegisterPointRelaisScreen(),
      ),
      GoRoute(
        path: '/register/admin',
        builder: (context, state) => const AdminRegistrationScreen(),
      ),
      
      // Routes pour les clients
      ShellRoute(
        navigatorKey: _clientNavigatorKey,
        builder: (context, state, child) => ClientHomeScreen(child: child),
        routes: [
          // Page d'accueil client
          GoRoute(
            path: '/client',
            builder: (context, state) => const ClientHomeContent(),
            routes: [
              // Détail d'une réparation
              GoRoute(
                path: 'repair/:repairId',
                builder: (context, state) {
                  final repairId = state.pathParameters['repairId']!;
                  return RepairDetailScreen(repairId: repairId);
                },
              ),
            ],
          ),
          // Liste des réparations
          GoRoute(
            path: '/client/repairs',
            builder: (context, state) => const RepairListScreen(),
            routes: [
              GoRoute(
                path: ':repairId',
                builder: (context, state) {
                  final repairId = state.pathParameters['repairId']!;
                  return RepairDetailScreen(repairId: repairId, isPointRelais: false, isTechnicien: false);
                },
              ),
              // Protection de la création de réparation pour les clients
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  return FutureBuilder(
                    future: authService.getUserType(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Scaffold(body: Center(child: CircularProgressIndicator()));
                      }
                      final userType = snapshot.data;
                      if (userType == 'technicien' || userType == 'admin') {
                        // Ici tu pourrais mettre un écran de création admin/tech si besoin
                        return const Scaffold(body: Center(child: Text('Écran de création réservé aux techniciens/admins')));
                      } else {
                        // Redirige immédiatement vers la liste si client
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go('/client/repairs');
                        });
                        return const Scaffold(body: Center(child: CircularProgressIndicator()));
                      }
                    },
                  );
                },
              ),
            ],
          ),
          // Nouvelle demande de réparation
          GoRoute(
            path: '/client/new-repair',
            builder: (context, state) => const NewRepairScreen(),
          ),
          // Chat
          GoRoute(
            path: '/client/chat',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Sélectionnez une conversation'),
              ),
            ),
            routes: [
              GoRoute(
                path: ':conversationId',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  // Utiliser conversationId comme repairId pour ChatScreen
                  return ChatScreen(repairId: conversationId);
                },
              ),
            ],
          ),
          // Profil client
          GoRoute(
            path: '/client/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Routes pour les points relais
      ShellRoute(
        navigatorKey: _pointRelaisNavigatorKey,
        builder: (context, state, child) => PointRelaisHomeScreen(child: child),
        routes: [
          // Page d'accueil point relais (obligatoire pour matcher /point_relais)
          GoRoute(
            path: '/point_relais',
            builder: (context, state) => const PointRelaisDashboard(),
          ),
          // Liste des réparations au point relais
          GoRoute(
            path: '/point_relais/repairs',
            builder: (context, state) => const RelayRepairsScreen(),
            routes: [
              // Détail d'une réparation
              GoRoute(
                path: ':repairId',
                builder: (context, state) {
                  final repairId = state.pathParameters['repairId']!;
                  return RepairDetailScreen(repairId: repairId, isPointRelais: true, isTechnicien: false);
                },
              ),
            ],
          ),
          // Scanner un appareil
          GoRoute(
            path: '/point_relais/scan',
            builder: (context, state) => const ScanDeviceScreen(),
          ),
          // Gestion du stockage
          GoRoute(
            path: '/point_relais/storage',
            builder: (context, state) => const StorageManagementScreen(),
          ),
          // Profil point relais
          GoRoute(
            path: '/point_relais/profile',
            builder: (context, state) => const PointRelaisProfileScreen(),
          ),
        ],
      ),
      
      // Routes pour les techniciens
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) => TechnicienHomeScreen(child: child),
        routes: [
          // Page d'accueil technicien
          GoRoute(
            path: '/technicien',
            builder: (context, state) => const TechnicienHomeContent(),
          ),
          // Liste des réparations du technicien
          GoRoute(
            path: '/technicien/repairs',
            builder: (context, state) => const TechnicienRepairsScreen(),
            routes: [
              // Détail d'une réparation
              GoRoute(
                path: ':repairId',
                builder: (context, state) {
                  final repairId = state.pathParameters['repairId']!;
                  return RepairDetailScreen(repairId: repairId, isPointRelais: false, isTechnicien: true);
                },
              ),
              // Nouvelle réparation (réservé aux techniciens)
              GoRoute(
                path: 'new',
                builder: (context, state) => const TechnicienNewRepairScreen(),
              ),
            ],
          ),
          // Chat du technicien
          GoRoute(
            path: '/technicien/chat',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Sélectionnez une conversation'),
              ),
            ),
            routes: [
              GoRoute(
                path: ':conversationId',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ChatScreen(repairId: conversationId);
                },
              ),
            ],
          ),
          // Profil technicien
          GoRoute(
            path: '/technicien/profile',
            builder: (context, state) => const TechnicienProfileScreen(),
          ),
        ],
      ),
      
      // Routes pour les administrateurs
      ShellRoute(
        navigatorKey: _adminNavigatorKey,
        builder: (context, state, child) => const AdminDashboardScreen(),
        routes: [
          // Tableau de bord administrateur
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          // Gestion des utilisateurs
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UsersManagementScreen(),
          ),
          // Gestion des réparations
          GoRoute(
            path: '/admin/repairs',
            builder: (context, state) => const RepairsManagementScreen(),
          ),
          // Statistiques
          GoRoute(
            path: '/admin/statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
          // Paramètres
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
