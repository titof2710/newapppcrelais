import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/repair_model.dart';
import 'supabase_config.dart';
import 'supabase_service.dart';
import 'supabase_helper.dart';

class RepairService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseService _supabaseService = SupabaseService();

  // Créer une nouvelle demande de réparation (réservé aux administrateurs et techniciens)
  Future<RepairModel> createRepair(RepairModel repair) async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier si l'utilisateur est un administrateur ou un technicien
      final userResponse = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', currentUser.uid)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(userResponse)) {
        throw Exception('Utilisateur non trouvé');
      }
      
      final userData = userResponse.data as Map<String, dynamic>;
      final String userType = userData['user_type'] as String;
      if (userType != 'admin' && userType != 'technicien') {
        throw Exception('Seuls les administrateurs et les techniciens peuvent créer des réparations');
      }

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

  // Obtenir une réparation par son ID
  Future<RepairModel> getRepairById(String repairId) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .select()
          .eq('id', repairId)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Réparation introuvable: ${SupabaseHelper.getErrorMessage(response)}');
      }

      return RepairModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la réparation: $e');
    }
  }

  // Obtenir toutes les réparations d'un client avec ID spécifié
  Future<List<RepairModel>> getClientRepairsById(String clientId) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false)
          .execute();

      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des réparations: ${SupabaseHelper.getErrorMessage(response)}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => RepairModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réparations: $e');
    }
  }

  // Obtenir toutes les réparations associées à un point relais avec ID spécifié
  Future<List<RepairModel>> getPointRelaisRepairsById(String pointRelaisId) async {
    return getRepairsForPointRelais(pointRelaisId);
  }

  // Alias pour getPointRelaisRepairsById pour la compatibilité
  Future<List<RepairModel>> getRepairsForPointRelais(String pointRelaisId, {RepairStatus? status}) async {
    try {
      // Construire la requête de base
      final query = _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .select();
      
      // Appliquer les filtres
      if (status != null) {
        // Filtrer par point relais ET statut
        final response = await query
            .eq('point_relais_id', pointRelaisId)
            .eq('status', status.toString().split('.').last)
            .order('created_at', ascending: false)
            .execute();
            
        if (SupabaseHelper.hasError(response)) {
          throw Exception('Erreur lors de la récupération des réparations: ${SupabaseHelper.getErrorMessage(response)}');
        }
        
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => RepairModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Filtrer uniquement par point relais
        final response = await query
            .eq('point_relais_id', pointRelaisId)
            .order('created_at', ascending: false)
            .execute();
            
        if (SupabaseHelper.hasError(response)) {
          throw Exception('Erreur lors de la récupération des réparations: ${SupabaseHelper.getErrorMessage(response)}');
        }
        
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => RepairModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réparations: $e');
    }
  }
  
  // Obtenir toutes les réparations d'un client avec ID spécifié
  Future<List<RepairModel>> getRepairsForClient(String clientId) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false)
          .execute();

      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des réparations: ${SupabaseHelper.getErrorMessage(response)}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => RepairModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réparations: $e');
    }
  }

  // Mettre à jour le statut d'une réparation
  Future<void> updateRepairStatus(String repairId, RepairStatus newStatus) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .update({
            'status': newStatus.toString().split('.').last,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', repairId)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la mise à jour du statut: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Ajouter une note à une réparation
  Future<void> addRepairNote(String repairId, RepairNote note) async {
    try {
      // D'abord, récupérer la réparation existante
      final repair = await getRepairById(repairId);
      
      // Ajouter la nouvelle note à la liste existante
      final List<RepairNote> updatedNotes = [...repair.notes, note];
      
      // Mettre à jour la réparation
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .update({
            'notes': updatedNotes.map((n) => n.toJson()).toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', repairId)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de l\'ajout de la note: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la note: $e');
    }
  }

  // Ajouter une tâche à une réparation
  Future<void> addRepairTask(String repairId, RepairTask task) async {
    try {
      // D'abord, récupérer la réparation existante
      final repair = await getRepairById(repairId);
      
      // Ajouter la nouvelle tâche à la liste existante
      final List<RepairTask> updatedTasks = [...repair.tasks, task];
      
      // Mettre à jour la réparation
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .update({
            'tasks': updatedTasks.map((t) => t.toJson()).toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', repairId)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de l\'ajout de la tâche: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la tâche: $e');
    }
  }

  // Mettre à jour une tâche de réparation
  Future<void> updateRepairTask(String repairId, RepairTask updatedTask) async {
    try {
      // D'abord, récupérer la réparation actuelle
      final RepairModel repair = await getRepairById(repairId);
      
      // Trouver l'index de la tâche à mettre à jour
      final int taskIndex = repair.tasks.indexWhere((task) => task.id == updatedTask.id);
      
      if (taskIndex == -1) {
        throw Exception('Tâche introuvable');
      }
      
      // Créer une nouvelle liste de tâches avec la tâche mise à jour
      final List<RepairTask> updatedTasks = List.from(repair.tasks);
      updatedTasks[taskIndex] = updatedTask;
      
      // Mettre à jour la réparation dans Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .update({
            'tasks': updatedTasks.map((task) => task.toJson()).toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', repairId)
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la mise à jour de la tâche: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la tâche: $e');
    }
  }

  // Mettre à jour le prix estimé d'une réparation
  Future<void> updateRepairEstimatedPrice(String repairId, double estimatedPrice) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .update({
            'estimatedPrice': estimatedPrice,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', repairId)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la mise à jour du prix estimé: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du prix estimé: $e');
    }
  }

  // Marquer une réparation comme payée
  Future<void> markRepairAsPaid(String repairId) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.repairsTable)
          .update({
            'isPaid': true,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', repairId)
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors du marquage comme payé: ${SupabaseHelper.getErrorMessage(response)}');
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage comme payé: $e');
    }
  }
  
  // Obtenir toutes les réparations de l'utilisateur client actuel
  Future<List<RepairModel>> getClientRepairs() async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      return getClientRepairsById(currentUser.uid);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réparations: $e');
    }
  }
  
  // Obtenir toutes les réparations associées au point relais actuel
  Future<List<RepairModel>> getRelayRepairs() async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      return getPointRelaisRepairsById(currentUser.uid);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réparations: $e');
    }
  }
  
  // Obtenir un flux (stream) de toutes les réparations du client actuel
  Stream<List<RepairModel>> getClientRepairsStream() {
    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Retourner un stream vide si l'utilisateur n'est pas connecté
      return Stream.value([]);
    }
    
    return getClientRepairsStreamById(currentUser.uid);
  }
  
  // Obtenir un flux (stream) de toutes les réparations associées au point relais actuel
  Stream<List<RepairModel>> getPointRelaisRepairsStream() {
    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Retourner un stream vide si l'utilisateur n'est pas connecté
      return Stream.value([]);
    }
    
    return getPointRelaisRepairsStreamById(currentUser.uid);
  }

  // Obtenir un flux (stream) de mises à jour pour une réparation spécifique
  Stream<RepairModel> getRepairStream(String repairId) {
    // Avec Supabase, nous devons simuler un stream en utilisant des requêtes répétées
    // ou utiliser les fonctionnalités de temps réel de Supabase
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await getRepairById(repairId);
    });
    
    // Alternative avec Supabase Realtime (nécessite une configuration côté serveur)
    // return _supabaseService.client
    //     .from(SupabaseConfig.repairsTable)
    //     .stream(['id'])
    //     .eq('id', repairId)
    //     .execute()
    //     .map((data) {
    //       if (data.isEmpty) return RepairModel();
    //       return RepairModel.fromJson(data.first as Map<String, dynamic>);
    //     });
  }

  // Obtenir un flux (stream) de toutes les réparations d'un client avec ID spécifié
  Stream<List<RepairModel>> getClientRepairsStreamById(String clientId) {
    // Avec Supabase, nous devons simuler un stream en utilisant des requêtes répétées
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      return await getClientRepairsById(clientId);
    });
    
    // Alternative avec Supabase Realtime (nécessite une configuration côté serveur)
    // return _supabaseService.client
    //     .from(SupabaseConfig.repairsTable)
    //     .stream(['id'])
    //     .eq('client_id', clientId)
    //     .order('created_at', ascending: false)
    //     .execute()
    //     .map((data) => data
    //         .map((item) => RepairModel.fromJson(item as Map<String, dynamic>))
    //         .toList());
  }

  // Obtenir un flux (stream) de toutes les réparations associées à un point relais avec ID spécifié
  Stream<List<RepairModel>> getPointRelaisRepairsStreamById(String pointRelaisId) {
    // Avec Supabase, nous devons simuler un stream en utilisant des requêtes répétées
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      return await getPointRelaisRepairsById(pointRelaisId);
    });
    
    // Alternative avec Supabase Realtime (nécessite une configuration côté serveur)
    // return _supabaseService.client
    //     .from(SupabaseConfig.repairsTable)
    //     .stream(['id'])
    //     .eq('point_relais_id', pointRelaisId)
    //     .order('created_at', ascending: false)
    //     .execute()
    //     .map((data) => data
    //         .map((item) => RepairModel.fromJson(item as Map<String, dynamic>))
    //         .toList());
  }
}
