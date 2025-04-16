import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class TechnicienAffectationService {
  final SupabaseClient client;
  final String table = 'technicien_point_relais';

  TechnicienAffectationService(this.client);

  Future<List<String>> getAssignedPointRelaisIds(String technicienId) async {
    final response = await client
        .from(table)
        .select('point_relais_id')
        .eq('technicien_id', technicienId)
        .execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la récupération des affectations: ${response.data}');
    }
    return (response.data as List)
        .map((e) => e['point_relais_id'] as String)
        .toList();
  }

  Future<List<UserModel>> getAllPointRelais() async {
    final response = await client
        .from('users')
        .select()
        .eq('user_type', 'point_relais')
        .execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la récupération des points relais: ${response.data}');
    }
    return (response.data as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignTechnicienToPointRelais(String technicienId, String pointRelaisId) async {
    final response = await client.from(table).insert({
      'technicien_id': technicienId,
      'point_relais_id': pointRelaisId,
    }).execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de l\'affectation: ${response.data}');
    }
  }

  Future<void> unassignTechnicienFromPointRelais(String technicienId, String pointRelaisId) async {
    final response = await client.from(table)
        .delete()
        .eq('technicien_id', technicienId)
        .eq('point_relais_id', pointRelaisId)
        .execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la désaffectation: ${response.data}');
    }
  }

  Future<List<UserModel>> getTechniciensForPointRelais(String pointRelaisId) async {
    final response = await client
        .from(table)
        .select('technicien_id')
        .eq('point_relais_id', pointRelaisId)
        .execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la récupération des techniciens: ${response.data}');
    }
    final ids = (response.data as List).map((e) => e['technicien_id'] as String).toList();
    if (ids.isEmpty) return [];
    final usersResponse = await client
        .from('users')
        .select()
        .in_('id', ids)
        .eq('user_type', 'technicien')
        .execute();
    if (usersResponse.status != 201 && usersResponse.status != 200) {
      throw Exception('Erreur lors de la récupération des techniciens: ${usersResponse.data}');
    }
    return (usersResponse.data as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> getMyPointRelais(String technicienId) async {
    final response = await client
        .from(table)
        .select('point_relais_id')
        .eq('technicien_id', technicienId)
        .execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la récupération des affectations: ${response.data}');
    }
    final ids = (response.data as List).map((e) => e['point_relais_id'] as String).toList();
    if (ids.isEmpty) return [];
    final usersResponse = await client
        .from('users')
        .select()
        .in_('id', ids)
        .eq('user_type', 'point_relais')
        .execute();
    if (usersResponse.status != 201 && usersResponse.status != 200) {
      throw Exception('Erreur lors de la récupération des points relais: ${usersResponse.data}');
    }
    return (usersResponse.data as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
