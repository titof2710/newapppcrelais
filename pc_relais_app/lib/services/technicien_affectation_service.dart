import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/safe_list_from_json.dart';

class TechnicienAffectationService {
  final SupabaseClient client;
  final String table = 'technicien_point_relais';

  TechnicienAffectationService(this.client);

  Future<List<String>> getAssignedPointRelaisIds(String technicienId) async {
    try {
      final data = await client
          .from(table)
          .select('point_relais_id')
          .eq('technicien_id', technicienId);
      return safeListFromJson(
        (data as List).map((e) => e['point_relais_id'] as String).toList(),
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des affectations: $e');
    }
  }

  Future<List<UserModel>> getAllPointRelais() async {
    try {
      final data = await client
          .from('users')
          .select()
          .eq('user_type', 'point_relais');
      return List<UserModel>.from(
        (data as List).map((e) => UserModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des points relais: $e');
    }
  }

  Future<void> assignTechnicienToPointRelais(String technicienId, String pointRelaisId) async {
    try {
      await client.from(table).insert({
        'technicien_id': technicienId,
        'point_relais_id': pointRelaisId,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'affectation: $e');
    }
  }

  Future<void> unassignTechnicienFromPointRelais(String technicienId, String pointRelaisId) async {
    try {
      await client.from(table)
          .delete()
          .eq('technicien_id', technicienId)
          .eq('point_relais_id', pointRelaisId);
    } catch (e) {
      throw Exception('Erreur lors de la désaffectation: $e');
    }
  }

  Future<List<UserModel>> getTechniciensForPointRelais(String pointRelaisId) async {
    try {
      final data = await client
          .from(table)
          .select('technicien_id')
          .eq('point_relais_id', pointRelaisId);
      final ids = (data as List).map((e) => e['technicien_id'] as String).toList();
      if (ids.isEmpty) return [];
      final users = await client
          .from('users')
          .select()
          .inFilter('id', ids)
          .eq('user_type', 'technicien');
      return List<UserModel>.from(
        (users as List).map((e) => UserModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des techniciens: $e');
    }
  }

  Future<List<UserModel>> getMyPointRelais(String technicienId) async {
    try {
      final data = await client
          .from(table)
          .select('point_relais_id')
          .eq('technicien_id', technicienId);
      final ids = (data as List).map((e) => e['point_relais_id'] as String).toList();
      if (ids.isEmpty) return [];
      final users = await client
          .from('users')
          .select()
          .inFilter('id', ids)
          .eq('user_type', 'point_relais');
      return List<UserModel>.from(
        (users as List).map((e) => UserModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des points relais: $e');
    }
  }
}
