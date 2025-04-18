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
      final List<dynamic> data = await client
          .from(SupabaseConfig.usersTable)
          .select();
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      rethrow;
    }
  }
  
  /// Récupère un utilisateur par son ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final data = await client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('uuid', userId)
          .maybeSingle();
      if (data == null) {
        return null;
      }
      return data as Map<String, dynamic>;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      rethrow;
    }
  }
  
  /// Crée ou met à jour un utilisateur
  Future<void> upsertUser(Map<String, dynamic> userData) async {
    try {
      // Vérifier si l'ID est fourni
      if (!userData.containsKey('uuid') || userData['uuid'] == null) {
        throw Exception('ID utilisateur requis pour la mise à jour');
      }
      
      // Récupérer les données existantes de l'utilisateur
      final existingUserData = await getUserById(userData['uuid']);
      
      // Si l'utilisateur existe, fusionner les données
      if (existingUserData != null) {
        print('Mise à jour de l\'utilisateur existant: ${userData['uuid']}');
        // Créer une copie des données existantes
        final Map<String, dynamic> mergedData = Map<String, dynamic>.from(existingUserData);
        // Ajouter/remplacer les nouvelles données
        mergedData.addAll(userData);
        
        print('Données fusionnées: $mergedData');
        
        // Effectuer la mise à jour avec les données fusionnées
        await client
            .from(SupabaseConfig.usersTable)
            .update(mergedData)
            .eq('uuid', userData['uuid']);
      } else {
        // Si l'utilisateur n'existe pas, vérifier que toutes les données requises sont présentes
        if (!userData.containsKey('email') || userData['email'] == null) {
          throw Exception('Email requis pour la création d\'un utilisateur');
        }
        
        // Effectuer l'insertion
        await client
            .from(SupabaseConfig.usersTable)
            .insert(userData);
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
      print('Tentative de récupération des réparations avec la méthode simplifiée');
      
      // Approche simplifiée pour éviter les problèmes d'UUID
      try {
        // Récupérer toutes les réparations (limité à 1000 pour éviter les problèmes de performance)
        final response = await client
            .from(SupabaseConfig.repairsTable)
            .select()
            .limit(1000);
        
        final List<dynamic> allRepairs = response as List<dynamic>;
        final List<Map<String, dynamic>> sanitizedRepairs = allRepairs
            .map((item) => _sanitizeRepairData(item as Map<String, dynamic>))
            .toList();
        
        print('Récupération réussie: ${sanitizedRepairs.length} réparations trouvées');
        return sanitizedRepairs;
      } catch (e) {
        print('Erreur lors de la récupération des réparations (méthode simplifiée): $e');
        // En dernier recours, retourner une liste vide pour éviter le plantage de l'application
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des réparations: $e');
      // En dernier recours, retourner une liste vide pour éviter le plantage de l'application
      return [];
    }
  }

  /// Crée une fonction SQL dans Supabase pour récupérer toutes les réparations
  /// Cette fonction évite les problèmes de conversion de type UUID
  Future<void> _createGetAllRepairsFunction() async {
    try {
      // S'assurer que la fonction function_exists existe
      await _createFunctionExistsFunction();
      
      // Vérifier si la fonction get_all_repairs existe déjà
      final checkResponse = await client
          .rpc('function_exists', params: {'function_name': 'get_all_repairs'})
          ;
      
      final bool functionExists = checkResponse.data as bool? ?? false;
      if (functionExists) {
        print('La fonction get_all_repairs existe déjà');
        return;
      }
      
      // Créer la fonction SQL
      final sql = '''
      CREATE OR REPLACE FUNCTION get_all_repairs()
      RETURNS SETOF repairs AS \$\$
      BEGIN
        RETURN QUERY SELECT * FROM repairs;
      END;
      \$\$ LANGUAGE plpgsql;
      ''';
      
      await client.rpc('run_sql', params: {'sql': sql});
      print('Fonction get_all_repairs créée avec succès');
    } catch (e) {
      print('Erreur lors de la création de la fonction get_all_repairs: $e');
      // En cas d'échec, nous continuerons avec la méthode standard
    }
  }

  /// Récupère les réparations d'un client
  Future<List<Map<String, dynamic>>> getClientRepairs(String clientId) async {
    try {
      print('Tentative de récupération des réparations du client avec la méthode simplifiée');
      
      // Approche simplifiée pour éviter les problèmes d'UUID
      // Au lieu d'utiliser .eq('client_id', clientId) qui peut causer des problèmes de type UUID,
      // récupérons toutes les réparations et filtrons-les en mémoire
      try {
        // Récupérer toutes les réparations (limité à 1000 pour éviter les problèmes de performance)
        final response = await client
            .from(SupabaseConfig.repairsTable)
            .select()
            .limit(1000);
        
        final List<dynamic> allRepairs = response as List<dynamic>;
        
        // Filtrer les réparations pour ce client spécifique
        final List<Map<String, dynamic>> clientRepairs = allRepairs
            .where((repair) => repair['client_id'] == clientId)
            .map((item) => _sanitizeRepairData(item as Map<String, dynamic>))
            .toList();
        
        print('Récupération réussie: ${clientRepairs.length} réparations trouvées pour le client $clientId');
        return clientRepairs;
      } catch (e) {
        print('Erreur lors de la récupération des réparations (méthode simplifiée): $e');
        // En dernier recours, retourner une liste vide pour éviter le plantage de l'application
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des réparations du client: $e');
      // En dernier recours, retourner une liste vide pour éviter le plantage de l'application
      return [];
    }
  }
  
  /// Crée une fonction SQL dans Supabase pour récupérer les réparations d'un client
  Future<void> _createGetClientRepairsFunction() async {
    try {
      // S'assurer que la fonction function_exists existe
      await _createFunctionExistsFunction();
      
      // Vérifier si la fonction get_client_repairs existe déjà
      final checkResponse = await client
          .rpc('function_exists', params: {'function_name': 'get_client_repairs'});
      
      final bool functionExists = checkResponse.data as bool? ?? false;
      if (functionExists) {
        print('La fonction get_client_repairs existe déjà');
        return;
      }
      
      // Créer la fonction SQL
      final sql = '''
      CREATE OR REPLACE FUNCTION get_client_repairs(client_id_param TEXT)
      RETURNS SETOF repairs AS \$\$
      BEGIN
        RETURN QUERY SELECT * FROM repairs WHERE client_id = client_id_param;
      END;
      \$\$ LANGUAGE plpgsql;
      ''';
      
      await client.rpc('run_sql', params: {'sql': sql});
      print('Fonction get_client_repairs créée avec succès');
    } catch (e) {
      print('Erreur lors de la création de la fonction get_client_repairs: $e');
      // En cas d'échec, nous continuerons avec la méthode standard
    }
  }
  
  /// Récupère les réparations d'un point relais
  Future<List<Map<String, dynamic>>> getPointRelaisRepairs(String pointRelaisId) async {
    try {
      final response = await client
          .from(SupabaseConfig.repairsTable)
          .select()
          .eq('point_relais_id', pointRelaisId)
          ;
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      final List<dynamic> rawData = response as List<dynamic>;
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
          ;
      
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
          ;
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      return List<Map<String, dynamic>>.from(response as List);
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
          ;
      
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
          .stream(primaryKey: ['uuid'])
          ;
      
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
          .eq('uuid', technicienId)
          .single()
          ;
      
      if (SupabaseHelper.hasError(response)) {
        final errorMsg = SupabaseHelper.getErrorMessage(response);
        if (errorMsg.contains('No rows found')) {
          return null;
        }
        throw Exception(errorMsg);
      }
      
      return response as Map<String, dynamic>;
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
          ;
      
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
          ;
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      final List<dynamic> rawData = response as List<dynamic>;
      return rawData.map((item) => _sanitizeRepairData(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réparations du technicien: $e');
      rethrow;
    }
  }
  
  /// S'assure que la fonction run_sql existe dans Supabase
  Future<void> _ensureRunSqlFunctionExists() async {
    try {
      // Essayer d'exécuter une requête SQL simple pour vérifier si run_sql existe
      await client.rpc('run_sql', params: {'sql': 'SELECT 1;'});
      print('La fonction run_sql existe déjà');
    } catch (e) {
      print('La fonction run_sql n\'existe pas, tentative de création...');
      // Si la fonction n'existe pas, nous devons la créer manuellement
      // Cela nécessite des privilèges d'administrateur sur la base de données
      // Cette partie devrait être gérée par un administrateur de base de données
      print('ERREUR: La fonction run_sql n\'existe pas dans votre base de données Supabase.');
      print('Cette fonction nécessite des privilèges d\'administrateur pour être créée.');
      print('Veuillez contacter votre administrateur Supabase pour créer cette fonction.');
      
      // Comme alternative, nous allons utiliser une approche différente pour récupérer les réparations
      throw Exception('La fonction run_sql n\'est pas disponible. Utilisez une méthode alternative pour récupérer les données.');
    }
  }
  
  /// Crée une fonction SQL dans Supabase pour vérifier si une fonction existe
  Future<void> _createFunctionExistsFunction() async {
    try {
      // Vérifier d'abord si la fonction run_sql existe
      await _ensureRunSqlFunctionExists();
      
      // Vérifier si la fonction function_exists existe déjà en utilisant une requête SQL directe
      final checkSql = '''
      SELECT EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public' AND p.proname = 'function_exists'
      ) as exists;
      ''';
      
      final checkResult = await client.rpc('run_sql', params: {'sql': checkSql});
      
      // Analyser le résultat pour voir si la fonction existe
      bool functionExists = false;
      if (checkResult.data != null && checkResult.data is List && (checkResult.data as List).isNotEmpty) {
        final resultMap = (checkResult.data as List)[0] as Map<String, dynamic>;
        functionExists = resultMap['exists'] as bool? ?? false;
      }
      
      if (functionExists) {
        print('La fonction function_exists existe déjà');
        return;
      }
      
      // Créer la fonction function_exists
      final sql = '''
      CREATE OR REPLACE FUNCTION function_exists(function_name TEXT)
      RETURNS BOOLEAN AS \$\$
      BEGIN
        RETURN EXISTS (
          SELECT 1 FROM pg_proc p
          JOIN pg_namespace n ON p.pronamespace = n.oid
          WHERE n.nspname = 'public' AND p.proname = function_name
        );
      END;
      \$\$ LANGUAGE plpgsql;
      ''';
      
      await client.rpc('run_sql', params: {'sql': sql});
      print('Fonction function_exists créée avec succès');
    } catch (e) {
      print('Erreur lors de la création de la fonction function_exists: $e');
      // En cas d'échec, nous continuerons avec la méthode standard
    }
  }
}
