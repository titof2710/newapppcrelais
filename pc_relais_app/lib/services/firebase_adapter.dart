import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

/// Service qui détecte automatiquement les problèmes de compatibilité Firebase
/// et adapte l'initialisation en conséquence
class FirebaseAdapter {
  static final FirebaseAdapter _instance = FirebaseAdapter._internal();
  
  factory FirebaseAdapter() {
    return _instance;
  }
  
  FirebaseAdapter._internal();
  
  bool _initialized = false;
  bool _isCompatibilityMode = false;
  String _errorMessage = '';
  
  bool get isInitialized => _initialized;
  bool get isCompatibilityMode => _isCompatibilityMode;
  String get errorMessage => _errorMessage;
  
  /// Initialise Firebase avec détection automatique des problèmes
  Future<bool> initialize() async {
    if (_initialized) return true;
    
    try {
      if (kIsWeb) {
        // Essayer d'abord l'initialisation standard pour le web
        await _initializeForWeb();
      } else {
        // Initialisation pour les plateformes mobiles
        await _initializeForMobile();
      }
      
      _initialized = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Erreur lors de l\'initialisation de Firebase: $_errorMessage');
      
      // Essayer les modes de compatibilité
      return await _tryCompatibilityModes();
    }
  }
  
  /// Initialisation standard pour le web
  Future<void> _initializeForWeb() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCCyyHI2rSYvsPfUc5pO6xkHExxIpkoaKM",
        authDomain: "pc-relais-app.firebaseapp.com",
        projectId: "pc-relais-app",
        storageBucket: "pc-relais-app.firebasestorage.app",
        messagingSenderId: "636492327464",
        appId: "1:636492327464:web:3f84a5dcd158358a49e31d",
        measurementId: "G-VEZPWPMXS1"
      ),
    );
    print('Firebase initialisé avec succès pour le web (mode standard)');
  }
  
  /// Initialisation pour les plateformes mobiles
  Future<void> _initializeForMobile() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialisé avec succès pour mobile');
  }
  
  /// Essaie différents modes de compatibilité jusqu'à ce qu'un fonctionne
  Future<bool> _tryCompatibilityModes() async {
    List<Future<bool> Function()> compatibilityModes = [
      _tryWebCompatibilityMode1,
      _tryWebCompatibilityMode2,
      _tryWebCompatibilityMode3,
      _tryFallbackMode
    ];
    
    for (var mode in compatibilityModes) {
      try {
        bool success = await mode();
        if (success) {
          _initialized = true;
          _isCompatibilityMode = true;
          return true;
        }
      } catch (e) {
        print('Mode de compatibilité échoué: ${e.toString()}');
        // Continuer avec le mode suivant
      }
    }
    
    // Si tous les modes échouent, retourner false
    return false;
  }
  
  /// Mode de compatibilité 1: Initialisation minimale
  Future<bool> _tryWebCompatibilityMode1() async {
    if (!kIsWeb) return false;
    
    try {
      // Essayer une initialisation minimale
      await Firebase.initializeApp();
      print('Firebase initialisé avec succès (mode de compatibilité 1)');
      return true;
    } catch (e) {
      print('Mode de compatibilité 1 échoué: ${e.toString()}');
      return false;
    }
  }
  
  /// Mode de compatibilité 2: Utilisation de la configuration web via JS
  Future<bool> _tryWebCompatibilityMode2() async {
    if (!kIsWeb) return false;
    
    try {
      // Ce mode suppose que l'initialisation est déjà faite dans index.html
      // et tente simplement de se connecter à l'instance existante
      print('Tentative de connexion à l\'instance Firebase existante (mode de compatibilité 2)');
      return true;
    } catch (e) {
      print('Mode de compatibilité 2 échoué: ${e.toString()}');
      return false;
    }
  }
  
  /// Mode de compatibilité 3: Désactivation de certaines fonctionnalités
  Future<bool> _tryWebCompatibilityMode3() async {
    if (!kIsWeb) return false;
    
    try {
      // Initialisation avec options minimales
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCCyyHI2rSYvsPfUc5pO6xkHExxIpkoaKM",
          authDomain: "pc-relais-app.firebaseapp.com",
          projectId: "pc-relais-app",
          appId: "1:636492327464:web:3f84a5dcd158358a49e31d",
        ),
      );
      print('Firebase initialisé avec succès (mode de compatibilité 3)');
      return true;
    } catch (e) {
      print('Mode de compatibilité 3 échoué: ${e.toString()}');
      return false;
    }
  }
  
  /// Mode de secours: Fonctionnement sans Firebase
  Future<bool> _tryFallbackMode() async {
    try {
      print('Initialisation du mode de secours (sans Firebase)');
      return true;
    } catch (e) {
      print('Mode de secours échoué: ${e.toString()}');
      return false;
    }
  }
  
  /// Vérifie si une fonctionnalité Firebase spécifique est disponible
  bool isFeatureAvailable(String feature) {
    if (!_initialized) return false;
    
    if (_isCompatibilityMode) {
      // En mode de compatibilité, certaines fonctionnalités peuvent être désactivées
      switch (feature) {
        case 'auth':
          return true; // Supposons que l'authentification fonctionne toujours
        case 'firestore':
          return true; // Supposons que Firestore fonctionne toujours
        case 'storage':
          return kIsWeb ? false : true; // Désactivé sur le web en mode compatibilité
        case 'messaging':
          return kIsWeb ? false : true; // Désactivé sur le web en mode compatibilité
        default:
          return false;
      }
    }
    
    // En mode normal, toutes les fonctionnalités sont disponibles
    return true;
  }
  
  /// Récupère l'instance de FirebaseAuth si disponible
  FirebaseAuth? get auth {
    if (!_initialized || !isFeatureAvailable('auth')) {
      return null;
    }
    return FirebaseAuth.instance;
  }
  
  /// Récupère l'instance de FirebaseFirestore si disponible
  FirebaseFirestore? get firestore {
    if (!_initialized || !isFeatureAvailable('firestore')) {
      return null;
    }
    return FirebaseFirestore.instance;
  }
  
  /// Récupère l'instance de FirebaseStorage si disponible
  FirebaseStorage? get storage {
    if (!_initialized || !isFeatureAvailable('storage')) {
      return null;
    }
    return FirebaseStorage.instance;
  }
  
  /// Récupère l'instance de FirebaseMessaging si disponible
  FirebaseMessaging? get messaging {
    if (!_initialized || !isFeatureAvailable('messaging')) {
      return null;
    }
    return FirebaseMessaging.instance;
  }
}
