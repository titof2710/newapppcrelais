import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deposit_model.dart';
import 'supabase_config.dart';
import 'storage_service.dart';

class DepositService {
  final SupabaseClient client;
  final String table = SupabaseConfig.depositsTable;

  DepositService(this.client);

  Future<String> createDeposit(DepositModel deposit) async {
    try {
      // Créer une copie du modèle pour éviter de modifier l'original
      final depositJson = deposit.toJson();
      
      // Le DepositModel.toJson() gère déjà correctement les IDs client
      // en mettant l'ID dans client_id uniquement s'il est un UUID valide
      // et dans firebase_client_id sinon
      
      // Insérer dans Supabase
      final response = await client.from(table).insert(depositJson).select('id').single();
      if (response == null || response['id'] == null) {
        throw Exception('Erreur lors de la création du dépôt: $response');
      }
      return response['id'] as String;
    } catch (e) {
      print('Erreur détaillée lors de la création du dépôt: $e');
      throw Exception('Erreur lors de la création du dépôt: $e');
    }
  }
  
  // Vérifie si une chaîne est un UUID valide
  bool _isValidUuid(String str) {
    // Format UUID: 8-4-4-4-12 (32 caractères + 4 tirets)
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false
    );
    return uuidRegex.hasMatch(str);
  }

  /// Recherche un dépôt par id (uuid) ou par identifiant texte (par exemple reference ou code).
  Future<DepositModel?> getDepositByIdOrReference(String value) async {
    // On tente d'abord par id (uuid)
    try {
      final response = await client.from(table).select().eq('id', value).maybeSingle();
      if (response != null) {
        return DepositModel.fromJson(response);
      }
    } catch (_) {
      // On ignore l'erreur car ce n'est peut-être pas un uuid
    }
    // Si ce n'est pas un uuid, on tente par le champ "reference" (ou "code")
    // Remplace 'reference' par le nom réel de ton champ métier si besoin !
    final response2 = await client.from(table).select().eq('reference', value).maybeSingle();
    if (response2 != null) {
      return DepositModel.fromJson(response2);
    }
    return null;
  }

  Future<void> updateDepositStatus(String id, String status) async {
    final response = await client.from(table).update({'status': status}).eq('id', id).select().maybeSingle();
    if (response == null) {
      throw Exception('Erreur lors de la mise à jour du statut du dépôt: $response');
    }
  }
}
