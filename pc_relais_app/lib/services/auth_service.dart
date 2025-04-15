import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';
import '../models/technicien_model.dart';
import '../models/admin_model.dart';
import '../models/client_model.dart';
import '../models/point_relais_model.dart';
import 'supabase_config.dart';
import 'supabase_service.dart';
import 'supabase_helper.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseService _supabaseService = SupabaseService();

  // Obtenir l'utilisateur actuel
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Stream pour suivre l'état d'authentification
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Inscription d'un nouveau client
  Future<UserModel> registerClient({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebase_auth.User? user = userCredential.user;
      if (user == null) {
        throw Exception("L'inscription a échoué");
      }

      // Créer le profil client dans Supabase
      final ClientModel newClient = ClientModel(
        id: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: DateTime.now(),
        repairIds: [],
      );

      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(newClient.toJson())
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la création du profil: ${SupabaseHelper.getErrorMessage(response)}');
      }

      // Sauvegarder le type d'utilisateur dans les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'client');

      return newClient;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Inscription d'un nouveau technicien
  Future<UserModel> registerTechnicien({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? address,
    List<String> speciality = const [],
    int experienceYears = 0,
    List<String> certifications = const [],
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebase_auth.User? user = userCredential.user;
      if (user == null) {
        throw Exception("L'inscription a échoué");
      }

      // Créer le profil technicien dans Supabase
      final TechnicienModel newTechnicien = TechnicienModel(
        id: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: DateTime.now(),
        speciality: speciality,
        experienceYears: experienceYears,
        certifications: certifications,
        assignedRepairs: [],
      );

      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(newTechnicien.toJson())
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la création du profil: ${SupabaseHelper.getErrorMessage(response)}');
      }

      // Sauvegarder le type d'utilisateur dans les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'technicien');

      return newTechnicien;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Inscription d'un nouveau point relais
  Future<UserModel> registerPointRelais({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String shopName,
    required String shopAddress,
    required List<String> openingHours,
    required int storageCapacity,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebase_auth.User? user = userCredential.user;
      if (user == null) {
        throw Exception("L'inscription a échoué");
      }

      // Créer le profil point relais dans Supabase
      final PointRelaisModel newPointRelais = PointRelaisModel(
        id: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        shopName: shopName,
        shopAddress: shopAddress,
        openingHours: openingHours,
        storageCapacity: storageCapacity,
        currentStorageUsed: 0,
        createdAt: DateTime.now(),
      );

      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(newPointRelais.toJson())
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la création du profil: ${SupabaseHelper.getErrorMessage(response)}');
      }

      // Sauvegarder le type d'utilisateur dans les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'point_relais');

      return newPointRelais;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion d'un utilisateur
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Connecter l'utilisateur avec Firebase Auth
      final firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebase_auth.User? user = userCredential.user;
      if (user == null) {
        throw Exception('La connexion a échoué');
      }

      // Récupérer les données de l'utilisateur depuis Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', user.uid)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Profil utilisateur introuvable: ${SupabaseHelper.getErrorMessage(response)}');
      }

      final userData = response.data as Map<String, dynamic>;
      final String userType = userData['user_type'] as String;

      // Sauvegarder le type d'utilisateur dans les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', userType);

      // Retourner le modèle d'utilisateur approprié
      if (userType == 'client') {
        return ClientModel.fromJson(userData);
      } else if (userType == 'point_relais') {
        return PointRelaisModel.fromJson(userData);
      } else if (userType == 'technicien') {
        return TechnicienModel.fromJson(userData);
      } else if (userType == 'admin') {
        // Utiliser le modèle AdminModel si disponible, sinon utiliser UserModel
        try {
          return AdminModel.fromJson(userData);
        } catch (e) {
          // Fallback au modèle utilisateur de base si AdminModel n'est pas disponible
          return UserModel.fromJson(userData);
        }
      } else {
        throw Exception('Type d\'utilisateur non reconnu: $userType');
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Effacer les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userType');
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Récupérer le type d'utilisateur depuis les préférences locales
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');
    
    // Gérer la transition de 'buraliste' à 'point_relais'
    if (userType == 'buraliste') {
      userType = 'point_relais';
      await prefs.setString('userType', userType);
      print('Type d\'utilisateur mis à jour de buraliste à point_relais');
    }
    
    return userType;
  }

  // Récupérer les informations de l'utilisateur actuel
  Future<UserModel?> getCurrentUserData() async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', currentUser.uid)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        return null;
      }

      final userData = response.data as Map<String, dynamic>;
      final String userType = userData['user_type'] as String;

      if (userType == 'client') {
        return ClientModel.fromJson(userData);
      } else if (userType == 'point_relais') {
        return PointRelaisModel.fromJson(userData);
      } else if (userType == 'technicien') {
        return TechnicienModel.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .update(user.toJson())
          .eq('id', user.id)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la mise à jour du profil: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation du mot de passe: $e');
    }
  }
  
  // Récupérer les points relais à proximité
  Future<List<PointRelaisModel>> getNearbyPointRelais() async {
    try {
      // Pour l'instant, on récupère tous les points relais
      // Dans une version future, on pourrait filtrer par localisation
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('user_type', 'point_relais')
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des points relais: ${SupabaseHelper.getErrorMessage(response)}');
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => PointRelaisModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des points relais: $e');
    }
  }
}
