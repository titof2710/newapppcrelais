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

  /// Recherche un dépôt par id (uuid) ou par identifiant texte (par exemple reference ou code).
  Future<DepositModel?> getDepositByIdOrReference(String value) async {
    // On tente d'abord par id (uuid)
    try {
      final response = await client.from(table).select().eq('id', value).maybeSingle();
      if ((response.status == 200 || response.status == 201) && response.data != null) {
        return DepositModel.fromJson(response.data);
      }
    } catch (_) {
      // On ignore l'erreur car ce n'est peut-être pas un uuid
    }
    // Si ce n'est pas un uuid, on tente par le champ "reference" (ou "code")
    // Remplace 'reference' par le nom réel de ton champ métier si besoin !
    final response2 = await client.from(table).select().eq('reference', value).maybeSingle();
    if ((response2.status == 200 || response2.status == 201) && response2.data != null) {
      return DepositModel.fromJson(response2.data);
    }
    return null;
  }

  Future<void> updateDepositStatus(String id, String status) async {
    final response = await client.from(table).update({'status': status}).eq('id', id).execute();
    if (response.status != 201 && response.status != 200) {
      throw Exception('Erreur lors de la mise à jour du statut du dépôt: ${response.data}');
    }
  }
}
