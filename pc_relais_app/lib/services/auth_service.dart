import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:gotrue/gotrue.dart' show OAuthProvider;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../models/technicien_model.dart';
import '../models/admin_model.dart';
import '../models/client_model.dart';
import '../models/point_relais_model.dart';
import 'supabase_config.dart';
import 'supabase_service.dart';
import 'supabase_helper.dart';

import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> refreshCurrentUser() async {
    _currentUser = await getCurrentUserData();
    notifyListeners();
  }
  /// Met à jour le token FCM de l'utilisateur dans Supabase
  Future<void> updateUserFcmToken(String uuid, String fcmToken) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .update({'fcm_token': fcmToken})
          .eq('uuid', uuid);
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la mise à jour du token FCM: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      print('Erreur updateUserFcmToken: $e');
    }
  }

  final SupabaseService _supabaseService = SupabaseService();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;


  // Stream pour suivre l'état d'authentification
  Stream<firebase_auth.User?> get authStateChanges => firebase_auth.FirebaseAuth.instance.authStateChanges();

  // Inscription d'un nouveau client
  Future<UserModel> registerClient({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      // Créer l'utilisateur dans Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception("L'inscription a échoué");
      }
      // Créer le profil client dans Supabase (table users)
      final ClientModel newClient = ClientModel(
        uuid: user.id,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: DateTime.now(),
        repairIds: [],
      );
      final insertResponse = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(newClient.toJson())
          .select();
      print('Réponse Supabase après insertion :');
      print(insertResponse);
      if (SupabaseHelper.hasError(insertResponse)) {
        print('Erreur détectée par SupabaseHelper.hasError !');
        throw Exception('Erreur lors de la création du profil: ${SupabaseHelper.getErrorMessage(insertResponse)}');
      }
      // Sauvegarder le type d'utilisateur dans les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'client');
      // Forcer la reconnexion pour que GoRouter détecte bien l'utilisateur
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      print('[DEBUG] Reconnexion après inscription réussie.');
      await refreshCurrentUser();
      return newClient;
    } catch (e) {
      print('Erreur lors de l\'inscription client : $e');
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
      // Créer l'utilisateur dans Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception("L'inscription a échoué");
      }
      // Créer le profil technicien dans Supabase (table users)
      final TechnicienModel newTechnicien = TechnicienModel(
        uuid: user.id,
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
      final insertResponse = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(newTechnicien.toJson());
      if (SupabaseHelper.hasError(insertResponse)) {
        throw Exception('Erreur lors de la création du profil: ${SupabaseHelper.getErrorMessage(insertResponse)}');
      }
      // Sauvegarder le type d'utilisateur dans les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'technicien');
      // Reconnexion Supabase pour activer l'utilisateur côté Provider
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      await refreshCurrentUser();
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
      // Créer l'utilisateur dans Supabase Auth
      // Créer l'utilisateur dans Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception("L'inscription a échoué");
      }
      // Créer le profil point relais dans Supabase (table users)
      final PointRelaisModel newPointRelais = PointRelaisModel(
        uuid: user.id,
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

      final insertResponse = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(newPointRelais.toJson());
      if (SupabaseHelper.hasError(insertResponse)) {
        throw Exception('Erreur lors de la création du profil: ${SupabaseHelper.getErrorMessage(insertResponse)}');
      }

      // Sauvegarder le type d'utilisateur dans les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'point_relais');
      // Reconnexion Supabase pour activer l'utilisateur côté Provider
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      await refreshCurrentUser();
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
      // Connexion Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception('La connexion a échoué');
      }
      print('Recherche utilisateur avec uuid: \'${user.id}\'');
      final userResponse = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('uuid', user.id)
          .single();
      if (SupabaseHelper.hasError(userResponse)) {
        throw Exception('Profil utilisateur introuvable: ${SupabaseHelper.getErrorMessage(userResponse)}');
      }
      final userData = userResponse as Map<String, dynamic>;
      final String userType = userData['user_type'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', userType);
      // Met à jour l'utilisateur courant
      if (userType == 'client') {
        _currentUser = ClientModel.fromJson(userData);
      } else if (userType == 'point_relais') {
        _currentUser = PointRelaisModel.fromJson(userData);
      } else if (userType == 'technicien') {
        _currentUser = TechnicienModel.fromJson(userData);
      } else if (userType == 'admin') {
        try {
          _currentUser = AdminModel.fromJson(userData);
        } catch (e) {
          _currentUser = UserModel.fromJson(userData);
        }
      } else {
        throw Exception('Type d\'utilisateur non reconnu: $userType');
      }
      notifyListeners();
      return _currentUser!;
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
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser == null) {
        return null;
      }

      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('uuid', supabaseUser.id)
          .single();
      
      if (SupabaseHelper.hasError(response)) {
        return null;
      }

      final userData = response as Map<String, dynamic>;
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
          .eq('id', user.uuid)
          ;
          
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
          ;
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des points relais: ${SupabaseHelper.getErrorMessage(response)}');
      }
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => PointRelaisModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des points relais: $e');
    }
  }
}
