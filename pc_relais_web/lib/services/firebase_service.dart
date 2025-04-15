import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Service pour gérer l'initialisation et l'accès à Firebase pour le web
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();
  
  bool _initialized = false;
  
  bool get isInitialized => _initialized;
  
  /// Initialise Firebase pour le web
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Initialiser Firebase avec les options spécifiques pour le web
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
      _initialized = true;
    } catch (e) {
      print('Erreur lors de l\'initialisation de Firebase: $e');
      rethrow;
    }
  }
  
  /// Récupère l'instance de FirebaseAuth
  FirebaseAuth get auth {
    if (!_initialized) {
      throw Exception('Firebase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    return FirebaseAuth.instance;
  }
  
  /// Récupère l'instance de FirebaseFirestore
  FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception('Firebase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    return FirebaseFirestore.instance;
  }
  
  /// Récupère l'instance de FirebaseStorage
  FirebaseStorage get storage {
    if (!_initialized) {
      throw Exception('Firebase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    return FirebaseStorage.instance;
  }
  
  /// Récupère l'instance de FirebaseMessaging
  FirebaseMessaging get messaging {
    if (!_initialized) {
      throw Exception('Firebase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    return FirebaseMessaging.instance;
  }
}
