import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'supabase_helper.dart';

/// Service pour gérer les interactions avec Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() {
    return _instance;
  }
  
  SupabaseService._internal();
  
  bool _initialized = false;
  
  bool get isInitialized => _initialized;
  
  /// Initialise Supabase
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      
      _initialized = true;
      print('Supabase initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation de Supabase: $e');
      rethrow;
    }
  }
  
  /// Récupère l'instance de Supabase
  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    return Supabase.instance.client;
  }
  
  /// Récupère tous les utilisateurs
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await client
          .from(SupabaseConfig.usersTable)
          .select()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      rethrow;
    }
  }
  
  /// Récupère un utilisateur par son ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        final errorMsg = SupabaseHelper.getErrorMessage(response);
        if (errorMsg.contains('No rows found')) {
          return null;
        }
        throw Exception(errorMsg);
      }
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      rethrow;
    }
  }
  
  /// Crée ou met à jour un utilisateur
  Future<void> upsertUser(Map<String, dynamic> userData) async {
    try {
      // Vérifier si l'ID est fourni
      if (!userData.containsKey('id') || userData['id'] == null) {
        throw Exception('ID utilisateur requis pour la mise à jour');
      }
      
      // Récupérer les données existantes de l'utilisateur
      final existingUserData = await getUserById(userData['id']);
      
      // Si l'utilisateur existe, fusionner les données
      if (existingUserData != null) {
        print('Mise à jour de l\'utilisateur existant: ${userData['id']}');
        // Créer une copie des données existantes
        final Map<String, dynamic> mergedData = Map<String, dynamic>.from(existingUserData);
        // Ajouter/remplacer les nouvelles données
        mergedData.addAll(userData);
        
        print('Données fusionnées: $mergedData');
        
        // Effectuer la mise à jour avec les données fusionnées
        final response = await client
            .from(SupabaseConfig.usersTable)
            .update(mergedData) // Utiliser update au lieu de upsert
            .eq('id', userData['id'])
            .execute();
        
        if (SupabaseHelper.hasError(response)) {
          throw Exception(SupabaseHelper.getErrorMessage(response));
        }
      } else {
        // Si l'utilisateur n'existe pas, vérifier que toutes les données requises sont présentes
        if (!userData.containsKey('email') || userData['email'] == null) {
          throw Exception('Email requis pour la création d\'un utilisateur');
        }
        
        // Effectuer l'insertion
        final response = await client
            .from(SupabaseConfig.usersTable)
            .insert(userData)
            .execute();
        
        if (SupabaseHelper.hasError(response)) {
          throw Exception(SupabaseHelper.getErrorMessage(response));
        }
      }
    } catch (e) {
      print('Erreur lors de la création/mise à jour de l\'utilisateur: $e');
      rethrow;
    }
  }
  
  /// Méthode utilitaire pour convertir les champs de type liste qui pourraient être des chaînes
  Map<String, dynamic> _sanitizeRepairData(Map<String, dynamic> data) {
    final Map<String, dynamic> sanitizedData = Map<String, dynamic>.from(data);
    
    // Liste des champs qui devraient être des listes
    final listFields = ['photos', 'accessories', 'visual_state', 'repair_ids', 'notes', 'tasks'];
    
    for (final field in listFields) {
      if (sanitizedData.containsKey(field)) {
        final value = sanitizedData[field];
        
        // Si c'est déjà une liste, ne rien faire
        if (value is List) continue;
        
        // Si c'est null, mettre une liste vide
        if (value == null) {
          sanitizedData[field] = [];
          continue;
        }
        
        // Si c'est une chaîne qui ressemble à une liste JSON
        if (value is String) {
          if (value.startsWith('[') && value.endsWith(']')) {
            try {
              final List<dynamic> parsed = jsonDecode(value);
              sanitizedData[field] = parsed;
            } catch (e) {
              print('Erreur lors du parsing de la liste $field: $e');
              sanitizedData[field] = [];
            }
          } else {
            // Si c'est juste une chaîne, la mettre comme élément unique
            sanitizedData[field] = [value];
          }
        }
      }
    }
    
    return sanitizedData;
  }

  /// Récupère toutes les réparations
  Future<List<Map<String, dynamic>>> getRepairs() async {
    try {
      final response = await client
          .from(SupabaseConfig.repairsTable)
          .select()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      final List<dynamic> rawData = response.data as List;
      return rawData.map((item) => _sanitizeRepairData(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réparations: $e');
      rethrow;
    }
  }
  
  /// Récupère les réparations d'un client
  Future<List<Map<String, dynamic>>> getClientRepairs(String clientId) async {
    try {
      final response = await client
          .from(SupabaseConfig.repairsTable)
          .select()
          .eq('client_id', clientId)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      final List<dynamic> rawData = response.data as List;
      return rawData.map((item) => _sanitizeRepairData(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réparations du client: $e');
      rethrow;
    }
  }
  
  /// Récupère les réparations d'un point relais
  Future<List<Map<String, dynamic>>> getPointRelaisRepairs(String pointRelaisId) async {
    try {
      final response = await client
          .from(SupabaseConfig.repairsTable)
          .select()
          .eq('point_relais_id', pointRelaisId)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      final List<dynamic> rawData = response.data as List;
      return rawData.map((item) => _sanitizeRepairData(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réparations du point relais: $e');
      rethrow;
    }
  }
  
  /// Crée ou met à jour une réparation
  Future<void> upsertRepair(Map<String, dynamic> repairData) async {
    try {
      final response = await client
          .from(SupabaseConfig.repairsTable)
          .upsert(repairData)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
    } catch (e) {
      print('Erreur lors de la création/mise à jour de la réparation: $e');
      rethrow;
    }
  }
  
  /// Récupère les messages d'une conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await client
          .from(SupabaseConfig.messagesTable)
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      print('Erreur lors de la récupération des messages: $e');
      rethrow;
    }
  }
  
  /// Envoie un message
  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await client
          .from(SupabaseConfig.messagesTable)
          .insert(messageData)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }
  
  /// S'abonne aux changements d'une table
  Stream<List<Map<String, dynamic>>> subscribeToTable(String table, {String? filter}) {
    try {
      final stream = client
          .from(table)
          .stream(primaryKey: ['id'])
          .execute();
      
      return stream.map((data) => List<Map<String, dynamic>>.from(data));
    } catch (e) {
      print('Erreur lors de l\'abonnement à la table $table: $e');
      rethrow;
    }
  }

  /// Récupère les détails d'un technicien par son ID
  Future<Map<String, dynamic>?> getTechnicienDetailsById(String technicienId) async {
    try {
      final response = await client
          .from(SupabaseConfig.technicienDetailsTable)
          .select()
          .eq('id', technicienId)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        final errorMsg = SupabaseHelper.getErrorMessage(response);
        if (errorMsg.contains('No rows found')) {
          return null;
        }
        throw Exception(errorMsg);
      }
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Erreur lors de la récupération des détails du technicien: $e');
      rethrow;
    }
  }

  /// Crée ou met à jour les détails d'un technicien
  Future<void> upsertTechnicienDetails(Map<String, dynamic> technicienData) async {
    try {
      final response = await client
          .from(SupabaseConfig.technicienDetailsTable)
          .upsert(technicienData)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
    } catch (e) {
      print('Erreur lors de la création/mise à jour des détails du technicien: $e');
      rethrow;
    }
  }

  /// Récupère les réparations assignées à un technicien
  Future<List<Map<String, dynamic>>> getTechnicienRepairs(String technicienId) async {
    try {
      final response = await client
          .from(SupabaseConfig.repairsTable)
          .select()
          .eq('technicien_id', technicienId)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      final List<dynamic> rawData = response.data as List;
      return rawData.map((item) => _sanitizeRepairData(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réparations du technicien: $e');
      rethrow;
    }
  }
}
