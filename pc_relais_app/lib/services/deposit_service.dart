import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deposit_model.dart';

class DepositService {
  final SupabaseClient client;
  final String table = 'deposits';

  DepositService(this.client);

  Future<String> createDeposit(DepositModel deposit) async {
    final response = await client.from(table).insert(deposit.toJson()).select('id').single();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la création du dépôt: ${response.data}');
    }
    return response.data['id'] as String;
  }

  Future<DepositModel?> getDepositById(String id) async {
    final response = await client.from(table).select().eq('id', id).maybeSingle();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la récupération du dépôt: ${response.data}');
    }
    if (response.data == null) return null;
    return DepositModel.fromJson(response.data);
  }

  Future<void> updateDepositStatus(String id, String status) async {
    final response = await client.from(table).update({'status': status}).eq('id', id).execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la mise à jour du statut du dépôt: ${response.data}');
    }
  }
}
