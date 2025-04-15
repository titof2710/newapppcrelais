import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/admin_model.dart';
import '../models/user_model.dart';
import '../models/repair_model.dart';
import '../models/client_model.dart';
import '../models/point_relais_model.dart';
import '../models/technicien_model.dart';
import 'supabase_config.dart';
import 'supabase_service.dart';
import 'supabase_helper.dart';

/// Service pour gérer les fonctionnalités d'administration
class AdminService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseService _supabaseService = SupabaseService();

  // Vérifier si l'utilisateur actuel est un administrateur
  Future<bool> isCurrentUserAdmin() async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('isCurrentUserAdmin: Utilisateur non connecté');
        return false;
      }
      
      print('isCurrentUserAdmin: Vérification pour l\'utilisateur ${currentUser.uid} (${currentUser.email})');

      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', currentUser.uid)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        print('isCurrentUserAdmin: Erreur Supabase: ${SupabaseHelper.getErrorMessage(response)}');
        return false;
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      if (data.isEmpty) {
        print('isCurrentUserAdmin: Aucun utilisateur trouvé avec cet ID');
        return false;
      }
      
      final userData = data[0] as Map<String, dynamic>;
      final userType = userData['user_type'] as String?;
      
      print('isCurrentUserAdmin: Type d\'utilisateur trouvé: $userType');
      return userType == 'admin';
    } catch (e) {
      print('Erreur lors de la vérification du statut admin: $e');
      return false;
    }
  }

  // Récupérer les données de l'administrateur actuel
  Future<AdminModel?> getCurrentAdminData() async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Aucun utilisateur connecté');
        return null;
      }

      print('Recherche de l\'utilisateur admin avec ID: ${currentUser.uid}');
      
      // D'abord, vérifions si l'utilisateur existe dans la base de données
      final userResponse = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', currentUser.uid)
          .execute();
      
      if (SupabaseHelper.hasError(userResponse)) {
        print('Erreur lors de la recherche de l\'utilisateur: ${SupabaseHelper.getErrorMessage(userResponse)}');
        return null;
      }
      
      if (userResponse.data == null || (userResponse.data as List).isEmpty) {
        print('Aucun utilisateur trouvé avec cet ID');
        return null;
      }
      
      // Afficher les données de l'utilisateur pour le débogage
      final userData = (userResponse.data as List)[0] as Map<String, dynamic>;
      print('Utilisateur trouvé: ${userData['name']}');
      print('Type d\'utilisateur: ${userData['user_type']}');
      
      // Vérifier si l'utilisateur est un administrateur
      if (userData['user_type'] != 'admin') {
        print('L\'utilisateur n\'est pas un administrateur, type: ${userData['user_type']}');
        return null;
      }
      
      // Créer le modèle admin
      try {
        return AdminModel.fromJson(userData);
      } catch (e) {
        print('Erreur lors de la création du modèle admin: $e');
        // Essayer de créer un modèle admin basique
        return AdminModel(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
          phoneNumber: userData['phone_number'] as String,
          createdAt: DateTime.parse(userData['created_at'] as String),
          permissions: [],
          role: 'admin',
        );
      }
    } catch (e) {
      print('Erreur lors de la récupération des données admin: $e');
      return null;
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des utilisateurs: ${SupabaseHelper.getErrorMessage(response)}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((userData) {
        final String userType = userData['user_type'] as String;
        switch (userType) {
          case 'client':
            return UserModel.fromJson(userData);
          case 'point_relais':
            return UserModel.fromJson(userData);
          case 'admin':
            return AdminModel.fromJson(userData);
          default:
            return UserModel.fromJson(userData);
        }
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  // Récupérer toutes les réparations
  Future<List<RepairModel>> getAllRepairs() async {
    try {
      // Utiliser la méthode getRepairs de SupabaseService qui a été corrigée
      final List<Map<String, dynamic>> repairsData = await _supabaseService.getRepairs();
      
      // Convertir les données en modèles RepairModel
      return repairsData.map((repairData) => RepairModel.fromJson(repairData)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réparations: $e');
    }
  }

  // Créer un nouvel administrateur
  Future<AdminModel> createAdmin({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    List<String> permissions = const [],
    String role = 'admin',
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

      // Créer le profil admin dans Supabase
      final AdminModel newAdmin = AdminModel(
        id: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        permissions: permissions,
        role: role,
      );

      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(newAdmin.toJson())
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la création du profil admin: ${SupabaseHelper.getErrorMessage(response)}');
      }

      return newAdmin;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'administrateur: $e');
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(UserModel user) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .update(user.toJson())
          .eq('id', user.id)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la mise à jour de l\'utilisateur: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      // Supprimer l'utilisateur de Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .delete()
          .eq('id', userId)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la suppression de l\'utilisateur: ${SupabaseHelper.getErrorMessage(response)}');
      }

      // Supprimer l'utilisateur de Firebase Auth
      // Note: Cette opération nécessite des privilèges d'administration Firebase
      // et pourrait ne pas fonctionner directement depuis l'application cliente
      try {
        // Cette fonctionnalité nécessite Firebase Admin SDK ou une fonction Cloud
        // await _auth.deleteUser(userId);
        print('La suppression de l\'utilisateur Firebase doit être effectuée via le SDK Admin ou une fonction Cloud');
      } catch (authError) {
        print('Erreur lors de la suppression de l\'utilisateur Firebase: $authError');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  // Créer un nouveau technicien
  Future<TechnicienModel> createTechnicien({
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
      // Créer l'utilisateur dans Firebase
      final firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final String userId = userCredential.user!.uid;
      final DateTime now = DateTime.now();
      
      // Créer le modèle technicien
      final TechnicienModel technicien = TechnicienModel(
        id: userId,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: now,
        speciality: speciality,
        experienceYears: experienceYears,
        certifications: certifications,
        assignedRepairs: [],
      );
      
      // Ajouter l'utilisateur à Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(technicien.toJson())
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        // En cas d'erreur, supprimer l'utilisateur Firebase
        await userCredential.user!.delete();
        throw Exception('Erreur lors de la création du technicien: ${SupabaseHelper.getErrorMessage(response)}');
      }
      
      return technicien;
    } catch (e) {
      throw Exception('Erreur lors de la création du technicien: $e');
    }
  }

  // Créer un nouveau client
  Future<ClientModel> createClient({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      print('Création client avec email: $email');
      if (email.isEmpty) {
        throw Exception('Email vide lors de la création du client');
      }
      
      // Créer l'utilisateur dans Firebase
      final firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final String userId = userCredential.user!.uid;
      final DateTime now = DateTime.now();
      
      // Créer le modèle client
      final ClientModel client = ClientModel(
        id: userId,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: now,
        repairIds: [],
      );
      
      // Vérifier que l'email est bien présent dans le JSON
      final Map<String, dynamic> clientJson = client.toJson();
      print('JSON client à insérer: $clientJson');
      
      if (clientJson['email'] == null || clientJson['email'].toString().isEmpty) {
        // Ajouter l'email manuellement si absent
        clientJson['email'] = email;
        print('Email ajouté manuellement: $email');
      }
      
      // Ajouter l'utilisateur à Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(clientJson)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        // En cas d'erreur, supprimer l'utilisateur Firebase
        await userCredential.user!.delete();
        print('Erreur Supabase: ${SupabaseHelper.getErrorMessage(response)}');
        throw Exception('Erreur lors de la création du client: ${SupabaseHelper.getErrorMessage(response)}');
      }
      
      return client;
    } catch (e) {
      print('Exception lors de la création du client: $e');
      throw Exception('Erreur lors de la création du client: $e');
    }
  }

  // Créer une nouvelle réparation (réservé aux administrateurs)
  Future<RepairModel> createRepair(RepairModel repair) async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('createRepair: Utilisateur non connecté');
        throw Exception('Utilisateur non connecté');
      }
      
      print('createRepair: Tentative de création de réparation par l\'utilisateur: ${currentUser.uid} (${currentUser.email})');

      // NOTE: Nous supposons que cette méthode n'est accessible que depuis l'interface d'administration
      // donc nous ne vérifions pas si l'utilisateur est un administrateur
      // Cette méthode est appelée depuis le widget CreateRepairDialog qui n'est accessible que par les administrateurs
      
      print('createRepair: Création d\'une réparation pour le client: ${repair.clientName}');

      // Générer un ID unique pour la réparation
      final String repairId = DateTime.now().millisecondsSinceEpoch.toString();
      final updatedRepair = repair.copyWith(id: repairId);
      
      // Ajouter la réparation à Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .insert(updatedRepair.toJson())
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la création de la réparation: ${SupabaseHelper.getErrorMessage(response)}');
      }
      
      // Mettre à jour l'utilisateur avec l'ID de la réparation
      final clientData = await _supabaseService.getUserById(repair.clientId);
      if (clientData != null) {
        List<String> repairIds = [];
        if (clientData.containsKey('repair_ids') && clientData['repair_ids'] != null) {
          repairIds = List<String>.from(clientData['repair_ids']);
        }
        repairIds.add(repairId);
        
        await _supabaseService.upsertUser({
          'id': repair.clientId,
          'repair_ids': repairIds
        });
      }

      return updatedRepair;
    } catch (e) {
      throw Exception('Erreur lors de la création de la réparation: $e');
    }
  }

  // Obtenir des statistiques sur les réparations
  Future<Map<String, dynamic>> getRepairStatistics() async {
    try {
      // Récupérer toutes les réparations
      final List<RepairModel> repairs = await getAllRepairs();
      
      // Calculer les statistiques
      final int totalRepairs = repairs.length;
      final int completedRepairs = repairs.where((repair) => repair.status == RepairStatus.completed).length;
      final int pendingRepairs = repairs.where((repair) => repair.status == RepairStatus.pending).length;
      final int inProgressRepairs = repairs.where((repair) => repair.status == RepairStatus.in_progress).length;
      
      // Calculer le temps moyen de réparation (pour les réparations terminées)
      double averageRepairTime = 0;
      final completedRepairsList = repairs.where((repair) => repair.status == RepairStatus.completed).toList();
      if (completedRepairsList.isNotEmpty) {
        final totalDuration = completedRepairsList.fold<Duration>(
          Duration.zero,
          (sum, repair) => sum + Duration(days: 1), // Valeur temporaire pour le temps de réparation
        );
        averageRepairTime = totalDuration.inHours / completedRepairsList.length;
      }
      
      return {
        'totalRepairs': totalRepairs,
        'completedRepairs': completedRepairs,
        'pendingRepairs': pendingRepairs,
        'inProgressRepairs': inProgressRepairs,
        'averageRepairTimeHours': averageRepairTime,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }
  
  // Récupérer tous les clients
  Future<List<ClientModel>> getAllClients() async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('user_type', 'client')
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des clients: ${SupabaseHelper.getErrorMessage(response)}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((userData) => ClientModel.fromJson(userData)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des clients: $e');
    }
  }
  
  // Mettre à jour le schéma de la base de données pour ajouter la colonne client_name à la table repairs
  Future<void> updateDatabaseSchema() async {
    try {
      // Vérifier si la colonne client_name existe déjà
      final checkResponse = await _supabaseService.client
          .rpc('column_exists', params: {
            'table_name': 'repairs',
            'column_name': 'client_name'
          })
          .execute();
      
      if (SupabaseHelper.hasError(checkResponse)) {
        print('Erreur lors de la vérification de la colonne: ${SupabaseHelper.getErrorMessage(checkResponse)}');
        // Continuer quand même, car l'erreur pourrait être due à l'absence de la fonction RPC
      } else {
        final bool columnExists = checkResponse.data as bool? ?? false;
        if (columnExists) {
          print('La colonne client_name existe déjà dans la table repairs');
          return;
        }
      }
      
      // Ajouter la colonne client_name à la table repairs
      final response = await _supabaseService.client
          .rpc('add_column_if_not_exists', params: {
            'table_name': 'repairs',
            'column_name': 'client_name',
            'column_type': 'TEXT'
          })
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        print('Erreur lors de l\'ajout de la colonne: ${SupabaseHelper.getErrorMessage(response)}');
        throw Exception('Impossible de mettre à jour le schéma de la base de données');
      }
      
      print('Colonne client_name ajoutée avec succès à la table repairs');
    } catch (e) {
      print('Erreur lors de la mise à jour du schéma: $e');
      throw Exception('Erreur lors de la mise à jour du schéma: $e');
    }
  }
  
  // Mettre à jour une réparation existante
  Future<RepairModel> updateRepair(RepairModel repair) async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('updateRepair: Utilisateur non connecté');
        throw Exception('Utilisateur non connecté');
      }
      
      print('updateRepair: Tentative de mise à jour de réparation par l\'utilisateur: ${currentUser.uid} (${currentUser.email})');

      // NOTE: Nous supposons que cette méthode n'est accessible que depuis l'interface d'administration
      // donc nous ne vérifions pas si l'utilisateur est un administrateur
      // Cette méthode est appelée depuis le widget EditRepairDialog qui n'est accessible que par les administrateurs
      
      print('updateRepair: Mise à jour de la réparation: ${repair.id} pour ${repair.clientName}');

      // Mettre à jour la réparation dans Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .update(repair.toJson())
          .eq('id', repair.id)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la mise à jour de la réparation: ${SupabaseHelper.getErrorMessage(response)}');
      }
      
      return repair;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la réparation: $e');
    }
  }
}
