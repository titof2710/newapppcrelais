import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/supabase_service.dart';
import 'screens/firebase_test_screen.dart';
import 'navigation/app_router.dart';
import 'services/auth_service.dart';
import 'services/repair_service.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

// Gestionnaire de messages en arrière-plan global
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Message reçu en arrière-plan: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Définir l'orientation de l'application en mode portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  try {
    // Initialiser Firebase en fonction de la plateforme
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    print('Firebase initialisé avec succès');
    
    // Initialiser le service Firebase
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    
    // Initialiser le service Supabase
    final supabaseService = SupabaseService();
    try {
      await supabaseService.initialize();
      print('Supabase initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation de Supabase: $e');
      // Continuer même si Supabase n'est pas initialisé, car nous avons toujours Firebase Auth
    }
    
    // Configurer le gestionnaire de messages en arrière-plan
    if (!kIsWeb) { // Désactiver pour le web pour l'instant
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Initialiser le service de notification
      final notificationService = NotificationService();
      await notificationService.initialize();
    }
    
    // Lancer l'application principale sur toutes les plateformes
    runApp(const MyApp());
  } catch (e) {
    // En cas d'erreur d'initialisation de Firebase, afficher une version de l'app en mode démo
    print('Erreur d\'initialisation de Firebase: $e');
    runApp(const MyAppDemo());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<RepairService>(
          create: (_) => RepairService(),
        ),
        Provider<ChatService>(
          create: (_) => ChatService(),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
      ],
      child: MaterialApp.router(
        title: 'PC Relais',
        theme: AppTheme.clientTheme,
        darkTheme: AppTheme.clientTheme, // À remplacer par un thème sombre si nécessaire
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

// Version de l'application en mode démo (sans Firebase)
/// Application spécifique pour tester Firebase sur le web
class MyAppWebTest extends StatelessWidget {
  const MyAppWebTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Relais - Test Firebase Web',
      theme: AppTheme.clientTheme,
      debugShowCheckedModeBanner: false,
      home: const FirebaseTestScreen(),
    );
  }
}

/// Version de l'application en mode démo (sans Firebase)
class MyAppDemo extends StatelessWidget {
  const MyAppDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Relais - Mode Démo',
      theme: AppTheme.clientTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.computer,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'PC Relais',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mode Démo',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Impossible de se connecter à Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Tenter de relancer l'application
                  main();
                },
                child: const Text('RÉESSAYER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
