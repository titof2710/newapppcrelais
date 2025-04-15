import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

/// Service pour gérer l'initialisation et l'accès à Firebase spécifiquement pour le web
/// en utilisant les instances Firebase JS déjà initialisées dans index.html
class FirebaseWebService {
  static final FirebaseWebService _instance = FirebaseWebService._internal();
  
  factory FirebaseWebService() {
    return _instance;
  }
  
  FirebaseWebService._internal();
  
  bool _initialized = false;
  bool _isCompatibilityMode = false;
  
  bool get isInitialized => _initialized;
  bool get isCompatibilityMode => _isCompatibilityMode;
  
  /// Initialise Firebase pour le web en utilisant les instances globales
  /// définies dans index.html
  Future<bool> initialize() async {
    if (_initialized) return true;
    
    try {
      if (kIsWeb) {
        // Pour le web, nous utilisons les instances Firebase JS déjà initialisées
        // dans index.html
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
        
        print('Firebase initialisé avec succès pour le web');
      } else {
        // Pour les plateformes mobiles, nous utilisons l'initialisation standard
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        
        print('Firebase initialisé avec succès pour mobile');
      }
      
      _initialized = true;
      return true;
    } catch (e) {
      print('Erreur lors de l\'initialisation de Firebase: $e');
      
      // En cas d'erreur, nous essayons le mode de compatibilité
      return await _tryCompatibilityMode();
    }
  }
  
  /// Essaie d'initialiser Firebase en mode de compatibilité
  Future<bool> _tryCompatibilityMode() async {
    try {
      if (kIsWeb) {
        // En mode de compatibilité pour le web, nous utilisons une configuration minimale
        await Firebase.initializeApp();
        
        print('Firebase initialisé en mode de compatibilité pour le web');
      } else {
        // Pour les plateformes mobiles, nous utilisons l'initialisation standard
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        
        print('Firebase initialisé avec succès pour mobile');
      }
      
      _initialized = true;
      _isCompatibilityMode = true;
      return true;
    } catch (e) {
      print('Erreur lors de l\'initialisation de Firebase en mode de compatibilité: $e');
      return false;
    }
  }
  
  /// Vérifie si une fonctionnalité Firebase spécifique est disponible
  bool isFeatureAvailable(String feature) {
    if (!_initialized) return false;
    
    if (_isCompatibilityMode && kIsWeb) {
      // En mode de compatibilité sur le web, certaines fonctionnalités peuvent être désactivées
      switch (feature) {
        case 'auth':
          return true; // Supposons que l'authentification fonctionne toujours
        case 'firestore':
          return true; // Supposons que Firestore fonctionne toujours
        case 'storage':
          return false; // Désactivé sur le web en mode compatibilité
        case 'messaging':
          return false; // Désactivé sur le web en mode compatibilité
        default:
          return false;
      }
    }
    
    // En mode normal, toutes les fonctionnalités sont disponibles
    return true;
  }
}
