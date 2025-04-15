import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Wrapper pour Firestore qui gère les différences entre web et mobile
class FirestoreWrapper {
  static final FirestoreWrapper _instance = FirestoreWrapper._internal();
  
  factory FirestoreWrapper() {
    return _instance;
  }
  
  FirestoreWrapper._internal();
  
  // Référence à l'instance de Firestore
  FirebaseFirestore? _firestoreInstance;
  
  // Getter pour accéder à l'instance de Firestore
  FirebaseFirestore get instance {
    if (_firestoreInstance == null) {
      _firestoreInstance = FirebaseFirestore.instance;
      
      // Configuration spécifique pour le web
      if (kIsWeb) {
        _firestoreInstance!.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
    }
    return _firestoreInstance!;
  }
  
  // Méthodes pour accéder aux collections
  CollectionReference collection(String path) {
    return instance.collection(path);
  }
  
  // Méthode pour accéder à un document
  DocumentReference document(String path) {
    return instance.doc(path);
  }
  
  // Méthode pour créer une requête
  Query query(String collectionPath) {
    return instance.collection(collectionPath);
  }
  
  // Méthode pour effectuer une transaction
  Future<T> runTransaction<T>(Future<T> Function(Transaction) transactionHandler) {
    return instance.runTransaction(transactionHandler);
  }
  
  // Méthode pour effectuer un batch
  WriteBatch batch() {
    return instance.batch();
  }
}
