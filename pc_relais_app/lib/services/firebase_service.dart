import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

/// Service pour gérer l'initialisation et l'accès à Firebase
/// de manière compatible avec le web et les plateformes mobiles
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();
  
  bool _initialized = false;
  bool _isDemo = false;
  
  bool get isInitialized => _initialized;
  bool get isDemo => _isDemo;
  
  /// Initialise Firebase en fonction de la plateforme
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      if (kIsWeb) {
        // Approche simplifiée pour le web
        // Vérifier si Firebase est déjà initialisé
        if (Firebase.apps.isNotEmpty) {
          _initialized = true;
          _isDemo = false;
          print('Firebase déjà initialisé pour le web');
          return;
        }
        
        // Initialisation simplifiée pour le web sans options spécifiques
        // Les options sont déjà définies dans index.html
        await Firebase.initializeApp();
      } else {
        // Pour les plateformes mobiles, nous utilisons l'initialisation standard
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      _initialized = true;
      _isDemo = false;
      print('Firebase initialisé avec succès pour ${kIsWeb ? "le web" : "mobile"}');
    } catch (e) {
      print('Erreur lors de l\'initialisation de Firebase: $e');
      // En cas d'erreur, nous passons en mode démo
      await _initializeFallback();
    }
  }
  
  /// Initialise un mode démo en cas d'échec de l'initialisation Firebase
  Future<void> _initializeFallback() async {
    try {
      print('Initialisation de Firebase en mode démo');
      _initialized = true;
      _isDemo = true;
    } catch (e) {
      print('Erreur lors de l\'initialisation du mode démo: $e');
    }
  }
  
  /// Récupère l'instance de FirebaseAuth
  FirebaseAuth get auth {
    if (!_initialized) {
      throw Exception('Firebase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    return FirebaseAuth.instance;
  }
  
  // Les services Firestore et Storage ont été supprimés car nous utiliserons une autre solution de base de données
  
  /// Récupère l'instance de FirebaseMessaging
  FirebaseMessaging get messaging {
    if (!_initialized) {
      throw Exception('Firebase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    return FirebaseMessaging.instance;
  }
}
